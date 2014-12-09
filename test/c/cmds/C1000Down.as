package cmds{
import com.moketao.socket.ISocketDown;
import com.moketao.socket.CustomByteArray;
	/** 登陆 **/
	public class C1000Down implements ISocketDown
	{
		public var ok:int; //8，登陆成功与否
		/** 登陆 **/
		public function C1000Down(){}
		public function UnPackFrom(b:CustomByteArray):*{
			ok = b.ReadInt8();//8（登陆成功与否）
			return this;
		}
	}
}
