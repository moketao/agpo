package cmds{
import com.moketao.socket.ISocketUp;
import com.moketao.socket.CustomByteArray;
	/** 测试 **/
	public class C1003Up implements ISocketUp
	{
		public var a1:int; //8，a1
		/** 测试 **/
		public function C1003Up(){}
		public function PackInTo(b:CustomByteArray):void{
			b.WriteInt8(a1); //8（a1）
		}
	}
}