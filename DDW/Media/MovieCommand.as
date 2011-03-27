package DDW.Media 
{
    import DDW.Managers.Sequencer;
    import flash.display.MovieClip;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.media.SoundTransform;
	import flash.utils.getDefinitionByName;
    
    public class MovieCommand extends MediaCommand
    {        
        public var currentFrame:uint;
        public var instance:MovieClip;
        protected var objectToReplace:InstanceDescriptor;
        protected var previousFrame:uint;
        protected var startFrameIndex:uint = 1;
        protected var startFrameLabel:String = null;
        
        protected static var soundOn:SoundTransform = new SoundTransform(1);
        protected static var soundOff:SoundTransform = new SoundTransform(0);
        
        public function MovieCommand(objectToPlay:AssetDescriptor, callback:Function = null, startFrame:Object = null, disableCursor:Boolean = false, objectToReplace:InstanceDescriptor = null) 
        {                        
            super(objectToPlay, callback, disableCursor);
            this.objectToReplace = objectToReplace;
            instance = MovieClip(objectToPlay.instance); // may be null
            if (startFrame != null)
            {
                if (startFrame is String)
                {
                    startFrameLabel = String(startFrame);
                }
                else
                {
                    startFrameIndex = uint(startFrame);                    
                }
            }
        }        
        
		public override function reset():void
		{        
            super.reset();
            if(objectToReplace != null)
            {
                objectToReplace.originalDisplayMetric.applyTo(instance, true);
            }
            instance.gotoAndStop(1);
            previousFrame = 1;
        }
        
		public override function play():void
		{        
            super.play();
            if (instance != null)
            {
                instance.visible = true;
                ensureListener();
                instance.soundTransform = soundOn; 
                if (startFrameLabel != null)
                {
                    instance.gotoAndPlay(startFrameLabel);
                }
                else
                {
                    instance.gotoAndPlay(startFrameIndex);
                }
            } 
		}
        
		public override function pause():void
		{
            super.pause();
            if (instance != null)
            {
                clearListener();
                instance.stop();
                instance.soundTransform = soundOff; 
            }
        }
		public override function resume():void
		{
            super.resume();
            if (instance != null)
            {
                instance.soundTransform = soundOn; 
                ensureListener();
                instance.play();
            }
        }
		public override function stop():void
		{
            super.stop();
            if (instance != null)
            {             
                clearListener(); 
                instance.stop();
                
                // turn off potential event sounds
                instance.soundTransform = soundOff; 
                
                if (objectToReplace != null && objectToReplace.displayObject != null)
                {
                    if (instance.parent != null)
                    {
                        instance.parent.removeChild(objectToReplace.displayObject);
                    } 
                    objectToReplace.originalParent.addChild(objectToReplace.displayObject);
                }  
            }
        }        
        public override function seek(location:Number):void
		{
            super.seek(location);
            if (instance != null)
            {
                instance.soundTransform = soundOn; 
                instance.gotoAndPlay(Math.min(Math.floor(location), instance.totalFrames));
            }
        }        
        public override function skipToEnd():void // will still callback  
		{
            super.skipToEnd();
            if (instance != null)
            {
                instance.soundTransform = soundOn; 
                instance.gotoAndPlay(instance.totalFrames - 1);
            }
        }
        
        private function ensureListener():void 
        {            
            instance.addEventListener(Event.ENTER_FRAME, onFrame);
        }
        private function clearListener():void 
        {            
            instance.removeEventListener(Event.ENTER_FRAME, this.onFrame, false);
        }
        private function onFrame(e:Event):void 
        {              			
			var m:MovieClip = MovieClip(e.target);			
            
			 // detect wrap & gotoAndStop(1)'s on the timeline
            if(m.currentFrame >= m.totalFrames || m.currentFrame < previousFrame)
            {
                onComplete();
            }		
            previousFrame = m.currentFrame;
        }
        protected override function onComplete():void 
        {      
            super.onComplete();                      
        }
        protected override function ensureInstance():void
        {         
            if (instance == null)
            {
                // todo: move this to AssetDexc. async loader
                var cls:Class = getDefinitionByName(objectToPlay.libraryName) as Class;
                instance = MovieClip(new cls());
                instance.name = "inst" + objectToPlay.libraryName;
                
                var depth:int = objectToReplace.originalParent.numChildren;
                if (objectToReplace.displayObject != null)
                {
                    objectToReplace.originalDisplayMetric.applyTo(instance, true);
                    objectToReplace.originalParent.removeChild(objectToReplace.displayObject);
                    
                    if (objectToReplace.originalDisplayMetric.depth != -1)
                    {
                        depth = objectToReplace.originalDisplayMetric.depth;                        
                    }
                }
                
                depth = (depth == -1) ? objectToReplace.originalParent.numChildren : depth;  
                
                objectToReplace.originalParent.addChildAt(instance, depth);
            }
        }
        public static function createFromClip(mc:MovieClip, callback:Function = null, startFrame:Object = null, disableCursor:Boolean = false):MovieCommand
        {            
            var ad:AssetDescriptor = new AssetDescriptor("", null, null, null, mc);
            var instDesc:InstanceDescriptor = new InstanceDescriptor(mc);
            var result:MovieCommand = new MovieCommand(ad, callback, startFrame, disableCursor, instDesc);
            Sequencer.instance.append(result);
            if (Sequencer.instance.appendList.length == 1)
            {
                Sequencer.instance.play();
            }
            return result;
        }
        
        public override function dispose():void 
        {
            super.dispose();
            
            objectToReplace = null;
            if (instance != null)
            {
                instance.stop();
                instance = null;
            }
        }
    }
}