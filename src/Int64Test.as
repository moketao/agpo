package
{
	import com.moketao.socket.CustomByteArray;
	
	import flash.display.Sprite;
	
	public class Int64Test extends Sprite
	{
		public function Int64Test()
		{
			var n:Number;
			n = 90000000000000001; //输出 90000000000000000;
			trace(n);//误差1
			n = 8999999999999999; //输出的是 8999999999999999;
			trace(n);//没有误差
			
			var bb:CustomByteArray;
			var k:int = 12;
			
			bb = new CustomByteArray();
			bb.writeInt(k);//正数
			bb.traceBytes("int     "+k.toString()+"  ");
			
			bb = new CustomByteArray();
			bb.writeInt(-k);//负数
			bb.traceBytes("int   - "+k.toString()+"  ");
			
			bb = new CustomByteArray();
			bb.writeInt(~k);//正数取反
			bb.traceBytes("int   ~ "+k.toString()+"  ");
			
			bb = new CustomByteArray();
			bb.writeInt(~k+1);//正数取反再加一得到对应的负数
			bb.traceBytes("int ~+1 "+k.toString()+"  ");
		}
	}
}