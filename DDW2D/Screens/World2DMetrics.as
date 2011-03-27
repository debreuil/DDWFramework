package DDW2D.Screens 
{
    public class World2DMetrics
    {        
		public var scale:Number = 30.0;
		public var timeStep:Number = 1.0/60.0;
		public var velocityIterations:int = 10;
		public var positionIterations:int = 10;
        
		public var gravityX:Number = 0;
		public var gravityY:Number = 10;
        
        public var allowSleep:Boolean;
        
		public var top:int = 0;
		public var left:int = 0;
		public var width:int = -1;
		public var height:int = -1;
        
        public function World2DMetrics() 
        {            
        }        
    }

}