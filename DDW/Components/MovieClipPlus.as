package DDW.Components
{
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.events.Event;

	public class MovieClipPlus extends Component
	{
		public var $mc:MovieClip;
		
		public var completeCallback:Function;
		public var finalFrame:int;
		
		public function MovieClipPlus(autoLayout:DisplayObject)
		{
			super(autoLayout);
		}		
		
		protected override function initializeComponent():void
		{			
		}
		public function get currentFrame():int
		{
			return $mc.currentFrame;
		}
		public function gotoAndStop(value:int):void
		{
			$mc.gotoAndStop(value);
		}
		public function gotoAndPlay(value:int):void
		{
			$mc.gotoAndPlay(value);
		}
		public function playOnce(callback:Function):void
		{
			if(this.$mc != null)
			{
				completeCallback = callback;
				if(!$mc.hasEventListener(Event.ENTER_FRAME))
				{
					$mc.addEventListener(Event.ENTER_FRAME, this.onEnterFrame, false, 0, true);	
				}
				finalFrame = $mc.totalFrames;
				this.$mc.gotoAndPlay(1);
			}
		}
		
		public function playSection(from:int, to:int, callback:Function):void
		{
			if(this.$mc != null)
			{
				completeCallback = callback;
				if(!$mc.hasEventListener(Event.ENTER_FRAME))
				{
					$mc.addEventListener(Event.ENTER_FRAME, this.onEnterFrame, false, 0, true);	
				}
				finalFrame = to;
				this.$mc.gotoAndPlay(from);
			}
		}
		
		public function play():void
		{
			this.$mc.play();
		}
		
		public function stop():void
		{
			if(this.$mc != null)
			{
				$mc.removeEventListener(Event.ENTER_FRAME, this.onEnterFrame);
				this.$mc.stop();
			}
		}	
			
		protected function onEnterFrame(e:Event):void
		{		
			if(this.$mc != null)
			{    
				if($mc.currentFrame == finalFrame) 
				{
			        $mc.stop();
					$mc.removeEventListener(Event.ENTER_FRAME, this.onEnterFrame);
					
					if(completeCallback != null)
					{
						completeCallback(e);
					}
    			}
    			
			}
		}
		
	}
}