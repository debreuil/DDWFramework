package DDW.Media 
{
    import DDW.Managers.Sequencer;
    import flash.events.Event;
    public class MediaCommand
    {
        protected const CREATED_STATE:String = "CREATED_STATE";
        protected const PLAYING_STATE:String = "PLAYING_STATE";
        protected const PAUSED_STATE:String = "PAUSED_STATE";
        protected const COMPLETE_STATE:String = "COMPLETE_STATE";
        
        protected var state:String = CREATED_STATE;
        
        protected var disableCursor:Boolean = false;
        //protected var canInterrupt:Boolean;        
        protected var callback:Function;        
        protected var objectToPlay:AssetDescriptor;
        
        public function MediaCommand(objectToPlay:AssetDescriptor, callback:Function = null, disableCursor:Boolean = false) 
        {            
            this.objectToPlay = objectToPlay;
            this.callback = callback;
            this.disableCursor = disableCursor;            
        }
        
        public function get isCreated():Boolean { return state == CREATED_STATE;    }
        public function get isPlaying():Boolean { return state == PLAYING_STATE;    }
        public function get isPaused() :Boolean { return state == PAUSED_STATE;     }
        public function get isComplete():Boolean{ return state == COMPLETE_STATE;   }
        
        public function reset():void { }
        public function play():void { ensureInstance(); state = PLAYING_STATE; }
        public function pause():void{ state = PAUSED_STATE; }
        public function resume():void{ ensureInstance(); state = PLAYING_STATE; }
        public function stop():void{ state = COMPLETE_STATE; }
        public function seek(location:Number):void{ ensureInstance(); state = PLAYING_STATE; }
        public function skipToEnd():void { ensureInstance(); state = PLAYING_STATE; } // will still callback
        
        protected function onComplete():void 
        {
            state = COMPLETE_STATE; 
            stop();
            reset();
            
            if(callback != null)
            {
                callback(this);
            }
        }        
        protected function ensureInstance():void { }
        
		public function update(elapsed:uint):void
		{            
        }
        
        public function dispose():void 
        {
            objectToPlay = null;
            callback = null;
        }
    }

}