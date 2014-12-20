package main

import (
	"fmt"
	"github.com/funny/link"
	//"time"
	. "ss/cmds"
)

// This is broadcast server demo work with the echo_client.
// usage:
//     go run broadcast/main.go
func main() {
	protocol := link.PacketN(2, link.BigEndianBO, link.BigEndianBF)

	server, err := link.Listen("tcp", "127.0.0.1:9999", protocol)
	if err != nil {
		panic(err)
	}

	channel := link.NewChannel(server.Protocol())
	//go func() {
	//	for {
	//		time.Sleep(time.Second)
	//		channel.Broadcast(link.Binary(time.Now().String()))
	//	}
	//}()

	println("server start")

	server.AcceptLoop(func(session *link.Session) {
		println("client", session.Conn().RemoteAddr().String(), "in")
		channel.Join(session, nil)
		session.ReadLoop(func(msg0 link.InBuffer) {
			//msg, _ := (&msg0).(link.InBufferBE)
			cmd := msg.ReadUint16()
			fmt.Println("收到协议", cmd)
			TraceBytes(msg.Get())
			res := DIC[cmd].Func(cmd, &msg, session)
			////channel.Broadcast(outBuffer.Get())
			session.SendPacket(res)

			fmt.Print("发送")
			TraceBytes(res.Get())
		})

		println("client", session.Conn().RemoteAddr().String(), "close")
		channel.Exit(session)
	})
}

/*显示 b的内部结构，以二进制的形式，如 00000000 00001111 00001000 */
func TraceBytes(b []byte) {
	fmt.Print("[ ")
	for i := 0; i < len(b); i++ {
		fmt.Printf("%08b ", b[i])
	}
	fmt.Print("]\n")
}
