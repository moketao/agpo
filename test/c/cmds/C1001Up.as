package cmds{
import com.moketao.socket.*;
	/** 写配置 **/
	public class C1001Up implements ISocketUp{
		public var txt:String;  //String，配置内容
		public var dir:String;  //String，目录
		public var name:String; //String，配置文件名
		/** 写配置 **/
		public function C1001Up(){}
		public function PackInTo(b:CustomByteArray):void{
			b.writeUTF(txt);  //String（配置内容）
			b.writeUTF(dir);  //String（目录）
			b.writeUTF(name); //String（配置文件名）
		}
	}
}
