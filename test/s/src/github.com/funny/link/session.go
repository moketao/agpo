package link

import (
	"container/list"
	"github.com/funny/sync"
	"net"
	"sync/atomic"
	"time"
)

// Session.
type Session struct {
	id uint64

	// About network
	conn          net.Conn
	protocol      PacketProtocol
	writer        PacketWriter
	reader        PacketReader
	bufferFactory BufferFactory

	// About send and receive
	usingBufferConn bool
	sendChan        chan Message
	sendPacketChan  chan OutBuffer
	readMutex       sync.Mutex
	sendMutex       sync.Mutex
	OnSendFailed    func(*Session, error)

	// About session close
	closeChan           chan int
	closeFlag           int32
	closeReason         interface{}
	closeEventMutex     sync.Mutex
	closeEventListeners *list.List

	// Put your session state here.
	State interface{}
}

// Create a new session instance.
func NewSession(id uint64, conn net.Conn, protocol PacketProtocol, sendChanSize int, readBufferSize, writeBufferSize int) *Session {
	usingBufferConn := false
	if readBufferSize > 0 || writeBufferSize > 0 {
		conn = NewBufferConn(conn, readBufferSize, writeBufferSize)
		usingBufferConn = true
	}

	session := &Session{
		id:                  id,
		conn:                conn,
		protocol:            protocol,
		writer:              protocol.NewWriter(),
		reader:              protocol.NewReader(),
		bufferFactory:       protocol.BufferFactory(),
		usingBufferConn:     usingBufferConn,
		sendChan:            make(chan Message, sendChanSize),
		sendPacketChan:      make(chan OutBuffer, sendChanSize),
		closeChan:           make(chan int),
		closeEventListeners: list.New(),
	}

	go session.sendLoop()

	return session
}

// Get session id.
func (session *Session) Id() uint64 {
	return session.id
}

// Get local address.
func (session *Session) Conn() net.Conn {
	return session.conn
}

// Get packet protocol.
func (session *Session) Protocol() PacketProtocol {
	return session.protocol
}

// Get packet reader.
func (session *Session) Reader() PacketReader {
	return session.reader
}

// Get packet writer.
func (session *Session) Writer() PacketWriter {
	return session.writer
}

// Check session is closed or not.
func (session *Session) IsClosed() bool {
	return atomic.LoadInt32(&session.closeFlag) != 0
}

// Get session close reason.
func (session *Session) CloseReason() interface{} {
	return session.closeReason
}

// Close session.
func (session *Session) Close(reason interface{}) {
	if atomic.CompareAndSwapInt32(&session.closeFlag, 0, 1) {
		session.closeReason = reason

		session.conn.Close()

		// exit send loop and cancel async send
		close(session.closeChan)

		session.dispatchCloseEvent()
	}
}

// Read message once.
func (session *Session) Read() (InBuffer, error) {
	var buffer = session.bufferFactory.NewInBuffer()
	if err := session.ReadReuseBuffer(buffer); err != nil {
		return nil, err
	}
	return buffer, nil
}

// Loop and read message. NOTE: The callback argument point to internal read buffer.
func (session *Session) ReadLoop(handler func(InBuffer)) {
	var buffer = session.bufferFactory.NewInBuffer()
	for {
		if err := session.ReadReuseBuffer(buffer); err != nil {
			session.Close(err)
			break
		}
		handler(buffer)
	}
}

// Read message once with buffer reusing.
// You can reuse a buffer for reading or just set buffer as nil is OK.
// About the buffer reusing, please see Read() and ReadLoop().
func (session *Session) ReadReuseBuffer(buffer InBuffer) error {
	if buffer == nil {
		panic(NilBufferError)
	}

	session.readMutex.Lock()
	defer session.readMutex.Unlock()

	if err := session.reader.ReadPacket(session.conn, buffer); err != nil {
		return err
	}

	return nil
}

// Packet a message.
func (session *Session) Packet(message Message, buffer OutBuffer) error {
	if buffer == nil {
		panic(NilBufferError)
	}
	buffer.Prepare(message.RecommendBufferSize())
	return message.WriteBuffer(buffer)
}

// Sync send a message. Equals Packet() and SendPacket(). This method will block on IO.
func (session *Session) Send(message Message) error {
	var buffer = session.bufferFactory.NewOutBuffer()
	return session.SendReuseBuffer(message, buffer)
}

// Sync send a packet. The packet must be properly formatted.
// Please see Packet().
func (session *Session) SendPacket(packet OutBuffer) error {
	session.sendMutex.Lock()
	defer session.sendMutex.Unlock()

	err := session.writer.WritePacket(session.conn, packet)
	if err == nil && session.usingBufferConn {
		return session.conn.(*BufferConn).Flush()
	}
	return err
}

// Sync send a message with buffer resuing.
// Equals Packet() and SendPacket().
// NOTE 1: This method will block on IO.
// NOTE 2: You can reuse a buffer for sending or just set buffer as nil is OK.
// About the buffer reusing, please see Send() and sendLoop().
func (session *Session) SendReuseBuffer(message Message, buffer OutBuffer) error {
	if err := session.Packet(message, buffer); err != nil {
		return err
	}
	return session.SendPacket(buffer)
}

// Loop and transport responses.
func (session *Session) sendLoop() {
	var buffer = session.bufferFactory.NewOutBuffer()
	for {
		select {
		case message := <-session.sendChan:
			if err := session.SendReuseBuffer(message, buffer); err != nil {
				if session.OnSendFailed != nil {
					session.OnSendFailed(session, err)
				} else {
					session.Close(err)
				}
				return
			}
		case packet := <-session.sendPacketChan:
			if err := session.SendPacket(packet); err != nil {
				if session.OnSendFailed != nil {
					session.OnSendFailed(session, err)
				} else {
					session.Close(err)
				}
				return
			}
		case <-session.closeChan:
			return
		}
	}
}

// Try async send a message.
// If send chan block until timeout happens, this method returns BlockingError.
func (session *Session) TrySend(message Message, timeout time.Duration) error {
	if session.IsClosed() {
		return SendToClosedError
	}

	select {
	case session.sendChan <- message:
	case <-session.closeChan:
		return SendToClosedError
	case <-time.After(timeout):
		return BlockingError
	}

	return nil
}

// Try async send a packet.
// If send chan block until timeout happens, this method returns BlockingError.
// The packet must be properly formatted. Please see Session.Packet().
func (session *Session) TrySendPacket(packet OutBuffer, timeout time.Duration) error {
	if session.IsClosed() {
		return SendToClosedError
	}

	select {
	case session.sendPacketChan <- packet:
	case <-session.closeChan:
		return SendToClosedError
	case <-time.After(timeout):
		return BlockingError
	}

	return nil
}

// The session close event listener interface.
type SessionCloseEventListener interface {
	OnSessionClose(*Session)
}

// Add close event listener.
func (session *Session) AddCloseEventListener(listener SessionCloseEventListener) {
	if session.IsClosed() {
		return
	}

	session.closeEventMutex.Lock()
	defer session.closeEventMutex.Unlock()

	session.closeEventListeners.PushBack(listener)
}

// Remove close event listener.
func (session *Session) RemoveCloseEventListener(listener SessionCloseEventListener) {
	if session.IsClosed() {
		return
	}

	session.closeEventMutex.Lock()
	defer session.closeEventMutex.Unlock()

	for i := session.closeEventListeners.Front(); i != nil; i = i.Next() {
		if i.Value == listener {
			session.closeEventListeners.Remove(i)
			return
		}
	}
}

// Dispatch close event.
func (session *Session) dispatchCloseEvent() {
	session.closeEventMutex.Lock()
	defer session.closeEventMutex.Unlock()

	for i := session.closeEventListeners.Front(); i != nil; i = i.Next() {
		i.Value.(SessionCloseEventListener).OnSessionClose(session)
	}
}
