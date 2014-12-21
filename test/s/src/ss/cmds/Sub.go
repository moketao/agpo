package cmds

import (
	"github.com/funny/link"
)

type Sub struct {
	s1 int8   //8，s1
	s2 int16  //16，s2
}

func (s *Sub) UnPackFrom(b *link.InBuffer) Sub {
	p := *b
	s.s1 = p.ReadInt8()  //s1
	s.s2 = p.ReadInt16() //s2
	return *s
}

func (s *Sub) PackInTo(p *link.OutBufferBE) {
	p.WriteInt8(s.s1)  //s1
	p.WriteInt16(s.s2) //s2
}

func (s *Sub)ToBuffer(cmdID uint16) *link.OutBufferBE {
	p := new(link.OutBufferBE)
	(*p).WriteUint16(cmdID) //写入协议号
	s.PackInTo(p)
	return p
}
