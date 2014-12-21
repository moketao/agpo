package com.moketao.socket.save {
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;

	public class ServerUp {
		public static function save(main:AGPO):void {
			var handleStr:String = <![CDATA[package cmds

import (
	_ "fmt"
	"github.com/funny/link"
	"reflect"
)

type ACMD struct {
	Code uint16                                                        //协议号
	Func func(uint16, *link.InBuffer, *link.Session) *link.OutBufferBE //协议号对应函数
}

var DIC map[uint16]ACMD = map[uint16]ACMD{} //以字典形式存在的协议
var CMD CmdStuct                            //以结构形式存在的协议

type CmdStuct struct {
	//moeditor struct start
	//moeditor struct end
}

func init() {
	//moeditor init start
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
]]>;
			var fileDIR:String=main.pathServer.text + "\\cmds\\";
			var fDIR:File=new File(fileDIR);
			if(!fDIR.exists) fDIR.createDirectory();
				
			var filePath:String=main.pathServer.text + "\\cmds\\CmdMap.go";
			var f:File=new File(filePath);

			if(!f.exists){
				var fs:FileStream = new FileStream();
				fs.open(f,FileMode.WRITE);
				fs.writeUTFBytes(handleStr);
				fs.close();
			}
			
			var s:FileStream=new FileStream();
			s.open(f, FileMode.READ);

			var isNodeClass:Boolean;
			var fileName:String="C" + main.cmd_name.text + "Up"; //文件名
			if (fileName.search(new RegExp(/\d/)) == -1) {
				fileName=main.cmd_name.text; //如果是数组内的 NodeClass 则不需要加 C前缀和 Up后缀
				isNodeClass=true;
			} else {
				//如果是C10000Up格式的，需要注册到 CmdMap.go
				var out:String=s.readUTFBytes(s.bytesAvailable);
				s.close();
				var reg:RegExp;
				var old:String;
				var arr:Array;
				var strWillAdd:String="\tCMD.C" + main.cmd_name.text + "up = ACMD{" + main.cmd_name.text + ", f" + main.cmd_name.text + "Up}";
				if (out.search(strWillAdd) == -1) {
					reg=/\t\/\/moeditor struct start[\s\S]*moeditor struct end/m;
					arr=out.match(reg);
					old=String(arr[0]).replace("\t//moeditor struct end", "");
					old=old + "\tC" + main.cmd_name.text + "up ACMD" + "\n\t//moeditor struct end";
					out=out.replace(reg, old);

					reg=/\t\/\/moeditor init start[\s\S]*moeditor init end/m;
					arr=out.match(reg);
					old=String(arr[0]).replace("\t//moeditor init end", "");
					old=old + strWillAdd + "\n\t//moeditor init end";
					out=out.replace(reg, old);

					CmdFile.SaveClientCmd(filePath, out);
				}
			}

			out="";
			var fields:String="";
			var unpacks:String="";
			var packs:String="";
			for (var i:int=0; i < main.body.numChildren; i++) {
				var line:Line=main.body.getChildAt(i) as Line;
				var d:LineData=line.getData();
				var nodeClassName:String=getClassName(d.desc);
				fields+="	" + d.name + " " + toTypeString(d.type, nodeClassName) + " //" + d.type + "，" + d.desc + "\n";
				if (d.type != "Array") {
					unpacks+="	s." + d.name+" = " + toReadFunc(d.type) + "//" + d.desc + "\n";
				} else {
					unpacks+="	count := int(p.ReadUint16())//数组长度（" + d.desc + "）\n";
					unpacks+="	for i := 0; i < count; i++ {\n";
					if (isClass(nodeClassName)) {
						unpacks+="		node := new(" + nodeClassName + ")\n";
						unpacks+="		s." + d.name + " = append(s." + d.name + ", node.UnPackFrom(b))\n";
					} else {
						unpacks+="		s." + d.name + " = append(s." + d.name + ", " + toReadFunc(nodeClassName) + ")\n";
					}
					unpacks+="	}\n";
				}
				if (d.type != "Array") {
					if(d.type=="String"){
						packs+="	p.WriteInt16(int(len(s." + d.name + ")))\n";
					}
					packs+="	p." + toWriteFunc(d.type) + "(s." + d.name + ")" + "//" + d.desc + "\n";
				} else {
					packs+="	count := len(s." + d.name + ")//数组长度（" + d.desc + "）\n";
					packs+="	for i := 0; i < count; i++ {\n";
					if (isClass(nodeClassName)) {
						packs+="		s." + d.name + "[i].PackInTo(&p)\n";
					} else {
						packs+="		" + toWriteFunc(nodeClassName) + "(s." + d.name + "[i])\n";
					}
					packs+="	}\n";
				}
			}
			if (isNodeClass) {
				fields=CmdFile.fixComment(fields);
				packs=CmdFile.fixComment(packs);
				unpacks=CmdFile.fixComment(unpacks);
				out+="package cmds\n\n";
				out+="import (\n";
				out+='	"github.com/funny/link"\n';
				out+=")\n\n";
				out+="type " + fileName + " struct {\n";
				out+=fields;
				out+="}\n\n";
				out+="func (s *" + fileName + ") UnPackFrom(b *link.InBuffer) " + fileName + " {\n";
				out+="	p := *b\n";
				out+=unpacks;
				out+="	return *s\n";
				out+="}\n\n";
				out+="func (s *" + fileName + ") PackInTo(p *link.OutBufferBE) {\n";
				//out+="	p := *b\n";
				out+=packs;
				out+="}\n\n";
				out+="func (s *"+fileName+")ToBuffer(cmdID uint16) *link.OutBufferBE {\n";
				out+="	p := new(link.OutBufferBE)\n";
				out+="	(*p).WriteUint16(cmdID) //写入协议号\n";
				out+="	s.PackInTo(p)\n";
				out+="	return p\n";
				out+="}\n";
				filePath=main.pathServer.text + "\\cmds\\" + fileName + ".go";
				CmdFile.SaveClientCmd(filePath, out);
			} else {
				fields=CmdFile.fixComment(fields);
				unpacks=CmdFile.fixComment(unpacks);
				out+="package cmds\n\n";
				out+="import (\n";
				out+='	"github.com/funny/link"\n';
				out+=")\n\n";
				out+="type C" + main.cmd_name.text + "Up struct {\n";
				out+=fields;
				out+="}\n\n";
				out+="func f" + main.cmd_name.text + "Up(c uint16, b *link.InBuffer, u *link.Session) *link.OutBufferBE {\n";
				out+="	s := new(C" + main.cmd_name.text + "Up)\n";
				out+="	p := *b\n";
				out+=unpacks;
				out+="	res := new(C" + main.cmd_name.text + "Down)\n";
				out+="	//业务逻辑：\n";
				out+="	\n";
				out+="	return res.ToBuffer()\n";
				out+="}\n\n";

				filePath=main.pathServer.text + "\\cmds\\" + fileName + ".go";
				CmdFile.SaveClientCmd(filePath, out);
			}
		}

		private static function getClassName(desc:String):String {
			var reg:RegExp=/\[(\w*)\]/;
			var out:Array=desc.match(reg);
			if (out && out.length >= 1) {
				return out[0].replace("[", "").replace("]", "");
			}
			return "";
		}

		public static function isClass(type:String):Boolean {
			if (type == "8" || type == "16" || type == "32" || type == "64" || type == "u8" || type == "u16" || type == "u32" || type == "u32" || type == "f32" || type == "f64" || type == "String" || type == "Array" || type == "Number") {
				return false;
			}
			return true;
		}

		public static function toTypeString(type:String, ClassInArray:String=""):String {
			switch (type) {
				case "8":  {
					return "int8";
					break;
				}
				case "16":  {
					return "int16";
					break;
				}
				case "32":  {
					return "int32";
					break;
				}
				case "64":  {
					return "int64";
					break;
				}
				case "f32":  {
					return "float32";
					break;
				}
				case "f64":  {
					return "float64";
					break;
				}
				case "String":  {
					return "string";
					break;
				}
				case "u8":  {
					return "uint8";
					break;
				}
				case "u16":  {
					return "uint16";
					break;
				}
				case "u32":  {
					return "uint32";
					break;
				}
				case "u64":  {
					return "uint64";
					break;
				}
				case "Array":  {
					ClassInArray=isClass(ClassInArray) ? ClassInArray : toTypeString(ClassInArray);
					return "[]" + ClassInArray;
					break;
				}
			}
			return null;
		}

		public static function toReadFunc(type:String):String {
			switch (type) {
				case "8":  {
					return "p.ReadInt8()";
					break;
				}
				case "16":  {
					return "p.ReadInt16()";
					break;
				}
				case "32":  {
					return "p.ReadInt32()";
					break;
				}
				case "64":  {
					return "p.ReadInt50()";
					break;
				}
				case "f32":  {
					return "p.ReadFloat32()";
					break;
				}
				case "f64":  {
					return "p.ReadFloat64()";
					break;
				}
				case "String":  {
					return "p.ReadString(int(p.ReadUint16()))";
					break;
				}
				case "u8":  {
					return "p.ReadUint8()";
					break;
				}
				case "u16":  {
					return "p.ReadUint16()";
					break;
				}
				case "u32":  {
					return "p.ReadUint32()";
					break;
				}
				case "u64":  {
					return "p.ReadUint64()";
					break;
				}
			}
			return null;
		}

		public static function toWriteFunc(type:String):String {
			switch (type) {
				case "8":  {
					return "WriteInt8";
					break;
				}
				case "16":  {
					return "WriteInt16";
					break;
				}
				case "32":  {
					return "WriteInt32";
					break;
				}
				case "64":  {
					return "WriteInt50";
					break;
				}
				case "f32":  {
					return "WriteFloat32";
					break;
				}
				case "f64":  {
					return "WriteFloat64";
					break;
				}
				case "String":  {
					return "WriteString";
					break;
				}
				case "u8":  {
					return "WriteUint8";
					break;
				}
				case "u16":  {
					return "WriteUint16";
					break;
				}
				case "u32":  {
					return "WriteUint32";
					break;
				}
				case "u64":  {
					return "WriteUint64";
					break;
				}
			}
			return null;
		}
	}
}
