/* license section

Flash MiniBuilder is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

Flash MiniBuilder is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with Flash MiniBuilder.  If not, see <http://www.gnu.org/licenses/>.


Author: Victor Dramba
2009
*/

/*
 * @Author Dramba Victor
 * 2009
 * 
 * You may use this code any way you like, but please keep this notice in
 * The code is provided "as is" without warranty of any kind.
 */

package net.wonderfl.editor.minibuilder
{
	import __AS3__.vec.Vector;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.utils.ByteArray;
	import flash.utils.getTimer;
	import net.wonderfl.editor.ITextArea;
	import net.wonderfl.utils.isMXML;
	import ro.minibuilder.asparser.Field;
	import ro.minibuilder.asparser.Parser;
	import ro.minibuilder.asparser.TypeDB;
	import ro.minibuilder.main.editor.Location;
	import ro.minibuilder.swcparser.SWFParser;
	import ro.victordramba.thread.ThreadEvent;
	import ro.victordramba.thread.ThreadsController;
	

	[Event(type="flash.events.Event", name="change")]
	[Event(type="flash.events.Event", name="complete")]
	



	public class ASParserController extends EventDispatcher
	{
		CONFIG::editor {
			[Embed(source="../../../../../assets/globals.amf", mimeType="application/octet-stream")]
			private static var GlobalTypesAsset:Class;
			
			[Embed(source="../../../../../assets/playerglobals.amf", mimeType="application/octet-stream")]
			private static var PlayerglobalAsset:Class;
		}
		
		
		
		private var parser:Parser;
		private var t0:Number;		
		static private var tc:ThreadsController;
		
		public var status:String;
		public var percentReady:Number = 0;
		//public var tokenInfo:String;
		//public var scopeInfo:Array/*of String*/
		//public var typeInfo:Array/*of String*/
		
		private var fld:ITextArea;
		
		public function ASParserController(stage:Stage, textField:ITextArea)
		{
			fld = textField;
			//TODO refactor, Controller should probably be a singleton
			if (!tc)
			{
				tc = new ThreadsController(stage);
				
				CONFIG::editor {
					TypeDB.setDB('global', TypeDB.fromByteArray(new GlobalTypesAsset));
					TypeDB.setDB('playerglobal', TypeDB.fromByteArray(new PlayerglobalAsset));
				}
			}
			parser = new Parser;
			
			//parser.addTypeData(TypeDB.formByteArray(new GlobalTypesAsset), 'global');
			//parser.addTypeData(TypeDB.formByteArray(new PlayerglobalAsset), 'player');
			//parser.addTypeData(TypeDB.formByteArray(new ASwingAsset), 'aswing');
			
			
			
			tc.addEventListener(ThreadEvent.THREAD_READY, function(e:ThreadEvent):void
			{
				if (e.thread != parser) return;
				parser.applyFormats(fld);
				//cursorMoved(textField.caretIndex);
				status = 'Parse time: '+ (getTimer()-t0) + 'ms '+parser.tokenCount+' tokens';
				dispatchEvent(new Event('status'));
				dispatchEvent(new Event(Event.COMPLETE));
			});
			
			tc.addEventListener(ThreadEvent.PROGRESS, function(e:ThreadEvent):void
			{
				if (e.thread != parser) return;
				status = '';
				percentReady = parser.percentReady;
				dispatchEvent(new Event('status'));
			});
		}		

		public function saveTypeDB():void
		{
			/*var so:SharedObject = SharedObject.getLocal('ascc-type');
			so.data.typeDB = parser.getTypeData();
			so.flush();*/
			
			//var file:FileReference = new FileReference;
			//var ret:ByteArray = parser.getTypeData();
			//file.save(ret, 'globals.amf');
			
		}
		
		public function slowDownParser():void {
			tc.onUIEvent(null);
		}
		
		public function restoreTypeDB():void
		{
			//throw new Error('restoreTypeDB not supported');
			//var so:SharedObject = SharedObject.getLocal('ascc-type');
			//TypeDB.setDB('restored', so.data.typeDB);
		}
		
		/*public function addTypeDB(typeDB:TypeDB, name:String):void
		{
			parser.addTypeData(typeDB, name);
		}*/
		
		public function loadSWFLib(swfData:ByteArray, fileName:String):void
		{
			TypeDB.setDB(fileName, SWFParser.parse(swfData));
		}
		
		public function sourceChanged(source:String, fileName:String):Boolean
		{
			if (source && source.charAt(0) == "<" && isMXML(source)) {
				dispatchEvent(new Event(Event.COMPLETE));
				return false;
			}
			//source = source.replace(/\n|\r\n/g, '\r');
			
			t0 = getTimer();
			parser.load(source, fileName);
			if (tc.isRunning(parser))
				tc.kill(parser);
			tc.run(parser);
			status = 'Processing ...';
			
			return true;
		}
		
		public function getMemberList(index:int):Vector.<String>
		{
			return parser.newResolver().getMemberList(fld.text, index);
		}
		
		public function getFunctionDetails(index:int):Field
		{
			return parser.newResolver().getFunctionDetails(fld.text, index);
		}
		
		public function getTypeOptions():Vector.<String>
		{
			return parser.newResolver().getAllTypes();
		}
		
		public function getAllOptions(index:int):Vector.<String>
		{
			return parser.newResolver().getAllOptions(index);
		}
		
		public function getMissingImports(name:String, pos:int):Object
		{
			return parser.newResolver().getMissingImports(name, pos);
		}
		
		public function isInScope(name:String, pos:int):Boolean
		{
			return parser.newResolver().isInScope(name, pos);
		}
		
		public function findDefinition(index:int):Location
		{
			var field:Field = parser.newResolver().findDefinition(fld.text, index);
			if (!field) return null;
			debug(field + '-' + field.parent);
			for (var parent:Field = field, i:int=0; parent && i<10; parent = parent.parent, i++)
			{
				debug('def path'+i+': '+parent.sourcePath);
				if (parent.sourcePath)
				{
					debug('found');
					return new Location(parent.sourcePath, field.pos);
				}
			}
			return new Location(null, field.pos);
		}
		
		private function debug(...args):void {
			CONFIG::debug { trace('ASParserController :: ' + args); }
		}
	}
}