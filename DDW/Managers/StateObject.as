package DDW.Managers
{
	import DDW.Media.Animator;
	import DDW.Media.DisplayMetric;
	import DDW.Screens.Screen;
	
	import flash.display.MovieClip;
	
	public class StateObject 
	{
		protected var _stateName:String;		
		protected var _screenClass:Class;	
		protected var screenInstance:Screen;
		
		public function StateObject(stateName:String, screenClass:Class, args:Array=null)
		{
			this._stateName = stateName;
			this._screenClass = screenClass;
			if(_screenClass is Screen)
			{
				throw(new Error("State bases must be Screen objects."));
			}
		}
		public function get stateName():String
		{
			return _stateName;
		}
		public function get screenClass():Class
		{
			return _screenClass;
		}
		public function get stateInstance():Screen
		{
			ensureStateInstance();
			return screenInstance;
		}	
		
		private function ensureStateInstance():void
		{
			if(screenInstance == null)
			{
				screenInstance = new _screenClass(); // add args
			}			
		}	
		
		protected var hideCompletionCallback:Function;
		protected var showCompletionCallback:Function;
		protected var showAnimator:Animator;
		protected var hideAnimator:Animator;
		
		public function hide(nextState:StateObject = null, hideCompletionCallback:Function = null):void
		{		
			this.hideCompletionCallback = hideCompletionCallback;
			if(screenInstance != null)
			{
				fadeOutBegin();
			}
			else if(hideCompletionCallback != null)
			{
				hideCompletionCallback();
			}
		}
		public function show(previousState:StateObject = null, showCompletionCallback:Function = null):void
		{			
			this.showCompletionCallback = showCompletionCallback;
			
			initializeStateView();
			if(screenInstance != null)
			{
				fadeInBegin();
			}
			else if(hideCompletionCallback != null)
			{
				hideCompletionCallback();
			}
		}
		
		protected function fadeInBegin():void // todo: add this as decorator..
		{		
			screenInstance.alpha = 0;
			var m0:DisplayMetric = screenInstance.getMetric();
			var m1:DisplayMetric = m0.clone();
			m1.alpha = 1;
			showAnimator = new Animator(screenInstance, m0, m1, 1, fadeInEnd);
			AnimationManager.getInstance().add(showAnimator);
		}
		protected function fadeInEnd(an:Animator, args:Array):void // todo: add this as decorator..
		{			
			if(showCompletionCallback != null)
			{
				showCompletionCallback();
				showCompletionCallback = null;
			}
			showAnimator = null;
		}
		protected function fadeOutBegin():void // todo: add this as decorator..
		{			
			screenInstance.alpha = 1;
			var m0:DisplayMetric = screenInstance.getMetric();
			var m1:DisplayMetric = m0.clone();
			m1.alpha = 0;
			hideAnimator = new Animator(screenInstance, m0, m1, 1, fadeOutEnd);
			AnimationManager.getInstance().add(hideAnimator);
		}
		protected function fadeOutEnd(an:Animator, args:Array):void // todo: add this as decorator..
		{		
			if(hideCompletionCallback != null)
			{
				hideCompletionCallback();
				hideCompletionCallback = null;
			}
			hideAnimator = null;
			disposeStateView();		
		}
		
		
		
		protected function initializeStateView():void
		{
			ensureStateInstance();
		}
		
		protected function disposeStateView():void
		{
			// todo: clean up anything else...
			if(stateInstance != null)
			{
				if(stateInstance is MovieClip)
				{
					MovieClip(stateInstance).stop();
				}
				screenInstance = null;
			}
		}
	}
}