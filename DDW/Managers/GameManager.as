package DDW.Managers
{	
	import DDW.Components.*;
	import DDW.Enums.*;
	import DDW.Interfaces.*;
	import DDW.Screens.*;
    import flash.events.Event;
	
	import flash.display.Sprite;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.utils.Timer;

	public class GameManager
	{	 		
        protected var stateManager:StateManager;
		
        private var t:Timer;
		protected var startTime:Number = -1;
		public var currentTime:Number = -1;
		protected var previousTime:Number = -1;
        
		protected var isPaused:Boolean = false;  
		protected var minInterval:int;
		protected var maxInterval:int;
		private var d:Date;
		
		public function GameManager(stateManager:StateManager)
		{
            this.stateManager = stateManager;
            init();
		}	
        
		public function init():void
		{				
			this.d =  new Date();
			this.startTime = d.getTime();
			this.currentTime = this.startTime;
			this.previousTime = 0;	
            
            //t = new Timer(32);
            //t.addEventListener(TimerEvent.TIMER, update);
            //t.start();
            minInterval = (1000.0 / stateManager.rootObject.stage.frameRate) - 2;
            maxInterval = (1000.0 / stateManager.rootObject.stage.frameRate) * 3 - 2;
            stateManager.rootObject.addEventListener(Event.ENTER_FRAME, update);
		}
        
		protected function update(e:Event):void
		{
            this.d = new Date(); 
            this.currentTime = d.getTime() - this.startTime;
            var elapsed:uint = this.currentTime - this.previousTime;
            
			if(elapsed > minInterval && !this.isPaused)
			{		
                if (elapsed < maxInterval) // during intitalization there can be huge jumps, so skip them
                {
                    stateManager.update(16);// elapsed);  
                }
                this.previousTime = this.currentTime;	
            }
		}
        
		public function dispose():void
		{
            if (t != null)
            {
                t.removeEventListener(TimerEvent.TIMER, update);
            }
            stateManager.rootObject.removeEventListener(Event.ENTER_FRAME, update);
		}
	}
}