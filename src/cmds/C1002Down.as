package cmds{
import com.moketao.socket.ISocketDown;
import com.moketao.socket.CustomByteArray;
	/** 数组测试 **/
	public class C1002Down implements ISocketDown
	{
		public var arr:Array=[]; //Array，[Sub]
		/** 数组测试 **/
		public function C1002Down(){}
		public function UnPackFrom(b:CustomByteArray):*{
			var len:int = b.ReadUint16();//读取数组长度，（[Sub]）
			for (var i:int = 0; i < len; i++){
				var node:Sub = new Sub();
				arr.push(node.UnPackFrom(b));
			}
			return this;
		}
	}
}