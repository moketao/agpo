package cmds

import (
	"github.com/funny/link"
)

type C1002Up struct {
	arr []Sub //Array，[Sub]
}

func f1002Up(c uint16, b *link.InBuffer, u *link.Session) *link.OutBufferBE {
	s := new(C1002Up)
	p := *b
	count := int(p.ReadUint16()) //数组长度（[Sub]）
	for i := 0; i < count; i++ {
		node := new(Sub)
		s.arr = append(s.arr, node.UnPackFrom(b))
	}
	res := new(C1002Down)
	//业务逻辑：
	res.arr = s.arr

	return res.ToBuffer()
}
