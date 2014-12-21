package cmds{
import com.moketao.socket.ISocketUp;
import com.moketao.socket.CustomByteArray;
	/** 数组测试 **/
	public class C1002Up implements ISocketUp
	{
		public var arr:Array=[]; //Array，[Sub]
		/** 数组测试 **/
		public function C1002Up(){}
		public function PackInTo(b:CustomByteArray):void{
			b.WriteUint16(arr.length);          //写入数组长度，（[Sub]）
			for(var i:int=0;i<arr.length;i++){ 
				arr[i].PackInTo(b);
			}
		}
	}
}