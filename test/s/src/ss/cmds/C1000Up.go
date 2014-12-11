package cmds

import (
	"fmt"
	"github.com/funny/link"
)

type C1000Up struct {
	name string //String，用户名
}

func f1000Up(c uint16, b *link.InBuffer, u *link.Session) *link.OutBufferBE {

	s := new(C1000Up)

	strLen := int((*b).ReadUint16())
	fmt.Println("strLen ", strLen)
	fmt.Println("len", (*b).Len())
	s.name = (*b).ReadString(strLen) //用户名
	fmt.Println("s.name", s.name)
	fmt.Println(c, "up协议收到", s) //需删除，否则影响性能
	res := new(C1000Down)
	//业务逻辑：
	res.ok = 1
	return res.ToBytes()
}
