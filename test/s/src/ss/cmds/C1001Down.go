package cmds

import (
	. "base"
)

type C1001Down struct {
	ok int8  //8，成功与否
}

func (s *C1001Down)PackInTo(p *Pack) {
	p.WriteUInt16(1001) //写入协议号
	p.WriteInt8(s.ok)//成功与否
}
func (s *C1001Down)ToBytes() []byte {
	pack := NewPackEmpty()
	s.PackInTo(pack)
	return pack.Data()
}
