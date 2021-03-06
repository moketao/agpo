package com.moketao.socket.save {


	public class ClientDown {
		public static function save(main:AGPO):void {
			var out:String="";
			var fields:String="";
			var packs:String="";
			var unpacks:String="";
			var isNodeClass:Boolean;
			var fileName:String="C" + main.cmd_name.text + "Down"; //文件名
			if (fileName.search(new RegExp(/\d/)) == -1) {
				fileName=main.cmd_name.text; //如果是数组内的 NodeClass 则不需要加 C前缀和 Up后缀
				isNodeClass=true;
			}
			for (var i:int=0; i < main.body.numChildren; i++) {
				var line:Line=main.body.getChildAt(i) as Line;
				var d:LineData=line.getDataString();
				fields+="		public var " + d.name + ":" + toTypeString(d.type) + ";//" + d.type + "，" + d.desc + "\n";
				var nodeClassName:String=getClassName(d.desc);
				if (d.type != "Array") {
					packs+="			" + toWriteFunc(d.type) + "(" + d.name + ");//" + d.type + "（" + d.desc + "）\n";
				} else {
					var len:String=d.name + ".length";
					packs+="			b.WriteUint16(" + len + ");//写入数组长度，（" + d.desc + "）\n";
					packs+="			for(var i:int=0;i<" + len + ";i++){ \n";
					if (isClass(nodeClassName)) {
						packs+="				" + d.name + "[i].PackInTo(b);\n";
					} else {
						packs+="				" + toWriteFunc(nodeClassName) + "(" + d.name + "[i]);\n";
					}
					packs+="			}\n";
				}
				if (d.type != "Array") {
					unpacks+="			" + d.name + " = " + toReadFunc(d.type) + ";//" + d.type + "（" + d.desc + "）\n";
				} else {
					unpacks+="			var len:int = b.ReadUint16();//读取数组长度，（" + d.desc + "）\n";
					unpacks+="			for (var i:int = 0; i < len; i++){\n";
					if (isClass(nodeClassName)) {
						unpacks+="				var node:" + nodeClassName + " = new " + nodeClassName + "();\n";
						unpacks+="				" + d.name + ".push(node.UnPackFrom(b));\n";
					} else {
						unpacks+="				" + d.name + ".push(" + toReadFunc(nodeClassName) + ");\n";
					}
					unpacks+="			}\n";
				}
			}
			if (isNodeClass) {
				fields=CmdFile.fixComment(fields);
				packs=CmdFile.fixComment(packs);
				unpacks=CmdFile.fixComment(unpacks);
				fileName=main.cmd_name.text; //如果是数组内的 NodeClass 则不需要加 C前缀和 Up后缀
				out+="package cmds{\n";
				out+="import com.moketao.socket.ISocketUp;\n";
				out+="import com.moketao.socket.ISocketDown;\n";
				out+="import com.moketao.socket.CustomByteArray;\n";
				out+="	/** " + main.cmd_desc.text + " **/\n";
				out+="	public class " + fileName + " implements ISocketUp,ISocketDown\n";
				out+="	{\n";
				out+=fields + "\n\n";
				out+="		/** " + main.cmd_desc.text + " **/\n";
				out+="		public function PosVO(){}\n";
				out+="		public function PackInTo(b:CustomByteArray):void{\n";
				out+=packs;
				out+="		}\n";
				out+="		public function UnPackFrom(b:CustomByteArray):*{\n";
				out+=unpacks;
				out+="			return this;\n";
				out+="		}\n";
				out+="	}\n";
				out+="}";
				CmdFile.SaveClientCmd(main.pathClient.text + "\\cmds\\" + fileName + ".as", out);
			} else {
				fields=CmdFile.fixComment(fields);
				packs=CmdFile.fixComment(packs);
				out+="package cmds{\n";
				out+="import com.moketao.socket.ISocketDown;\n";
				out+="import com.moketao.socket.CustomByteArray;\n";
				out+="	/** " + main.cmd_desc.text + " **/\n";
				out+="	public class " + fileName + " implements ISocketDown\n";
				out+="	{\n";
				out+=fields;
				out+="		/** " + main.cmd_desc.text + " **/\n";
				out+="		public function " + fileName + "(){}\n"
				out+="		public function UnPackFrom(b:CustomByteArray):*{\n";
				out+=unpacks;
				out+="			return this;\n";
				out+="		}\n";
				out+="	}\n"
				out+="}"

				CmdFile.SaveClientCmd(main.pathClient.text + "\\cmds\\" + fileName + ".as", out);
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

		public static function toTypeString(type:String):String {
			switch (type) {
				case "8":  {
					return "int";
					break;
				}
				case "16":  {
					return "int";
					break;
				}
				case "32":  {
					return "int";
					break;
				}
				case "64":  {
					return "Number";
					break;
				}
				case "f32":  {
					return "Number";
					break;
				}
				case "f64":  {
					return "Number";
					break;
				}
				case "String":  {
					return "String";
					break;
				}
				case "u8":  {
					return "int";
					break;
				}
				case "u16":  {
					return "int";
					break;
				}
				case "u32":  {
					return "uint";
					break;
				}
				case "u64":  {
					return "Number";
					break;
				}
				case "Array":  {
					return "Array=[]";
					break;
				}
			}
			return null;
		}

		public static function toWriteFunc(type:String):String {
			switch (type) {
				case "8":  {
					return "b.WriteInt8";
					break;
				}
				case "16":  {
					return "b.WriteInt16";
					break;
				}
				case "32":  {
					return "b.WriteInt32";
					break;
				}
				case "64":  {
					return "b.WriteInt50";
					break;
				}
				case "f32":  {
					return "b.writeFloat";
					break;
				}
				case "f64":  {
					return "b.writeDouble";
					break;
				}
				case "String":  {
					return "b.writeUTF";
					break;
				}
				case "u8":  {
					return "b.WriteUint8";
					break;
				}
				case "u16":  {
					return "b.WriteUint16";
					break;
				}
				case "u32":  {
					return "b.WriteUint32";
					break;
				}
				case "u64":  {
					return "b.WriteUint64";
					break;
				}
			}
			return null;
		}

		public static function toReadFunc(type:String):String {
			switch (type) {
				case "8":  {
					return "b.ReadInt8()";
					break;
				}
				case "16":  {
					return "b.ReadInt16()";
					break;
				}
				case "32":  {
					return "b.ReadInt32()";
					break;
				}
				case "64":  {
					return "b.ReadInt64()"; //todo:解决正负的问题
					break;
				}
				case "f32":  {
					return "b.readFloat()";
					break;
				}
				case "f64":  {
					return "b.readDouble()";
					break;
				}
				case "String":  {
					return "b.readUTF()";
					break;
				}
				case "u8":  {
					return "b.ReadUint8()";
					break;
				}
				case "u16":  {
					return "b.ReadUint16()";
					break;
				}
				case "u32":  {
					return "b.ReadUint32()";
					break;
				}
				case "u64":  {
					return "b.ReadUint64()";
					break;
				}
			}
			return null;
		}
	}
}
