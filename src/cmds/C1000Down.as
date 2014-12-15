package cmds{
import com.moketao.socket.ISocketDown;
import com.moketao.socket.CustomByteArray;
	/** 登陆返回 **/
	public class C1000Down implements ISocketDown
	{
		public var a1:int;     //8，1
		public var a2:int;     //16，2
		public var a3:int;     //32，3
		public var a4:Number;  //64，4
		public var a5:String;  //String，5
		public var a6:Number;  //f32，6
		public var a7:Number;  //f64，7
		public var a8:int;     //u8，8
		public var a9:int;     //u16，9
		public var a10:uint;   //u32，0
		public var a11:Number; //u64，11
		/** 登陆返回 **/
		public function C1000Down(){}
		public function UnPackFrom(b:CustomByteArray):*{
			a1 = b.ReadInt8();//8（1）
			a2 = b.ReadInt16();//16（2）
			a3 = b.ReadInt32();//32（3）
			a4 = b.ReadInt64();//64（4）
			a5 = b.readUTF();//String（5）
			a6 = b.readFloat();//f32（6）
			a7 = b.readDouble();//f64（7）
			a8 = b.ReadUint8();//u8（8）
			a9 = b.ReadUint16();//u16（9）
			a10 = b.ReadUint32();//u32（0）
			a11 = b.ReadUint64();//u64（11）
			return this;
		}
	}
}