package com.moketao.socket {
	import flash.utils.ByteArray;
	import flash.utils.Endian;

	public class CustomByteArray extends ByteArray {
		public function CustomByteArray() {
			super();
			this.endian=Endian.BIG_ENDIAN;
		}

		/**
		 * 读Int8
		 */
		public function ReadInt8():int {
			return int(this.readByte());
		}

		/**
		 * 读Int8
		 */
		public function ReadUint8():int {
			return uint(this.readByte());
		}

		/**
		 * 读Int16
		 */
		public function ReadInt16():int {
			return this.readShort();
		}

		/**
		 * 读IntU16
		 */
		public function ReadUint16():int {
			return uint(this.readShort());
		}

		/**
		 * 读Int32
		 */
		public function ReadInt32():int {
			return this.readInt();
		}

		/**
		 * 读Int32
		 */
		public function ReadUint32():uint {
			return this.readUnsignedInt();
		}

		/**
		 * 读Int64 ，实际上不到64位，最大的一个字节位用来放负号，极限值：-8999999999999999 到 +8999999999999999
		 */
		public function ReadInt64():Number {
			var str:String="";
			var firstByte:uint = this.readUnsignedByte();
			
			var fu:int = firstByte==0?-1:1;//首个字节用来决定正数或负数
			
			var end:Number = this.position + 7;//7个字节
			for (var i:int=this.position; i < end; i++) {
				var byte:uint=this[i] as uint;
				var s:String=byte.toString(2);
				s=("00000000" + s).substr(-8);
				str+=s;
			}
			this.position+=7;
			var res:Number = parseInt(str,2)*fu;
			return res;
		}

		public static const n7:Number=Math.pow(256, 7);
		public static const n6:Number=Math.pow(256, 6);
		public static const n5:Number=Math.pow(256, 5);
		public static const n4:Number=Math.pow(256, 4);
		public static const n3:Number=Math.pow(256, 3);
		public static const n2:Number=Math.pow(256, 2);
		public static const n1:Number=Math.pow(256, 1);

		/**
		 * 读Uint64 ，极限值：8999999999999999
		 */
		public function ReadUint64():Number {
			var number:Number=0;//as3实在太挫了，不能位移超过32位，这里只能用乘法
			number =this.readUnsignedByte()*n7;
			number+=this.readUnsignedByte()*n6;
			number+=this.readUnsignedByte()*n5;
			number+=this.readUnsignedByte()*n4;
			number+=this.readUnsignedByte()*n3;
			number+=this.readUnsignedByte()*n2;
			number+=this.readUnsignedByte()*n1;
			number+=this.readUnsignedByte()* 1;
			return number;
		}
		
		//////////////////////////////////////////////////以上读↑，以下写↓
		
		/**
		 * 写Int8
		 */
		public function WriteInt8(value:int):void {
			this.writeByte(value);
		}

		/**
		 * 写Uint8
		 */
		public function WriteUint8(value:int):void {
			this.writeByte(value);
		}

		/**
		 * 写Int16
		 */
		public function WriteInt16(value:int):void {
			this.writeShort(value);
		}

		/**
		 * 写Uint16
		 */
		public function WriteUint16(value:int):void {
			this.writeShort(value);
		}

		/**
		 *  写Int32
		 */
		public function WriteInt32(value:int):void {
			this.writeInt(value);
		}

		/**
		 *  写Int32
		 */
		public function WriteUint32(value:uint):void {
			this.writeUnsignedInt(value);
		}

		public static const zeroU64:String  = "0000000000000000000000000000000000000000000000000000000000000000";
		
		/**
		 * 写Int64 正数极限 8999999999999999，负数极限 -8999999999999999
		 */
		public function WriteInt64(v:Number):void {
			var s:String;
			var fu:Boolean;			//负数符号
			if(v<0){
				fu = true;
				v = v*-1;			//负数乘以-1，去掉符号，取正数部分
			}
			s = v.toString(2);	//如果是正数，自然直接用正数去存储，无需乘以-1
			if(fu){
				s="00000000"+(zeroU64 + s).substr(-56);//00000000代表负数
			}else{
				s="00000001"+(zeroU64 + s).substr(-56);//00000001代表正数
			}
			for (var i:int=0; i < 8; i++) {
				this.writeByte(parseInt(s.substr(i * 8, 8), 2));
			}
		}
		
		/**
		 * 写Uint64，8999999999999999 （8后面跟着15个9）是一个接近极限是值，再大就危险了，可以用trace(8999999999999999+2)测试，会出错，少一位
		 */
		public function WriteUint64(value:Number):void {
			var s:String=value.toString(2);
			s=(zeroU64 + s).substr(-64);
			for (var i:int=0; i < 8; i++) {
				this.writeByte(parseInt(s.substr(i * 8, 8), 2));
			}
		}

		public function traceBytes(desc:String=""):void {
			var pos:uint = this.position;
			this.position = 0;
			var out:String=desc+"[ ";
			for (var i:int=0; i < this.length; i++) {
				var byte:uint=this[i] as uint;
				var s:String=byte.toString(2);
				s=("00000000" + s).substr(-8) + " ";
				out+=s;
			}
			out+="]";
			this.position=pos;
			trace(out);
		}
	}
}
