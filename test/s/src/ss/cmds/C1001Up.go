package handle

import (
	. "base"
	"fmt"
)

type C1001Up struct {
	txt string   //String，配置内容
	dir string   //String，目录
	name string  //String，配置文件名
}

func f1001Up(c uint16, p *Pack, u *Player) []byte {
	s := new(C1001Up)
	s.txt = p.ReadString()  //配置内容
	s.dir = p.ReadString()  //目录
	s.name = p.ReadString() //配置文件名
	fmt.Println(s)//需删除，否则影响性能
	res := new (C1001Down)
	//业务逻辑：
	
	return res.ToBytes()
}

