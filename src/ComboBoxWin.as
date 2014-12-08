package
{
	import com.bit101.components.ComboBox;
	import com.bit101.components.HBox;
	import com.bit101.components.InputText;
	import com.bit101.components.PushButton;
	import com.bit101.components.VBox;
	import com.bit101.components.Window;
	
	import flash.display.DisplayObjectContainer;
	import flash.net.SharedObject;
	
	import mycom.Alert;
	
	public class ComboBoxWin extends Window
	{
		private var tmp:Array;
		private var groupName:String;

		private var box:ComboBox;

		private var txt_add:InputText;

		private var OKFunc:Function;
		public function ComboBoxWin(parent:DisplayObjectContainer=null,title:String="Window",groupName:String="projects",OKFunc:Function=null)
		{
			super(parent, 222, 122, title);
			this.OKFunc = OKFunc;
			this.groupName = groupName;
			setSize(400,90);
			var body:VBox = new VBox(this,5,5);
			
			tmp = SO(groupName);
			if(tmp==null) tmp = [];
			
			var menu:HBox = new HBox(body);
			box = new ComboBox(menu,0,0,"",tmp);
			box.selectedIndex = 0;
			
			var last:* = SO(groupName+"_last");
			if(last!=null && last!=""){
				var index:int = box.items.indexOf(last);
				if(index>=0){
					box.selectedIndex = index;
				}
			}
			
			box.numVisibleItems = tmp.length+1;
			var btn_del:PushButton = new PushButton(menu,0,0,"del",del);btn_del.width = 35;
			txt_add = new InputText(menu);
			var btn_add:PushButton = new PushButton(menu,0,0,"add",add);btn_add.width = 35;
			new PushButton(this,150,40,"确定",onOK);
		}
		public function del(e:*):void
		{
			if(box.selectedItem){
				var ob:* = box.items.splice(box.selectedIndex,1);
				box.selectedIndex = 0;
				box.draw();
				trace("del",ob);
			}else{
				Alert.show("请选择左边的下拉选项后，再点击删除");
			}
		}
		public function add(e:*):void
		{
			if(box.items.indexOf(txt_add.text)<0){
				box.items.push(txt_add.text);
				box.selectedItem = txt_add.text;
				box.draw();
				trace("add",txt_add.text);
			}else{
				Alert.show("已经存在，不能添加");
			}
		}
		private function onOK(e:*):void{
			var arr:Array = SO(groupName);
			if(arr==null)arr=[];
			var isSame:Boolean = true;
			if(arr.length!=tmp.length) isSame=false;
			if(isSame){
				for (var i:int = 0; i < arr.length; i++) {
					if(arr[i]!=tmp[i]){
						isSame = false;
						break;
					}
				}
			}
			trace(isSame,tmp);
			var item:Object = box.selectedItem;
			if(item!="" && item!=null){
				SO(groupName,tmp);
				SO(groupName+"_last",item);
				if(OKFunc!=null){
					OKFunc(item);
					parent.removeChild(this);
				}
			}else{
				Alert.show("请选择一个有效值");
			}
		}
		public static function SO(key:String, val:*=null):*
		{
			var so:SharedObject = SharedObject.getLocal("agpo");
			if(val!=null) so.data[key] = val;
			return so.data[key];
		}
	}
}