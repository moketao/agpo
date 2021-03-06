package common.baseData {

	public final class UInt64 extends Binary64 {
		public final function set high(value:uint):void {
			internalHigh=value
		}

		public final function get high():uint {
			return internalHigh
		}

		public function UInt64(low:uint=0, high:uint=0) {
			super(low, high)
		}

		public function toString(radix:uint=10):String {
			if (radix < 2 || radix > 36) {
				throw new ArgumentError
			}
			if (low == 0 && high == 0) {
				return "0"
			}
			const digitChars:Array=[];
			const copyOfThis:UInt64=new UInt64(low, high);
			do {
				const digit:uint=copyOfThis.div(radix);
				digitChars.push((digit < 10 ? '0' : 'a').charCodeAt() + digit)
			} while (copyOfThis.low != 0 || copyOfThis.high != 0)
			return String.fromCharCode.apply(String, digitChars.reverse())
		}

		public static function parseUInt64(str:String, radix:uint=0):UInt64 {
			var i:uint=0
			if (radix == 0) {
				if (str.search(/^0x/) == 0) {
					radix=16
					i=2
				} else {
					radix=10
				}
			}
			if (radix < 2 || radix > 36) {
				throw new ArgumentError
			}
			str=str.toLowerCase()
			const result:UInt64=new UInt64
			for (; i < str.length; i++) {
				var digit:uint=str.charCodeAt(i)
				if (digit >= '0'.charCodeAt() && digit <= '9'.charCodeAt()) {
					digit-='0'.charCodeAt()
				} else if (digit >= 'a'.charCodeAt() && digit <= 'z'.charCodeAt()) {
					digit-='a'.charCodeAt()
				} else {
					throw new ArgumentError
				}
				if (digit >= radix) {
					throw new ArgumentError
				}
				result.mul(radix)
				result.add(digit)
			}
			return result
		}
	}
}
