package cmds

import (
	"github.com/funny/link"
)

type C1002Down struct {
	arr []int8  //Array，[8]
}

func (s *C1002Down)PackInTo(p *link.OutBufferBE ) {
	count := len(s.arr)//数组长度（[8]）
	p.WriteUint16(uint16(count))
	for i := 0; i < count; i++ {
		p.WriteInt8(s.arr[i])
	}
}
func (s *C1002Down)ToBuffer() *link.OutBufferBE {
	p := new(link.OutBufferBE)
	p.WriteUint16(1002) //写入协议号
	s.PackInTo(p)
	return p
}
