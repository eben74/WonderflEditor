package net.wonderfl.editor 
{
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	import net.wonderfl.editor.core.TextHScroll;
	import net.wonderfl.editor.core.TextVScroll;
	import net.wonderfl.editor.core.UIComponent;
	import net.wonderfl.editor.core.UIFTETextField;
	import net.wonderfl.editor.utils.calcFontBox;
	/**
	 * ...
	 * @author kobayashi-taro
	 */
	public class UIFTETextFieldComponent extends UIComponent implements IEditor
	{
		private var changeRevalIID:int;
		private var _field:UIFTETextField;
		private var lineNums:LineNumberField;
		private var _vScroll:TextVScroll;
		private var _hScroll:TextHScroll;
		private var _boxWidth:int;
		
		public function UIFTETextFieldComponent() 
		{
			_field = new UIFTETextField;
			addChild(_field);
			
			_boxWidth = calcFontBox(_field.defaultTextFormat).width;
			
			
			addEventListener(FocusEvent.FOCUS_IN, function(e:FocusEvent):void {
				stage.focus = _field;
			});
			
			addEventListener(FocusEvent.KEY_FOCUS_CHANGE, function(e:Event):void {
				e.preventDefault();
			});
			
			_field.addEventListener(Event.SCROLL, onTextScroll);
			
			lineNums = new LineNumberField(_field);
			addChild(lineNums);
			lineNums.addEventListener(MouseEvent.MOUSE_DOWN, function(e:MouseEvent):void {
				_field.onMouseDown(e);
				stage.addEventListener(MouseEvent.MOUSE_UP, numStageMouseUp);
			});
			lineNums.addEventListener(Event.RESIZE, function ():void {
				_field.x = lineNums.width;
				_field.width = _width - lineNums.width;
			});
			
			_vScroll = new TextVScroll(_field);
			_hScroll = new TextHScroll(_field);
			_hScroll.addEventListener(Event.SCROLL, onHScroll);
			addChild(_vScroll);
			addChild(_hScroll);
		}
		
		private function onHScroll(e:Event):void 
		{
			trace('on h scroll : ' + _hScroll.value);
			_field.scrollH = _hScroll.value;
//			_field.x = lineNums.width - _hScroll.value * _boxWidth;
		}
		
		private function onTextScroll(e:Event):void 
		{
			_hScroll.setThumbPercent(_width / _field.maxWidth);
			_hScroll.setSliderParams(1, _field.width / _boxWidth, _hScroll.value);
		}
		
		private function numStageMouseUp(e:Event):void
		{
			stage.focus = _field;
			stage.removeEventListener(MouseEvent.MOUSE_UP, numStageMouseUp);
		}
		
		override protected function updateSize():void 
		{
			_field.height = _height - _hScroll.height;
			_vScroll.height = _height;
			_hScroll.width = _width;
			_vScroll.x = _width - _vScroll.width;
			_hScroll.y = _field.height;
			lineNums.height = _field.height;
		}
		
		public function applyFormatRuns():void
		{
			_field.applyFormatRuns();
		}
		
		public function addFormatRun(beginIndex:int, endIndex:int, bold:Boolean, italic:Boolean, color:String):void
		{
			_field.addFormatRun(beginIndex, endIndex, bold, italic, color);
		}
		
		public function set scrollY(value:int):void {
			_field.scrollY = value;
		}
		
		public function set scrollH(value:int):void {
			
		}
		
		public function clearFormatRuns():void
		{
			_field.clearFormatRuns();
		}
		
		public function setSelection($selectionBeginIndex:int, $selectionEndIndex:int):void {
			_field.setSelection($selectionBeginIndex, $selectionEndIndex);
		}
		
		public function get text():String {
			return _field.text;
		}
		
		public function set text(value:String):void {
			_field.text = value;
		}
		
	}

}