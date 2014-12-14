package cmds

import (
	"github.com/funny/link"
)

type Sub struct {
	f1 int8  //8，adsfsadf
}

func (s *Sub) UnPackFrom(p *link.InBufferBE) Sub {
	s.f1 = p.ReadInt8() //adsfsadf
	return *s
}

func (s *Sub) PackInTo(p *link.OutBufferBE) {
	p.WriteInt8(s.f1) //adsfsadf
}

func (s *Sub)ToBuffer(cmdID uint16) *link.OutBufferBE {
	p := new(link.OutBufferBE)
	p.WriteUint16(cmdID) //写入协议号
	s.PackInTo(p)
	return p
}
