package cmds{
import com.moketao.socket.*;
	/** 写配置 **/
	public class C1001Down implements ISocketDown{
		public var ok:int; //8，成功与否
		/** 写配置 **/
		public function C1001Down(){}
		public function UnPackFrom(b:CustomByteArray):*{
			ok = b.ReadInt8();//8（成功与否）
			return this;
		}
	}
}
