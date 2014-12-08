package cmds {
	import flash.utils.Dictionary;

	public class CmdMap {
		private static var _instance:CommandMap=null;
		public var _CMDDic:Dictionary;
		public function CmdMap() {
			_CMDDic=new Dictionary();
			configCMD();
		}

		public static function getInstance():CommandMap {
			if (_instance == null) {
				_instance=new CommandMap();
			}
			return _instance;
		}

		private function configCMD():void {
			//dicStart
			_CMDDic[1000]=C1000Down;
			_CMDDic[1001]=C1001Down;
			//dicEnd
		}

		public static function getCmdOB(cmd:int):* {
			var a_class:Class = _instance._CMDDic[cmd];
			if(a_class==null)return null;
			return new a_class();
		}
	}
}

