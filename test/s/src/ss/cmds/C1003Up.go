package cmds

import (
	"github.com/funny/link"
)

type C1003Up struct {
	a1 int8  //8，a1
}

func f1003Up(c uint16, b *link.InBuffer, u *link.Session) *link.OutBufferBE {
	s := new(C1003Up)
	p := *b
	s.a1 = p.ReadInt8() //a1
	res := new(C1003Down)
	//业务逻辑：
	
	return res.ToBuffer()
}

