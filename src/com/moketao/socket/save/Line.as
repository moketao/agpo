package com.moketao.socket.save {
	/*
	* 一行数据  【类型】 【数值】 【删除】
	*/
	import com.bit101.components.ComboBox;
	import com.bit101.components.HBox;
	import com.bit101.components.InputText;
	import com.bit101.components.Label;
	import com.bit101.components.PushButton;
	
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.utils.describeType;
	import flash.utils.getDefinitionByName;
	import flash.utils.setTimeout;
	
	import mycom.Alert;

	public class Line extends HBox {
		public static var TYPES:Array=["8", "16", "32", "64", "String", "f32", "f64", "u8", "u16", "u32", "u64", "Array"];

		public function Line(parent:DisplayObjectContainer=null, xpos:Number=0, ypos:Number=0,ob:Object=null):void {
			super(parent, xpos, ypos);
			dropDown=new ComboBox(this, 0, 0, "Type", TYPES); dropDown.numVisibleItems = TYPES.length; 
			setTimeout(function():void{
				dropDown.addEventListener(Event.SELECT,onSelect);
			},2);

			var tname_label:Label=new Label(this, 0, 0, "tname");
			tname_label.height=20;
			tname=new InputText(this);
			tname.height=20;

			var desc_label:Label=new Label(this, 0, 0, "desc");
			tname_label.height=20;
			desc=new InputText(this);
			desc.height=20;

			var val_label:Label=new Label(this, 0, 0, "val");
			val_label.height=20;
			val=new InputText(this);
			val.height=20;
			
			var del:PushButton=new PushButton(this, 0, 0, "Delete", click_del);
			
			if(ob!=null){
				dropDown.selectedItem = ob.type;
				tname.text = ob.name;
				desc.text = ob.desc;
				if(ob.val)val.text = ob.val;
			}
		}
		
		protected function onSelect(e:Event):void
		{
			if(dropDown.selectedItem=="Array"){
				Alert.show("Array类型，需要在 desc字段里加入子类的类名，格式如下：\n[SubClassName]\n[u8]\n[String]");
			}
		}
		
		public var dropDown:ComboBox;
		public var val:InputText;
		public var desc:InputText;
		public var tname:InputText;
		private var _value:Object;

		public function get value():Object
		{
			var i:String = dropDown.selectedItem as String;
			function v(atype:String,valStr:String):*{
				if(atype=="String") return valStr;
				if(atype=="8" || atype=="16" || atype=="32" || atype=="64" || atype=="64" || atype=="f32" || atype=="f64" || atype=="u8" || atype=="u16" || atype=="u32" || atype=="u64") return parseFloat(valStr);
				return atype;
			}
			if(i=="Array"){
				var arr:Array = val.text.split(",");
				var out:Array = [];
				var p:RegExp = /\[(.*)\]/;
				var subType:String = "String";
				var match:Array = String(desc.text).match(p);
				if(match && match.length>0){
					subType = match[1];
				}
				if(TYPES.indexOf(subType)<0){
					if(val.text=="") return [];
					var obArr:Array = JSON.parse(val.text) as Array;
					var outArr:Array = [];
					for (var k:int = 0; k < obArr.length; k++){
						var aob:Object = obArr[k];
						var aclass:Class = flash.utils.getDefinitionByName("cmds."+subType) as Class;
						var ob:* = new aclass();
						var d:XML = flash.utils.describeType(ob);
						var list:XMLList = d.variable.@name;
						for (var i2:int = 0; i2 < list.length(); i2++){
							var s:String = (list[i2] as XML).toString();
							ob[s] = aob[s];
						}
						outArr.push(ob);
					}
					return outArr;
				}else{
					for (var j:int = 0; j < arr.length; j++){
						out.push(v(subType,arr[j]));
					}
				}
				return out;
			}else{
				return v(i,val.text);
			}
			throw new Error("暂不支持");
			return 0;
		}

		public function getData():LineData {
			var d:LineData=new LineData();
			d.type=getType();
			d.name=tname.text;
			d.desc=desc.text;
			d.val=value;
			return d;
		}
		public function getDataString():LineData {
			var d:LineData=new LineData();
			d.type=getType();
			d.name=tname.text;
			d.desc=desc.text;
			d.val=val.text;
			return d;
		}

		public function getType():String {
			return Line.TYPES[dropDown.selectedIndex];
		}

		public function click_del(e:MouseEvent):void {
			if (parent) {
				parent.removeChild(this);
			}
		}
	}

}
