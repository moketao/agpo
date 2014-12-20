package cmds{
import com.moketao.socket.ISocketUp;
import com.moketao.socket.ISocketDown;
import com.moketao.socket.CustomByteArray;
	/** sdafadf **/
	public class Sub implements ISocketUp,ISocketDown
	{
		public var s1:int; //8，s1
		public var s2:int; //16，s2


		/** sdafadf **/
		public function Sub(){}
		public function PackInTo(b:CustomByteArray):void{
			b.WriteInt8(s1);  //8（s1）
			b.WriteInt16(s2); //16（s2）
		}
		public function UnPackFrom(b:CustomByteArray):*{
			s1 = b.ReadInt8();  //8（s1）
			s2 = b.ReadInt16(); //16（s2）
			return this;
		}
	}
}