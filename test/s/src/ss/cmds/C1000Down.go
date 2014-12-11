package cmds

import (
	"github.com/funny/link"
)

type C1000Down struct {
	ok int8 //8，登陆成功与否
}

func (s *C1000Down) PackInTo(p *link.OutBufferBE) {
	p.WriteUint16(1000) //写入协议号
	p.WriteInt8(s.ok)   //登陆成功与否
}
func (s *C1000Down) ToBytes() *link.OutBufferBE {
	p := new(link.OutBufferBE)
	s.PackInTo(p)
	return p
}
