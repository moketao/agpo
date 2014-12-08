package cmds

import (
	. "base"
)

type C1000Down struct {
	ok string  //String，成功与否
}

func (s *C1000Down)PackInTo(p *Pack) {
	p.WriteUInt16(1000) //写入协议号
	p.WriteString(s.ok)//成功与否
}
func (s *C1000Down)ToBytes() []byte {
	pack := NewPackEmpty()
	s.PackInTo(pack)
	return pack.Data()
}
