package DDW.Utilities 
{
    import DDW.Components.Component;
    import DDW.Interfaces.ITransition;
    import DDW.Media.Animator;
    import DDW.Media.DisplayMetric;
    import DDW.Managers.*;
    import flash.display.DisplayObject;
    import flash.display.Sprite;
    public class FadeTransition implements ITransition
    {        
        public var blocker:Sprite;
        
		private var _hideCompletionCallback:Function;
		private var _showCompletionCallback:Function;
        
		protected var showAnimator:Animator;
		protected var hideAnimator:Animator;
        
        public function FadeTransition(blocker:Component = null) 
        {            
            this.blocker = blocker;
        }
		public function get hideCompletionCallback() : Function
		{
			return _hideCompletionCallback;
		}
		public function set hideCompletionCallback( n:Function ) : void
		{
			_hideCompletionCallback = n;
		}
		public function get showCompletionCallback() : Function
		{
			return _showCompletionCallback;
		}
		public function set showCompletionCallback( n:Function ) : void
		{
			_showCompletionCallback = n;
		}
        
		public function fadeInBegin():void // todo: add this as decorator..
		{		
            if (blocker != null)
            {
                blocker.alpha = 1;
                blocker.visible = true;
                var m0:DisplayMetric = DisplayMetric.getMetric(blocker);
                var m1:DisplayMetric = m0.clone();
                m1.alpha = 0;
                showAnimator = new Animator(blocker, m0, m1, 3, fadeInEnd);
                AnimationManager.instance.add(showAnimator);
            }
			else if(_showCompletionCallback != null)
			{
				_showCompletionCallback();
			}
		}
		public function fadeInEnd(an:Animator, args:Array):void // todo: add this as decorator..
		{			           
            blocker.visible = false;
			if(_showCompletionCallback != null)
			{
				_showCompletionCallback();
				_showCompletionCallback = null;
			}
			showAnimator = null;
		}
		public function fadeOutBegin():void // todo: add this as decorator..
		{			   
            if (blocker != null)
            {
                blocker.alpha = 0;
                blocker.visible = true;
                var m0:DisplayMetric = DisplayMetric.getMetric(blocker);
                var m1:DisplayMetric = m0.clone();
                m1.alpha = 1;
                hideAnimator = new Animator(blocker, m0, m1, 3, fadeOutEnd);
                AnimationManager.instance.add(hideAnimator);
            }
			else if(_hideCompletionCallback != null)
			{
				_hideCompletionCallback();
			}
		}
		public function fadeOutEnd(an:Animator, args:Array):void // todo: add this as decorator..
		{		  
			hideAnimator = null;
            blocker.visible = true; 
			if(_hideCompletionCallback != null)
			{
				_hideCompletionCallback();
				_hideCompletionCallback = null;
			}
		}
		
    }

}