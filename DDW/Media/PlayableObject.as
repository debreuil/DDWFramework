package DDW.Media
{
	import DDW.Interfaces.*;
	
	import flash.display.DisplayObjectContainer;
	
	public class PlayableObject implements IDisposable
	{
		public var skipAmount:Number = 5;
		public var volume:Number = 1;
		public var isPaused:Boolean = false;
		public var isMuted:Boolean = false;
		public var isVideo:Boolean = false;
		
		protected var path:String;
		protected var container:DisplayObjectContainer;	
		protected var completeCallback:Function;	
		
		public function PlayableObject()
		{
		}
		public function setContent(path:String, container:DisplayObjectContainer, completeCallback:Function = null, x:int = 0, y:int = 0, w:int = -1, h:int = -1):void
		{
			this.completeCallback = completeCallback;
			this.container = container;
			this.path = path;
			isPaused = true;
		}
		
		public function get duration():Number{return 100;}
		public function setDefaultImage(path:String, x:int=0, y:int=0):void{}
		public function getCurrentTime():Number{return -1;}
		public function pause():void{isPaused = true;}	
		public function resume():void{isPaused = false;}
		public function seek(location:Number):void{}	
		public function setVolume(amount:Number):void{this.volume = amount;}	
		public function toggleMute():void{isMuted = !isMuted;}	
		public function disposeView():void{};
		
		public function playFromStart():void
		{
			isPaused = false;
			if(getCurrentTime() > 1)
			{
				seek(1);
			}
			resume();
			setVolume(volume);
		}					
		public function seekAndPlay(location:int):void
		{			
			seek(location);
			resume();
		}
		public function skipBack(amount:int = int.MAX_VALUE):void
		{			
			amount = (amount == int.MAX_VALUE) ? skipAmount : amount;
			var t:Number = getCurrentTime();
			t -= amount;
			if(t < 0)
			{
				t = 0;
			}
			seek(t);
		}
		public function skipBackAndPlay(amount:int = int.MAX_VALUE):void
		{
			amount = (amount == int.MAX_VALUE) ? skipAmount : amount;
			skipBack(amount);
			resume();
		}	
		public function skipForward(amount:int = int.MAX_VALUE):void
		{			
			amount = (amount == int.MAX_VALUE) ? skipAmount : amount;
			var t:Number = getCurrentTime();
			t += amount;
			if(t > duration)
			{
				t = duration;
			}
			seek(t);
		}		
		public function skipForwardAndPlay(amount:int = int.MAX_VALUE):void
		{			
			amount = (amount == int.MAX_VALUE) ? skipAmount : amount;
			skipForward(amount);
			resume();
		}			
		public function atStart():Boolean
		{
			return getCurrentTime() < .1;
		}
		public function atEnd():Boolean
		{
			return (getCurrentTime() > duration - .5) || (duration == 0);
		}
		
	}
}