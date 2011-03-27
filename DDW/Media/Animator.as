package DDW.Media
{
	import flash.display.DisplayObject;
	import flash.utils.getDefinitionByName;
	
	public class Animator
	{
		private var view:DisplayObject;
		public var startMetric:DisplayMetric;
		public var endMetric:DisplayMetric;
		public var steps:int;	
		
		public var tickCallback:Function;
		public var completionCallback:Function;
		public var callbackTarget:Object;
		public var callbackArg:Object;
		public var tweenFormula:Function;		
		
		public var t:Number = 0;
		private var inc:Number;	
		private var _isComplete:Boolean;
		private var hasCalledBack:Boolean;
        		
		public function Animator(view:DisplayObject, startMetric:DisplayMetric, endMetric:DisplayMetric, steps:int, completionCallback:Function = null, callbackTarget:Object = null, callbackArg:Object = null, tickCallback:Function = null) 
		{
			this.view = view;
			this.startMetric = startMetric;
			this.endMetric = endMetric;
			this.steps = steps;
			this.completionCallback = completionCallback;
			this.callbackTarget = callbackTarget;
			this.callbackArg = callbackArg;
			this.tickCallback = tickCallback;
			
			_isComplete = false;
			hasCalledBack = false;
			inc = 1 / steps;
			tweenFormula = linearIncrement;
		}
		
		public function start():void
		{
			t = 0;
			_isComplete = false;
		}
		public function end():void
		{
			t = 1;
		}
		public function revertAnimationInstant():void
		{
			endMetric = startMetric;
			t = 1;
			_isComplete = false;
		}
		public function revertAnimationSmooth():void
		{
			var m:DisplayMetric = getCurrentMetric();
			endMetric = startMetric;
			startMetric = m;
			t = 1 - t;
			_isComplete = false;
		}
		public function incrementT(applyChanges:Boolean):void
		{
			_isComplete = false;
			t += inc;
			if (t > 1)
			{
				t = 1;
				_isComplete = true;
			}
			
			if(applyChanges)
			{
				this.applyMetric();
                if (tickCallback != null)
                {
                    tickCallback.call(callbackTarget, this);
                }
			}
			
			if(_isComplete)
			{				
				if (!hasCalledBack && completionCallback != null)
				{
					if (callbackTarget != null)
					{
						//callbackTarget[completionCallback](this, callbackArg);
                        completionCallback.call(callbackTarget, this, callbackArg);
					}
					else
					{
						completionCallback(this, callbackArg);
					}
					hasCalledBack = true;
				}
				hasCalledBack = true;
			}
		}
		
		public function get isComplete():Boolean
		{
			return _isComplete;
		}
		
		public function applyMetric():void
		{
			if(this.view != null)
			{
				var m:DisplayMetric = getCurrentMetric();
				view.x = m.x;
				view.y = m.y; 
				view.width = m.width; 
				view.height = m.height;
				view.alpha = m.alpha;
				//view.scaleX = m.scale;
				//view.scaleY = m.scale;
			}
		}
		public function getCurrentMetric() :DisplayMetric
		{
			var result:DisplayMetric;
			if (t == 1)
			{
				result = endMetric;
			}
			else
			{
				result = tweenFormula(t);
			}
			return result;
		}
		private function linearIncrement(t:Number) :DisplayMetric
		{
			var x:Number = (endMetric.x - startMetric.x) * t + startMetric.x;
			var y:Number = (endMetric.y - startMetric.y) * t + startMetric.y;
			var w:Number = (endMetric.width - startMetric.width) * t + startMetric.width;
			var h:Number = (endMetric.height - startMetric.height) * t + startMetric.height;
			var a:Number = (endMetric.alpha - startMetric.alpha) * t + startMetric.alpha;
			var s:Number = (endMetric.scale - startMetric.scale) * t + startMetric.scale;
			
			var result:DisplayMetric = new DisplayMetric(x, y, w, h, a, s);
			return result;
		}
		public function toString() :String
		{
			return "anim: " + t + "   st:" + startMetric + "   end:" + endMetric;
		}
	}
}