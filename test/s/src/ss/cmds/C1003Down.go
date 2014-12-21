package cmds

import (
	"github.com/funny/link"
)

type C1003Down struct {
	a1 int8  //8，a1
}

func (s *C1003Down)PackInTo(p *link.OutBufferBE ) {
	p.WriteInt8(s.a1)//a1
}
func (s *C1003Down)ToBuffer() *link.OutBufferBE {
	p := new(link.OutBufferBE)
	(*p).WriteUint16(1003) //写入协议号
	s.PackInTo(p)
	return p
}
