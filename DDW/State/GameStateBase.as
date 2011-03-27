package DDW.State 
{
	public class GameStateBase implements IGameState 
	{		              
		private var manager:StateManager;
				        
		public static var DEFAULT_SCREEN:String = "defaultScreen";
		
		public var currentState:String;
		public var currentSubState:String;
        
        public var parentStates:Object = { };
        protected var transition:ITransition = new FadeTransition(); 
		
        public function GameStateBase()
        {
        }
        
		public function initialize(manager:StateManager):void
		{			
			this.manager = manager;
            
            createOverlays();
			createStates();					
		}			
		public function advanceState():void
		{
			setState(currentState);
		}	
        
		public function setState(stateName:String):void
		{
            var prevState:String = currentState;
			currentState = stateName;
			
            switch(currentState)
            {                    
                case EXIT_SCREEN:
                    if (prevState == HOUSE_SCREEN)
                    {                        
                        exitGame();
                    }
                    else if (parentStates[prevState] != null)
                    {
                        setState(parentStates[prevState]);
                    }
                    else
                    {
                        setPreviousState();
                    }
                    break;
                    
                default:
                    manager.setCurrentState(currentState);
                    //throw new(Error("state must exist when setting state: " + currentState));
                    break;
            }
		}
                
		public function setPreviousState():void
		{
            if (manager.previousState != null)
            {
                if (manager.previousState.previousScreen != null)
                {
                    currentState = manager.previousState.previousScreen;
                }
                else
                {
                    currentState = manager.previousState.stateName;                    
                }
                
                manager.setCurrentState(currentState);
            }
            else
            {
                setMainState();
            }
		}
		public function setMainState():void
		{
			currentState = HOUSE_SCREEN;
			manager.setCurrentState(HOUSE_SCREEN);
		}
		private function createOverlays():void
		{	
		}
		private function createStates():void
		{			
            //manager.addState(new StateDescriptor(GAME_SPLASH, GameSplashScreen, "assets/gameSplash.swf", "gameSplash", transition));
		}
		public function exitGame():void
		{		
            manager.disposeView();
		}
		
	}

}