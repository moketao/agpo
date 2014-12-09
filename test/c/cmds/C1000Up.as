package cmds{
import com.moketao.socket.ISocketUp;
import com.moketao.socket.CustomByteArray;
	/** 登陆 **/
	public class C1000Up implements ISocketUp
	{
		public var name:String; //String，用户名
		/** 登陆 **/
		public function C1000Up(){}
		public function PackInTo(b:CustomByteArray):void{
			b.writeUTF(name); //String（用户名）
		}
	}
}
