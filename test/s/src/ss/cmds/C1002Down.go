package cmds

import (
	"github.com/funny/link"
)

type C1002Down struct {
	arr []Sub  //Array，[Sub]
}

func (s *C1002Down)PackInTo(p *link.OutBufferBE ) {
	count := len(s.arr)//数组长度（[Sub]）
	p.WriteUint16(uint16(count))
	for i := 0; i < count; i++ {
		s.arr[i].PackInTo(p)
	}
}
func (s *C1002Down)ToBuffer() *link.OutBufferBE {
	p := new(link.OutBufferBE)
	(*p).WriteUint16(1002) //写入协议号
	s.PackInTo(p)
	return p
}
