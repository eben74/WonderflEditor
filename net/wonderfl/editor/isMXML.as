package net.wonderfl.editor 
{
	public function isMXML(text:String):Boolean {
		return text.search(/<\?xml version="1.0" encoding="utf-8"\?>/) == 0;
	}
}