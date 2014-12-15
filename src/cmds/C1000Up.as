package cmds{
import com.moketao.socket.ISocketUp;
import com.moketao.socket.CustomByteArray;
	/** 登陆 **/
	public class C1000Up implements ISocketUp
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
		/** 登陆 **/
		public function C1000Up(){}
		public function PackInTo(b:CustomByteArray):void{
			b.WriteInt8(a1);    //8（1）
			b.WriteInt16(a2);   //16（2）
			b.WriteInt32(a3);   //32（3）
			b.WriteInt64(a4);   //64（4）
			b.writeUTF(a5);     //String（5）
			b.writeFloat(a6);   //f32（6）
			b.writeDouble(a7);  //f64（7）
			b.WriteUint8(a8);   //u8（8）
			b.WriteUint16(a9);  //u16（9）
			b.WriteUint32(a10); //u32（0）
			b.WriteUint64(a11); //u64（11）
		}
	}
}