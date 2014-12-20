package cmds{
import com.moketao.socket.ISocketDown;
import com.moketao.socket.CustomByteArray;
	/** 数组测试 **/
	public class C1002Down implements ISocketDown
	{
		public var arr:Array=[]; //Array，[8]
		/** 数组测试 **/
		public function C1002Down(){}
		public function UnPackFrom(b:CustomByteArray):*{
			var len:int = b.ReadUint16();//读取数组长度，（[8]）
			for (var i:int = 0; i < len; i++){
				arr.push(b.ReadInt8());
			}
			return this;
		}
	}
}