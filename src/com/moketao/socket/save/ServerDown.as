package com.moketao.socket.save {
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;

	public class ServerDown {
		public static function save(main:AGPO):void {
			//CmdMap.go
			
			var mapStr:String = <![CDATA[package cmds {
	import flash.utils.Dictionary;

	public class CmdMap {
		private static var _instance:CmdMap=null;
		public var _CMDDic:Dictionary;
		public function CmdMap() {
			_CMDDic=new Dictionary();
			configCMD();
		}

		public static function getInstance():CmdMap {
			if (_instance == null) {
				_instance=new CmdMap();
			}
			return _instance;
		}

		private function configCMD():void {
			//dicStart
			//dicEnd
		}

		public static function getCmdOB(cmd:int):* {
			var a_class:Class = _instance._CMDDic[cmd];
			if(a_class==null)return null;
			return new a_class();
		}
	}
}

]]>
			
			var filePath:String=main.pathClient.text + "\\cmds\\CmdMap.as";
			var f:File=new File(filePath);
			
			if(!f.exists){
				var ss:FileStream = new FileStream();
				ss.open(f,FileMode.WRITE);
				ss.writeUTFBytes(mapStr);
				ss.close();
			}
			
			var s:FileStream=new FileStream();
			s.open(f, FileMode.READ);
			var out:String="";
			var isNodeClass:Boolean;
			var fileName:String="C" + main.cmd_name.text + "Down"; //文件名
			if (fileName.search(new RegExp(/\d/)) == -1) {
				fileName=main.cmd_name.text; //如果是数组内的 NodeClass 则不需要加 C前缀和 Up后缀
				isNodeClass=true;
			} else {
				//如果是C10000Down格式的，需要注册到 ComandMap.as
				out=s.readUTFBytes(s.bytesAvailable);
				s.close();
				var reg:RegExp;
				var old:String;
				var arr:Array;
				var strWillAdd:String="\t\t\t_CMDDic[" + main.cmd_name.text + "]=C" + main.cmd_name.text + "Down;";
				var strWillAdd_search:String="C" + main.cmd_name.text + "Down;";
				if (out.search(strWillAdd_search) == -1) {
					reg=/\t\t\t\/\/dicStart[\s\S]*dicEnd/m;
					arr=out.match(reg);
					old=String(arr[0]).replace("\t\t\t//dicEnd", "");
					old=old + strWillAdd + "\n\t\t\t//dicEnd";
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
					if(d.type=="String"){
						unpacks+="	p.ReadInt16(int16(len(s." + d.name + ")))\n";
					}
					unpacks+="	p." + toReadFunc(d.type) + "(s." + d.name + ")" + "//" + d.desc + "\n";
				} else {
					unpacks+="	count := int(p.ReadUint16())//数组长度（" + d.desc + "）\n";
					unpacks+="	for i := 0; i < count; i++ {\n";
					if (isClass(nodeClassName)) {
						unpacks+="		node := new(" + nodeClassName + ")\n";
						unpacks+="		s." + d.name + " = append(s." + d.name + ", node.UnPackFrom(p))\n";
					} else {
						unpacks+="		s." + d.name + " = append(s." + d.name + ", " + toReadFunc(nodeClassName) + ")\n";
					}
					unpacks+="	}\n";
				}
				if (d.type != "Array") {
					if(d.type=="String"){
						packs+="	p.WriteInt16(int16(len(s." + d.name + ")))\n";
					}
					packs+="	p." + toWriteFunc(d.type) + "(s." + d.name + ")" + "//" + d.desc + "\n";
				} else {
					packs+="	count := len(s." + d.name + ")//数组长度（" + d.desc + "）\n";
					packs+="	for i := 0; i < count; i++ {\n";
					if (isClass(nodeClassName)) {
						packs+="		s." + d.name + "[i].PackInTo(p)\n";
					} else {
						packs+="		p." + toWriteFunc(nodeClassName) + "(s." + d.name + "[i])\n";
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
				out+="func (s *" + fileName + ") UnPackFrom(p *link.InBufferBE ) " + fileName + " {\n";
				out+=unpacks;
				out+="	return *s\n";
				out+="}\n\n";
				out+="func (s *" + fileName + ") PackInTo(p *link.OutBufferBE ) {\n";
				out+=packs;
				out+="}\n\n";
				out+="func (s *"+fileName+")ToBuffer() *link.OutBufferBE {\n";
				out+="	p := new(link.OutBufferBE)\n";
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
				out+="type C" + main.cmd_name.text + "Down struct {\n";
				out+=fields;
				out+="}\n\n";
				out+="func (s *C"+main.cmd_name.text+"Down)PackInTo(p *link.OutBufferBE ) {\n";
				out+=packs;
				out+="}\n";
				out+="func (s *C"+main.cmd_name.text+"Down)ToBuffer() *link.OutBufferBE {\n";
				out+="	p := new(link.OutBufferBE)\n";
				out+="	p.WriteUint16("+main.cmd_name.text+") //写入协议号\n";
				out+="	s.PackInTo(p)\n";
				out+="	return p\n";
				out+="}\n";

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
					return "WriteInt50";//不是真的64位，只写入50位左右，最高位用来表达符号，as3的Number支持不了那么多位的正整数，超过8999999999999999精确度就不够了
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
