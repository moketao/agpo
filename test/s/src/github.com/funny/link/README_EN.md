Introduction
============

This is a simple network library for Go.

It focus on packet based persistent connection communication.

It provide a packet splitting protocol like Erlang's `{packet: N}` in default. And supported custom packet splitting protocol.

But it didn't limit the encode or decode format of the request and response.

Also this library provide session management and broadcast features to make your life easy.

How to install
==============

```
go get github.com/funny/link
```

How to use
===========

Choose a protocol for your project.

```go
proto := link.PacketN(2, link.BigEndianBO, link.LittleEndianBF)
```

Setup a server on port `8080` and set protocol.

```go
server, _ := link.Listen("tcp", "0.0.0.0:8080", proto)
```

Handle incoming connections. And setup a message handler on the new session.

```go
server.AcceptLoop(func(session *link.Session) {
	fmt.Println("session start")

	session.ReadLoop(func(session *link.Session, msg link.InBuffer) {
		fmt.Printf("new message: %s\n", msg.Get())
	})

	fmt.Println("session closed")
})
```

Use the same protocol dial to the server.

```go
proto := link.PacketN(2, link.BigEndianBO, link.LittleEndianBF)

client, _ := link.Dial("tcp", "127.0.0.1:8080", proto)
```

Send a message to server.

```go
client.Send(link.Binary("Hello World!"))
```

Examples
========

* [Echo server](https://github.com/funny/link/blob/master/examples/echo_server/main.go)
* [Echo client](https://github.com/funny/link/blob/master/examples/echo_client/main.go)
* [Broadcast server](https://github.com/funny/link/blob/master/examples/broadcast/main.go)
* [Benchmark tool](https://github.com/funny/link/blob/master/examples/benchmark/main.go)

Document
========

[Let's Go!](http://godoc.org/github.com/funny/link)
