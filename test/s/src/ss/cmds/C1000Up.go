package cmds

import (
	"github.com/funny/link"
)

type C1000Up struct {
	a1  int8    //8，1
	a2  int16   //16，2
	a3  int32   //32，3
	a4  int64   //64，4
	a5  string  //String，5
	a6  float32 //f32，6
	a7  float64 //f64，7
	a8  uint8   //u8，8
	a9  uint16  //u16，9
	a10 uint32  //u32，0
	a11 uint64  //u64，11
}

func f1000Up(c uint16, b *link.InBufferBE, u *link.Session) *link.OutBufferBE {
	s := new(C1000Up)
	p := *b
	s.a1 = p.ReadInt8()                      //1
	s.a2 = p.ReadInt16()                     //2
	s.a3 = p.ReadInt32()                     //3
	s.a4 = p.ReadInt50()                     //4
	s.a5 = p.ReadString(int(p.ReadUint16())) //5
	s.a6 = p.ReadFloat32()                   //6
	s.a7 = p.ReadFloat64()                   //7
	s.a8 = p.ReadUint8()                     //8
	s.a9 = p.ReadUint16()                    //9
	s.a10 = p.ReadUint32()                   //0
	s.a11 = p.ReadUint64()                   //11
	res := new(C1000Down)
	//业务逻辑：
	res.a1 = s.a1
	res.a2 = s.a2
	res.a3 = s.a3
	res.a4 = s.a4
	res.a5 = s.a5
	res.a6 = s.a6
	res.a7 = s.a7
	res.a8 = s.a8
	res.a9 = s.a9
	res.a10 = s.a10
	res.a11 = s.a11
	return res.ToBuffer()
}
