package DDW.Managers
{
	import DDW.Interfaces.ITimeoutPlayer;
	
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	public class TimeoutManager extends Manager
	{
		private static var manager:TimeoutManager;
		public var currentTimeoutObject:ITimeoutPlayer = null;
		private var timer:Timer;
		private var shortTimeoutDuration:int = 4; //  2; // 
		private var longTimeoutDuration:int = 12; // 4; // 
		private static var singletonLock:Boolean = false;
		
		function TimeoutManager()
		{
			if(singletonLock)
			{
				init();
			}
			else
			{
				throw new Error("TimeoutManager is a singleton class. Use 'getInstance' instead.");
			}
		}
        public static function get instance():TimeoutManager
		{
			if(manager == null)
			{
				TimeoutManager.singletonLock = true;
				manager = new TimeoutManager();
				TimeoutManager.singletonLock = false;
			}
			return manager;
		}
		private function init():void
		{
			timer = new Timer(1000);
			timer.addEventListener(TimerEvent.TIMER, this.onTimer);		
			timer.start();
		}
		public function stop():void
		{
			timer.stop();
		}
		public function restart():void
		{
			if(!Sequencer.instance.isPlaying)
			{
				timer.reset();
				timer.start();
			}
		}
		private function onTimer(event:TimerEvent):void
		{
			var wasHandled:Boolean = false;
			
			if(timer.currentCount == shortTimeoutDuration)
			{
				wasHandled = callShortTimeout();
			}
			else if(timer.currentCount >= longTimeoutDuration)
			{
				wasHandled = callLongTimeout();
				if(!wasHandled)
				{
					restart();
				}
			}
			if(wasHandled)
			{
				timer.stop();
			}
		}
		private function callShortTimeout():Boolean
		{
			var result:Boolean = false;
			if(currentTimeoutObject != null)
			{
				result = currentTimeoutObject.onShortTimeout();
			}
			else
            {
				//result = callBlankTimeout();				
			}
			return result;
		}
		private function callLongTimeout():Boolean
		{
			var result:Boolean = false;
			if(currentTimeoutObject != null)
			{
				result = currentTimeoutObject.onLongTimeout();
			}
			else
			{
				//result = callBlankTImeout();				
			}
			return result;
		}
	}
}