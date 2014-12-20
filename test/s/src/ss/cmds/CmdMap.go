package cmds

import (
	_ "fmt"
	"github.com/funny/link"
	"reflect"
)

type ACMD struct {
	Code uint16                                                          //协议号
	Func func(uint16, *link.InBufferBE, *link.Session) *link.OutBufferBE //协议号对应函数
}

var DIC map[uint16]ACMD = map[uint16]ACMD{} //以字典形式存在的协议
var CMD CmdStuct                            //以结构形式存在的协议

type CmdStuct struct {
	//moeditor struct start
	C1000up ACMD
	C1002up ACMD
	//moeditor struct end
}

func init() {
	//moeditor init start
	CMD.C1000up = ACMD{1000, f1000Up}
	CMD.C1002up = ACMD{1002, f1002Up}
	//moeditor init end

	//利用reflect解析结构
	v := reflect.ValueOf(CMD)
	for i := 0; i < v.NumField(); i++ {
		value := v.Field(i)
		switch t := value.Interface().(type) {
		case ACMD:
			DIC[t.Code] = t //将协议写到 map 中
		}
	}
}
