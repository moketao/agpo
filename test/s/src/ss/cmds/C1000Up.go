package cmds

import (
	"github.com/funny/link"
)

type C1000Up struct {
	name string //String，名字
	ff   int64  //64，ff
}

func f1000Up(c uint16, b *link.InBuffer, u *link.Session) *link.OutBufferBE {
	s := new(C1000Up)
	p := *b
	s.name = p.ReadString(int(p.ReadUint16())) //名字
	s.ff = p.ReadInt50()                       //ff
	res := new(C1000Down)
	//业务逻辑：
	res.ff = s.ff
	res.name = s.name

	return res.ToBuffer()
}
