package {
	import flash.net.SharedObject;
	
	public class G {
		public static function SO(key:String, val:*=null):*
		{
			var so:SharedObject = SharedObject.getLocal("agpo");
			if(val!=null) so.data[key] = val;
			return so.data[key];
		}
		public function G() {
		}
	}
}
