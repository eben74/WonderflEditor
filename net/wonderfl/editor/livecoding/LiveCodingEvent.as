package net.wonderfl.editor.livecoding{
    import flash.events.Event;

	public class LiveCodingEvent extends Event {
		public static const JOINED          :String = "LiveCodingEvent_JOINED";
        public static const RELAYED         :String = "LiveCodingEvent_RELAYED";
        public static const MEMBERS_UPDATED :String = "LiveCodingEvent_MEMBERS_UPDATED";
        public static const ERROR           :String = "LiveCodingEvent_ERROR";
        public var data :Object;

		public function LiveCodingEvent( _type :String, _data :Object ){
            data = _data;
			super( _type, true );
		}

		public override function clone():Event {
			return new LiveCodingEvent( type, data );
		}
	}
}
