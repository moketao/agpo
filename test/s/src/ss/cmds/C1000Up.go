package handle

import (
	. "base"
	"fmt"
)

type C1000Up struct {
	name string  //String，用户名
}

func f1000Up(c uint16, p *Pack, u *Player) []byte {
	s := new(C1000Up)
	s.name = p.ReadString() //用户名
	fmt.Println(s)//需删除，否则影响性能
	res := new (C1000Down)
	//业务逻辑：
	
	return res.ToBytes()
}

