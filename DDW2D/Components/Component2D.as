package DDW2D.Components 
{
    import Box2D.Common.Math.b2Vec2;
    import Box2D.Dynamics.b2Body;
    import Box2D.Dynamics.b2World;
    import DDW.Components.Component;
    import flash.display.DisplayObject;
    import flash.display.MovieClip;
	import flash.utils.describeType;
    
    public class Component2D extends Component
    {        
        protected const splinePrefix:String = "sp$";
        protected const shapePrefix:String = "p$";
        protected const circlePrefix:String = "c$";
        
        public var shapeDefs:Array;
        
        public function get friction():Number { return 0.0; }
        public function get density():Number { return 1.0; }
        public function get restitution():Number { return 0.0; }
        public function get canSleep():Boolean { return true; }
        
        public function get isStatic():Boolean { return false; }
        public function get isKinematic():Boolean { return false; }
        
        public function Component2D(autoLayout:DisplayObject)
		{
            parse2DElements(autoLayout);
            super(autoLayout);
        } 
        
        public function initializePhysics(body:b2Body, world:b2World):void 
        {
        }
        
        public function updatePhysics(elapsed:uint, body:b2Body, world:b2World):void
        {            
        }
        
        public function updateView(elapsed:uint, body:b2Body, scale:Number):void
        {
            var p:b2Vec2 = body.GetPosition();
            this.x = p.x * scale;
            this.y = p.y * scale;
            this.rotation = (body.GetAngle()/ Math.PI * 180);
        }
                
        protected function parse2DElements(autoLayout:DisplayObject):void
        {
            shapeDefs = [];
            var curDef:Array = [];
            shapeDefs.push(curDef);
            
            var m:MovieClip = MovieClip(autoLayout);
            
            var shapeIndex:int = 0;
            var ptIndex:int = 0;
            var prefix:String = shapePrefix;
            curDef.isSpline = false;
            var d:DisplayObject = m.getChildByName(shapePrefix + shapeIndex + "_" + ptIndex);
            if (d == null)
            {
                d = m.getChildByName(splinePrefix + shapeIndex + "_" + ptIndex);
                if (d != null)
                {
                    curDef.isSpline = true;
                    prefix = splinePrefix;
                }
            }
            
            while (d != null)
            {
                var isCircle:Boolean = Math.abs(d.width / d.scaleX - 100) < .1;
                if (isCircle)
                {
                    curDef.isCircle = true;
                    curDef.push(new b2Vec2(d.x, d.y));
                    curDef.push(d.width / 2.0);
                }
                else
                {
                    curDef.isCircle = false;
                    curDef.push(new b2Vec2(d.x, d.y));
                }
                
                m.removeChild(d);
                
                ptIndex++;
                d = m.getChildByName(prefix + shapeIndex + "_" + ptIndex);
                
                if (d == null)
                {
                    //ensureCW(curDef);                    
                    ptIndex = 0;
                    shapeIndex++;                    
                    d = m.getChildByName(prefix + shapeIndex + "_" + ptIndex);  
                    
                    if (d != null)
                    {
                        curDef = [];
                        shapeDefs.push(curDef);
                    }
                    else
                    {
                        break;
                    }
                }
            }
        }
        
        protected function ensureCW(pts:Array):void
        {
            if(pts.length > 2)
            {
                var cp:Number =
                    (pts[1].x - pts[0].x) *
                    (pts[2].y - pts[1].y) -
                    (pts[1].y - pts[0].y) *
                    (pts[2].x - pts[1].x);

                var isCW:Boolean = (cp > 0);

                if(!isCW)
                {
                    pts = pts.reverse();
                }
            }
        }
    }

}