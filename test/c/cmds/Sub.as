package cmds{
import com.moketao.socket.ISocketUp;
import com.moketao.socket.ISocketDown;
import com.moketao.socket.CustomByteArray;
	/** sdafadf **/
	public class Sub implements ISocketUp,ISocketDown
	{
		public var f1:int; //8，adsfsadf


		/** sdafadf **/
		public function Sub(){}
		public function PackInTo(b:CustomByteArray):void{
			b.WriteInt8(f1); //8（adsfsadf）
		}
		public function UnPackFrom(b:CustomByteArray):*{
			f1 = b.ReadInt8(); //8（adsfsadf）
			return this;
		}
	}
}