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
	import flash.events.MouseEvent;

	public class Line extends HBox {
		public static var TYPES:Array=["8", "16", "32", "64", "String", "f32", "f64", "u8", "u16", "u32", "u64", "Array"];

		public function Line(parent:DisplayObjectContainer=null, xpos:Number=0, ypos:Number=0,ob:Object=null):void {
			super(parent, xpos, ypos);
			dropDown=new ComboBox(this, 0, 0, "Type", TYPES);

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

		public var dropDown:ComboBox;
		public var val:InputText;
		public var desc:InputText;
		public var tname:InputText;
		private var _value:Object;

		public function get value():Object
		{
			var i:Object = dropDown.selectedItem;
			if(i=="String") return val.text;
			if(i=="8" || i=="16" || i=="32" || i=="64" || i=="64" || i=="f32" || i=="f64" || i=="u8" || i=="u16" || i=="u32" || i=="u64") return parseFloat(val.text);
			throw new Error("暂不支持");
			return 0;
		}

		public function getData():LineData {
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
