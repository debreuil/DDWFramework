package DDW.Managers
{
	import DDW.Media.Animator;
	import DDW.Media.DisplayMetric;
	
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	public class AnimationManager extends Manager
	{
		private static var _instance:AnimationManager;
		private var animationList:Array = [];
		public var isEnabled:Boolean = true;
		
		private var timer:Timer;
		private var tickDuration:int = 20;
		private static var singletonLock:Boolean = false;
		
		public function AnimationManager()
		{
			if(singletonLock)
			{
				init();
			}
			else
			{
				throw new Error("AnimationManager is a singleton class. Use 'getInstance' instead.");
			}
		}
        public static function get instance():AnimationManager
		{
			if(_instance == null)
			{
				singletonLock = true;
				_instance = new AnimationManager();
				singletonLock = false;
			}
			return _instance;
		}
        
		private function init():void
		{
			timer = new Timer(tickDuration);
			timer.addEventListener(TimerEvent.TIMER, this.onTimer, false, 0, true);	
			if(isEnabled)
			{	
				timer.start();
			}
		}
		
		public function add(obj:Animator):void
		{
			this.animationList.push(obj);
			if(!timer.running)
			{
				restart();
			}
		}
		public function remove(obj:Animator):Boolean
		{
			var result:Boolean = false;
			if(obj != null && animationList.indexOf(obj) > -1)
			{
				this.animationList.splice(animationList.indexOf(obj), 1);
				if(timer.running && this.animationList.length == 0)
				{
					stop();
				}
				result = true;
			}
			return result;
		}
		
		public function stop():void
		{
			if(this.timer != null)
			{
				timer.stop();
			}
		}
		public function restart():void
		{
			if(this.timer != null)
			{
				if(isEnabled)
				{	
					timer.reset();
					timer.start();
				}
			}
		}
		private function onTimer(event:TimerEvent):void
		{
			for(var i:int = 0; i < animationList.length; i++)
			{
				updateAnimation(animationList[i]);
			}
			event.updateAfterEvent();
		}
		private function updateAnimation(an:Animator):Boolean
		{
			var result:Boolean = false;
			
			if (an != null)
			{
				an.incrementT(true);
				
				if (an.isComplete)
				{
					remove(an);
					result = true;
				}
			}
			
			return result;
		}
		
		public override function disposeView():void
		{
			if(this.timer != null)
			{
				this.timer.stop();
				this.timer.removeEventListener(TimerEvent.TIMER, this.onTimer);
				this.timer = null;
			}
		}
	}
}