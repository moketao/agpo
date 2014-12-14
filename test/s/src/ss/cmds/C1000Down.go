package cmds

import (
	"github.com/funny/link"
)

type C1000Down struct {
	name string  //String，原样返回名字
	ff int64     //64，ff
}

func (s *C1000Down)PackInTo(p *link.OutBufferBE ) {
	p.WriteInt16(int16(len(s.name)))
	p.WriteString(s.name)//原样返回名字
	p.WriteInt50(s.ff)//ff
}
func (s *C1000Down)ToBuffer() *link.OutBufferBE {
	p := new(link.OutBufferBE)
	p.WriteUint16(1000) //写入协议号
	s.PackInTo(p)
	return p
}
