package cmds{
import com.moketao.socket.ISocketDown;
import com.moketao.socket.CustomByteArray;
	/** 登陆返回 **/
	public class C1000Down implements ISocketDown
	{
		public var name:String; //String，原样返回名字
		public var ff:Number;   //64，ff
		/** 登陆返回 **/
		public function C1000Down(){}
		public function UnPackFrom(b:CustomByteArray):*{
			name = b.readUTF();//String（原样返回名字）
			ff = b.ReadInt64();//64（ff）
			return this;
		}
	}
}