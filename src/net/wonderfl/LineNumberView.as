﻿package net.wonderfl 
{
import flash.text.TextLineMetrics;
import jp.psyark.psycode.controls.UIControl;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.events.Event;
import jp.psyark.psycode.core.TextEditUI;
import jp.psyark.psycode.core.psycode_internal;
/**
 * @author kobayashi-taro
 */
public class LineNumberView extends UIControl
{
	private var _textFieldCache:Array = [];
	private var _linePosCache:Array = [];
	private var _target:TextEditUI;
	private var _bottomScrollV:int = -1;
	private var _defaultTextFormat:TextFormat;
	private var _lastLineIndex:int = -1;
	
	public function LineNumberView(target:TextEditUI) 
	{
		_target = target;
		
		mouseChildren = false;
		mouseEnabled = false;
		
		_target.addEventListener(Event.CHANGE, updateView);
		_target.addEventListener(Event.SCROLL, updateView);
	}
	
	private function get maxWidth():int {
		return getTextField(_target.lastLineIndex).width;
	}
	
	public function updateLinePos($force:Boolean = false):void {
		var lli:int = _target.lastLineIndex;
		var bsv:int = _target.textField.bottomScrollV;
		
		if (!$force && _lastLineIndex == lli && _bottomScrollV == bsv)
			return;
		
		_lastLineIndex = lli;
		_bottomScrollV = bsv;
		var tlm:TextLineMetrics;
		var yPos:Number = 0;
		var tf:TextField;
		_linePosCache.length = 0;
		
		
		for (var i:int = 0; i <= lli; ++i) {
			tlm = _target.textField.getLineMetrics(i);
			_linePosCache[i] = yPos;
			yPos += tlm.height;
		}
		
		i = 0;
		while (i <= lli) {
			tf = getTextField(i);
			tf.y = _linePosCache[i];
			tf.x = maxWidth - tf.width;
			
			addChild(tf);
			
			++i;
		}
		
		var len:int = _textFieldCache.length;
		while (i < len) {
			tf = _textFieldCache[i];
			if (tf.parent) removeChild(tf);
			++i;
		}
		
		width = maxWidth + 4;
		y = -_linePosCache[_target.scrollV - 1];
	}
	
	public function getLinePos(i:int):Number {
		return _linePosCache[i];
	}
	
	
	public function setTextFormat(format:TextFormat, beginIndex:int=-1, endIndex:int=-1):void {
		_defaultTextFormat = format;
		
		updateView(null);
	}
	
	private function getTextField(i:int):TextField {
		var tf:TextField = _textFieldCache[i]
		
		if (tf == null) {
			tf = new TextField;
			tf.text = '' + (i + 1);
			tf.setTextFormat(_defaultTextFormat);
			tf.width = tf.textWidth + 4;
			tf.height = tf.textHeight + 4;
			tf.selectable = false;
			tf.mouseEnabled = false;
			tf.mouseWheelEnabled = false;
			_textFieldCache[i] = tf;
		}
		
		return tf;
	}
	
	public function updateView(event:Event):void {
		updateLinePos();
		
		dispatchEvent(new Event(Event.RESIZE));
	}
}
}