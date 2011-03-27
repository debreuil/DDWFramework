package DDW.Managers
{
	import DDW.Interfaces.IDisposable;
    import DDW.Interfaces.IGameState;
    import DDW.Media.AssetDescriptor;
	import DDW.Screens.Screen;
    import DDW.Screens.SplashScreen;
    import flash.display.DisplayObject;
    import flash.display.LoaderInfo;
    import State.GameState;
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
				
	public class StateManager  implements IDisposable
	{		
		public static const frameRate:uint = 31;
		
		public var overlayLayer:Sprite;
		public var rootObject:Sprite;
		
		private var _states:Vector.<StateDescriptor> = new Vector.<StateDescriptor>();		
		private var _overlays:Vector.<AssetDescriptor> = new Vector.<AssetDescriptor>();
		
		public var previousState:StateDescriptor;
		public var currentState:StateDescriptor;
		
		public function StateManager(rootObject:Sprite, overlayLayer:Sprite, gameState:IGameState)
		{
			if(rootObject == null || overlayLayer == null)
			{
				throw(new Error("Neither root nor overlay can be null"));
			}
			this.rootObject = rootObject;
            this.overlayLayer = overlayLayer;
            gameState.initialize(this);
		}
		
		public function addOverlay(overlayDescriptor:AssetDescriptor, onAddedCallback:Function = null):void
		{
			_overlays.push(overlayDescriptor);
            // add immendiately
            overlayDescriptor.getInstanceAsync
            (
                function(inst:DisplayObject):void
                {
                    //inst.visible = false;
                    overlayLayer.addChild(inst);
                    if (onAddedCallback != null)
                    {
                        onAddedCallback(inst);
                    }
                } 
             );
		}
        
		public function addState(stateDescriptor:StateDescriptor):void
		{
			_states.push(stateDescriptor);
		}		
        
		public function getState(stateName:String):StateDescriptor
		{
			var result:StateDescriptor = null;
			for (var i:int = 0; i < _states.length; i++) 
			{
				if (_states[i].stateName == stateName)
				{
					result = _states[i];
					break;
				}				
			}
			return result;
		}
		
		public function getOverlay(overlayName:String):AssetDescriptor
		{
			var result:AssetDescriptor = null;
			for (var i:int = 0; i < _overlays.length; i++) 
			{
				if (_states[i].stateName == overlayName)
				{
					result = _overlays[i];
					break;
				}				
			}
			return result;
		}
		
		public function getCurrentState():StateDescriptor
		{	
			return currentState;	
		}
		public function setCurrentState(stateName:String):void
		{
			if(currentState != null && stateName == currentState.stateName)
			{
				// skip
			}
			else if(stateName == "" || stateName == null)
			{
				transitionStateTo(null); // eg: at end, display nothing next
			}
			else
			{
				var st:StateDescriptor = getState(stateName);
				if (st != null)
				{
					transitionStateTo(st); // normally this
				}
			}
		}
		
		protected function transitionStateTo(nextState:StateDescriptor = null):void
		{
            var orgState:StateDescriptor = previousState;
            previousState = currentState;
            
			currentState = nextState;
			if(previousState != null)
			{
				previousState.hide(previousState, createCurrentState);
			}
			else
			{
				createCurrentState();
			}	
		}
		protected function createCurrentState():void
		{
			if(previousState != null && previousState.screenInstance != null)
			{			
                var pState:Screen = previousState.screenInstance;
                previousState.screenInstance = null;
                Screen.stopAll(pState);
				if(rootObject.contains(pState))
				{
					rootObject.removeChild(pState);
					if (pState.unloadWhenRemoved)
                    {
                        AssetManager.instance.unloadAsset(previousState.assetUrl);
                        previousState = null;
                    }
				}
			}
			
			if(currentState != null)
			{
                currentState.getInstanceAsync
                (
                    function(inst:Screen):void
                    {
                        currentState.previousScreen = inst.previousScreen;
                        rootObject.addChild(inst);
                        currentState.show(previousState, stateCreationComplete);
                    }
                 );
			}	
		}
		
		protected function stateCreationComplete():void
		{				
		}
        
        public function goToPreviousState():void 
        {
            var curIndex:int = _states.indexOf(currentState);
            curIndex = (curIndex == 0) ? _states.length - 1 : curIndex - 1;
            setCurrentState(_states[curIndex].name);
        }
        public function goToNextState():void 
        {
            var curIndex:int = _states.indexOf(currentState);
            curIndex = (curIndex == _states.length - 1) ? 0 : curIndex + 1;
            setCurrentState(_states[curIndex].name); 
        }
        
        
		public function update(elapsed:Number):void
		{
            if (currentState.screenInstance != null)
            {
                currentState.screenInstance.update(elapsed);
            }
            Sequencer.instance.update(elapsed);
        }
        
		private var isDisposed:Boolean = false;
		public function disposeView():void
		{
			if(!isDisposed) // in case double calls
			{
                var n:int = overlayLayer.numChildren;
                for (var i:int = 0; i < n; i++) 
                {
                    // dispose objects in overlay layer
                    overlayLayer.removeChildAt(0);
                }
				transitionStateTo(null);
			}
			isDisposed = true;
		}
	}
}
