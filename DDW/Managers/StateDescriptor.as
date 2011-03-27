package DDW.Managers
{
    import DDW.Components.Component;
    import DDW.Interfaces.ITransition;
	import DDW.Media.Animator;
	import DDW.Media.DisplayMetric;
    import DDW.Media.AssetDescriptor;
	import DDW.Screens.Screen;
    import DDW.Utilities.FadeTransition;
    import flash.display.DisplayObject;
    import flash.display.DisplayObjectContainer;
    import flash.display.LoaderInfo;
    import flash.system.ApplicationDomain;
	
	import flash.display.MovieClip;
	
	public class StateDescriptor extends AssetDescriptor
	{	               
		protected var transition:ITransition   
        public var previousScreen:String = null;
		
		public function StateDescriptor(stateName:String, screenClass:Class, assetUrl:String = null, libraryName:String = null, transition:ITransition  = null)
		{
            super(stateName, screenClass, assetUrl, libraryName);
            
			if(screenClass is Screen)
			{
				throw(new Error("State bases must be Screen objects."));
			}
            this.transition = transition;
		}
		public function get stateName():String
		{
			return _name;
		}
		public function get screenInstance():Screen
		{
			return Screen(_instance);
		}
		public function set screenInstance(value:Screen):void
		{
            _instance = value;
		}
        
		private var hideCompletionCallback:Function;
		public function hide(nextState:StateDescriptor = null, hideCompletionCallback:Function = null):void
		{		
            this.hideCompletionCallback = hideCompletionCallback;
			if(transition != null)
			{
                transition.hideCompletionCallback = onHideEnd;
				transition.fadeOutBegin();
			}
			else if(hideCompletionCallback != null)
			{
                onHideEnd();
				//hideCompletionCallback();
			}
		}
        private function onHideEnd():void
        {
            if (hideCompletionCallback != null)
            {
                var fn:Function = hideCompletionCallback;
                fn();
                hideCompletionCallback = null;
            }
            //disposeStateView();
        }
		public function show(previousState:StateDescriptor = null, showCompletionCallback:Function = null):void
		{			
			initializeStateView();
			if(transition != null)
			{
                transition.showCompletionCallback = showCompletionCallback;
				transition.fadeInBegin();
			}
			else if(showCompletionCallback != null)
			{
				showCompletionCallback();
			}
		}
			
		protected function initializeStateView():void
		{
			ensureStateInstance();
		}
		
		protected function disposeStateView():void
		{
			// todo: clean up anything else...
			if(_instance != null)
			{
                Screen.stopAll(_instance);
                if (_instance is Component)
                {
                    Component(_instance).disposeView();
                }
				_instance = null;
			}
		}
	}
}