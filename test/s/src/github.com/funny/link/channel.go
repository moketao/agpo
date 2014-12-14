package link

import "github.com/funny/sync"

// The channel type. Used to maintain a group of session.
// Normally used for broadcast classify purpose.
type Channel struct {
	broadcaster *Broadcaster
	mutex       sync.RWMutex
	sessions    map[uint64]channelSession
}

type channelSession struct {
	*Session
	KickCallback func()
}

// Create a channel instance.
func NewChannel(protocol PacketProtocol) *Channel {
	return &Channel{
		broadcaster: NewBroadcaster(protocol),
		sessions:    make(map[uint64]channelSession),
	}
}

// How mush sessions in this channel.
func (channel *Channel) Len() int {
	channel.mutex.RLock()
	defer channel.mutex.RUnlock()
	return len(channel.sessions)
}

// Join the channel. The kickCallback will called when the session kick out from the channel.
func (channel *Channel) Join(session *Session, kickCallback func()) {
	channel.mutex.Lock()
	defer channel.mutex.Unlock()
	session.AddCloseEventListener(channel)
	channel.sessions[session.Id()] = channelSession{session, kickCallback}
}

// Implement the SessionCloseEventListener interface.
func (channel *Channel) OnSessionClose(session *Session) {
	channel.Exit(session)
}

// Exit the channel.
func (channel *Channel) Exit(session *Session) {
	channel.mutex.Lock()
	defer channel.mutex.Unlock()

	session.RemoveCloseEventListener(channel)
	delete(channel.sessions, session.Id())
}

// Kick out a session from the channel.
func (channel *Channel) Kick(sessionId uint64) {
	channel.mutex.Lock()
	defer channel.mutex.Unlock()
	if session, exists := channel.sessions[sessionId]; exists {
		delete(channel.sessions, sessionId)
		if session.KickCallback != nil {
			session.KickCallback()
		}
	}
}

// Fetch the sessions. NOTE: Invoke Kick() or Exit() in fetch callback will dead lock.
func (channel *Channel) Fetch(callback func(*Session)) {
	channel.mutex.RLock()
	defer channel.mutex.RUnlock()
	for _, sesssion := range channel.sessions {
		callback(sesssion.Session)
	}
}

// Broadcast to channel sessions.
func (channel *Channel) Broadcast(message Message) error {
	return channel.broadcaster.Broadcast(channel, message)
}

// Broadcast to channel sessions.
func (channel *Channel) MustBroadcast(message Message) error {
	return channel.broadcaster.MustBroadcast(channel, message)
}
