package cmds

import (
	. "base"
)

type C1000Down struct {
	ok int8  //8，登陆成功与否
}

func (s *C1000Down)PackInTo(p *Pack) {
	p.WriteUInt16(1000) //写入协议号
	p.WriteInt8(s.ok)//登陆成功与否
}
func (s *C1000Down)ToBytes() []byte {
	pack := NewPackEmpty()
	s.PackInTo(pack)
	return pack.Data()
}
