package cmds{
import com.moketao.socket.*;
	/** 登陆 **/
	public class C1000Down implements ISocketDown{
		public var ok:String; //String，成功与否
		/** 登陆 **/
		public function C1000Down(){}
		public function UnPackFrom(b:CustomByteArray):*{
			ok = b.readUTF();//String（成功与否）
			return this;
		}
	}
}
