package link

import (
	"bufio"
	"net"
	"sync/atomic"
	"time"
)

var dialSessionId uint64

// The easy way to setup a server.
func Listen(network, address string, protocol PacketProtocol) (*Server, error) {
	listener, err := net.Listen(network, address)
	if err != nil {
		return nil, err
	}
	return NewServer(listener, protocol), nil
}

// The easy way to create a connection.
func Dial(network, address string, protocol PacketProtocol) (*Session, error) {
	conn, err := net.Dial(network, address)
	if err != nil {
		return nil, err
	}
	id := atomic.AddUint64(&dialSessionId, 1)
	session := NewSession(id, conn, protocol, DefaultSendChanSize, DefaultReadBufferSize, DefaultWriteBufferSize)
	return session, nil
}

// The easy way to create a connection with timeout setting.
func DialTimeout(network, address string, timeout time.Duration, protocol PacketProtocol) (*Session, error) {
	conn, err := net.DialTimeout(network, address, timeout)
	if err != nil {
		return nil, err
	}
	id := atomic.AddUint64(&dialSessionId, 1)
	session := NewSession(id, conn, protocol, DefaultSendChanSize, DefaultReadBufferSize, DefaultWriteBufferSize)
	return session, nil
}

// This type implement the Settings interface.
// It's a simple way to make your custom protocol have package size limiting ability.
// See PNWriter and PNReader.
type SizeLimit struct {
	maxsize int
}

// Set max packet size and returns old size limitation.
// Set 0 means unlimit.
func (s *SizeLimit) GetMaxPacketSize() int {
	return s.maxsize
}

// Set max packet size.
// Set 0 means unlimit.
func (s *SizeLimit) SetMaxPacketSize(maxsize int) {
	s.maxsize = maxsize
}

// Buffered connection.
type BufferConn struct {
	net.Conn
	reader *bufio.Reader
	writer *bufio.Writer
}

func NewBufferConn(conn net.Conn, readBufferSize, writeBufferSize int) *BufferConn {
	return &BufferConn{
		conn,
		bufio.NewReaderSize(conn, readBufferSize),
		bufio.NewWriterSize(conn, writeBufferSize),
	}
}

func (conn *BufferConn) Read(d []byte) (int, error) {
	return conn.reader.Read(d)
}

func (conn *BufferConn) Write(p []byte) (int, error) {
	return conn.writer.Write(p)
}

func (conn *BufferConn) Flush() error {
	return conn.writer.Flush()
}
