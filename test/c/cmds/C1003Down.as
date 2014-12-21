package cmds{
import com.moketao.socket.ISocketDown;
import com.moketao.socket.CustomByteArray;
	/** 测试 **/
	public class C1003Down implements ISocketDown
	{
		public var a1:int; //8，a1
		/** 测试 **/
		public function C1003Down(){}
		public function UnPackFrom(b:CustomByteArray):*{
			a1 = b.ReadInt8();//8（a1）
			return this;
		}
	}
}