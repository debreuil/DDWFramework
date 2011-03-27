package DDW2D.Screens 
{
    import Box2D.Collision.*;
    import Box2D.Collision.Shapes.*;
    import Box2D.Common.Math.*;
    import Box2D.Dynamics.*;
    import Box2D.Dynamics.Contacts.b2Contact;
    import Box2D.Dynamics.Joints.*;
    import DDW.Components.*;
    import DDW.Screens.*;
    import DDW2D.Components.*;
    import DDW2D.Managers.*;
    import DDW2D.Physics.*;
    import DDW2D.Utils.ScreenCamera;
    import flash.display.*;
    import flash.events.*;
    import flash.utils.*;
    
    public class Screen2D extends Screen
    {
		public var world:b2World;
		public var scale:Number;
		public var camera:ScreenCamera;
        
		protected var timeStep:Number;
		protected var velocityIterations:int = 10;
		protected var positionIterations:int = 10;
		protected var debugDraw:Boolean = false;
        
        protected var staticPattern:String = Component.USE$ ? "$S_" : "S_";
        protected var kinematicPattern:String = Component.USE$ ? "$K_" : "K_";
        protected var world2DMetrics:World2DMetrics;
		
		protected var isWorldActive:Boolean = true;
        
        public function Screen2D(autoLayout:DisplayObject, metrics:World2DMetrics = null)
		{
            world2DMetrics = (metrics == null) ? new World2DMetrics() : metrics;
            scale = world2DMetrics.scale;
            
			super(autoLayout);
        }
        
        override public function onAddedToStage(e:Event):void 
        {
            super.onAddedToStage(e);
            
            createWorld();
            create2DComponents();
            createCamera();
			
			addEventListener(Event.ENTER_FRAME, enterFrame);
		}
        override public function onRemovedFromStage(e:Event):void 
        {
            super.onRemovedFromStage(e);
            destroyWorld();
			
			removeEventListener(Event.ENTER_FRAME, enterFrame);
        }
		
		//Start framerate counter, displays framerate between 7 - 12 seconds after 12 seconds
		private var fps:Number = 30;
		private var timeinit:Date = new Date;
		private var lasttime:Number = timeinit.getMilliseconds();
		
		private var averagePooled:Number = 0;
		private var numbersInAverage:Number = 0;
		private var averageDisplayed:Boolean = false;
		
		private var framerateValues:Vector.<Number> = new Vector.<Number>();
		
		public function enterFrame(e:Event):void
		{
			var time:Date = new Date;
			var timepassed:Number = ((time.getMilliseconds() - lasttime) >= 0)?(time.getMilliseconds() - lasttime):(1000 + (time.getMilliseconds() - lasttime));
			
			lasttime = time.getMilliseconds();
			
			var totalDiff:Number = -(timeinit.valueOf() -  time.valueOf());
			if (totalDiff > 7000 && totalDiff < 12000)
			{
				averagePooled += timepassed;
				numbersInAverage++;
			}
			framerateValues.push(timepassed);
			
			if (totalDiff > 12000 && averageDisplayed == false)
			{
				averageDisplayed = true;
				trace("Total average: " + 1000 / (averagePooled / numbersInAverage));
				
			}
		}	
        
        protected var components:Vector.<Component2D> = new Vector.<Component2D>();
        override public function addChild(child:DisplayObject):DisplayObject 
        {
            var d:DisplayObject = super.addChild(child);
            
            if (child is Component2D)
            {
                components.push(Component2D(child));
            }
            
            return d;
        }  
        
        protected function createCamera():void 
        { 
        }
        
        protected function create2DComponents():void 
        {   
            for (var i:int = 0; i < components.length; i++)
            {
                add2DElement(components[i]);
            }            
        }
        
        public function add2DElement(component2D:Component2D):void 
        {     
            var isStatic:Boolean = component2D.isStatic;   
            var isKinematic:Boolean = component2D.isKinematic;           
            if (!isStatic && !isKinematic)
            {
                isStatic = component2D.rootName.toUpperCase().indexOf(staticPattern) == 0;
                isKinematic = component2D.rootName.toUpperCase().indexOf(kinematicPattern) == 0;
            }
            
            var bodyDef:b2BodyDef = new b2BodyDef();
            //bodyDef.type = isStatic ? b2Body.b2_staticBody : b2Body.b2_dynamicBody;
            if (isKinematic)
            {
                bodyDef.type = b2Body.b2_kinematicBody;
            }
            else if (isStatic)
            {
                bodyDef.type = b2Body.b2_staticBody;
            }
            
            else
            {
                bodyDef.type = b2Body.b2_dynamicBody;
            }
            
            var offset:b2Vec2 = (component2D.shapeDefs[0].isCircle) ?  component2D.shapeDefs[0][0]: new b2Vec2(0, 0);  
            bodyDef.position.Set((offset.x + component2D.x) / scale, (offset.y + component2D.y) / scale);
            bodyDef.angle = component2D.rotation / 180.0 * Math.PI;       
            
            var body:b2Body = world.CreateBody(bodyDef);            
            
            var sx:Number = component2D.scaleX;
            var sy:Number = component2D.scaleY;
            
            for (var i:int = 0; i < component2D.shapeDefs.length; i++)
            {           
                var pts:Array = component2D.shapeDefs[i];
                
                if (pts.isCircle)
                {
                    addCircleShape(body, component2D, pts);
                    //offset = pts[0];
                }
                else if(pts.isSpline)
                {
                    addSplineShape(body, component2D, pts, sx, sy);
                }  
                else
                {
                    addPolygonShape(body, component2D, pts, sx, sy);
                }                   
            }
            
            body.SetLinearDamping(0);
            body.SetSleepingAllowed(component2D.canSleep);
            body.SetUserData(component2D);  
            
            component2D.initializePhysics(body, world);
        }
        
        protected function addSplineShape(body:b2Body, component2D:Component2D, pts:Array, scaleX:Number, scaleY:Number):void 
        {              
            var vertices:Array = [];
            if ( (scaleX < 0 && scaleY > 0) || (scaleX > 0 && scaleY < 0) )
            {
                pts = pts.reverse();
            }
            for (var p:int = 0; p < pts.length; p++)
            {
                vertices[p] = new b2Vec2(pts[p].x / scale * scaleX, pts[p].y / scale * scaleY);
            }
               
            for (var i:int = 1; i < vertices.length; i++) 
            {
                var polyShape:b2PolygonShape = new b2PolygonShape();
                polyShape.SetAsEdge( vertices[i - 1], vertices[i] );  
                
                var fixtureDef:b2FixtureDef = new b2FixtureDef();
                fixtureDef.shape = polyShape; 
                fixtureDef.density = component2D.density;
                fixtureDef.friction = component2D.friction;
                fixtureDef.restitution = component2D.restitution;
                
                body.CreateFixture(fixtureDef); 
                
            }         
        }
        
        protected function addPolygonShape(body:b2Body, component2D:Component2D, pts:Array, scaleX:Number, scaleY:Number):void 
        {              
            var vertices:Array = [];
            if ( (scaleX < 0 && scaleY > 0) || (scaleX > 0 && scaleY < 0) )
            {
                pts = pts.reverse();
            }
            for (var p:int = 0; p < pts.length; p++)
            {
                vertices[p] = new b2Vec2(pts[p].x / scale * scaleX, pts[p].y / scale * scaleY);
            }
                        
            var polyShape:b2PolygonShape = new b2PolygonShape();
            polyShape.SetAsArray( vertices, pts.length );
            
            var fixtureDef:b2FixtureDef = new b2FixtureDef();         
            fixtureDef.shape = polyShape;   
            fixtureDef.density = component2D.density;
            fixtureDef.friction = component2D.friction;
            fixtureDef.restitution = component2D.restitution;   
            
            body.CreateFixture(fixtureDef);         
        }
        
        protected function addCircleShape(body:b2Body, component2D:Component2D, pts:Array):void 
        {              
            var circShape:b2CircleShape = new b2CircleShape(pts[1] / scale);
            
            var fixtureDef:b2FixtureDef = new b2FixtureDef();
            fixtureDef.shape = circShape;
            fixtureDef.density = component2D.density;
            fixtureDef.friction = component2D.friction;
            fixtureDef.restitution = component2D.restitution;        
            
            body.CreateFixture(fixtureDef);   
        }
        
		protected function createWorld():void
		{            
            scale = world2DMetrics.scale;
            timeStep = world2DMetrics.timeStep;
            velocityIterations = world2DMetrics.velocityIterations;
            positionIterations = world2DMetrics.positionIterations;
            
			var w:int = (world2DMetrics.width == -1) ? stage.stageWidth : world2DMetrics.width;
			var h:int = (world2DMetrics.height == -1) ? stage.stageHeight : world2DMetrics.height;
								
			var gravity:b2Vec2 = new b2Vec2(world2DMetrics.gravityX, world2DMetrics.gravityY);
			world = new b2World(gravity, world2DMetrics.allowSleep);	
			world.SetWarmStarting(true);            
            
			world.SetContactListener(new ContactListener(ContactManager.instance));
                    
            if (debugDraw)
            {
                setupDebugDraw();
            }            
        }
		protected function destroyWorld():void
		{ 
            var c:b2Contact = world.GetContactList();
            while (c != null)
            {
                c.SetEnabled(false);
                c = c.GetNext();
            } 
            
            var j:b2Joint = world.GetJointList();
            while (j != null)
            {
                world.DestroyJoint(j);
                j = j.GetNext();
            } 
            
            var b:b2Body = world.GetBodyList();
            while (b != null)
            {
                b.SetUserData(null);
                world.DestroyBody(b);
                b = b.GetNext();
            } 
			world.SetContactListener(null);
        }
        
        private var debugLayer:Sprite;
		public function setupDebugDraw():void
		{
            if (debugLayer == null)
            {
                debugLayer = new Sprite();
                this.addChild(debugLayer);
                this.setChildIndex(debugLayer, this.numChildren - 1);
            }
			var dbgDraw:b2DebugDraw = new b2DebugDraw();
			dbgDraw.SetSprite(debugLayer);
			dbgDraw.SetDrawScale(scale);
			dbgDraw.SetFillAlpha(0.3);
			dbgDraw.SetLineThickness(1.0);
			dbgDraw.SetFlags(b2DebugDraw.e_shapeBit | b2DebugDraw.e_jointBit);
			world.SetDebugDraw(dbgDraw);            
        }
        
		public function setBounds(x:Number, y:Number, w:Number, h:Number):void
		{
			var overlap:Number = 10;
			var thickness:Number = 100;
            
			var top:b2Body = addBoxToWorld(-overlap + x, -thickness + y, w + overlap * 2, thickness);
			var bottom:b2Body = addBoxToWorld(-overlap, h, w + overlap * 2, thickness);
			var left:b2Body = addBoxToWorld(-thickness+ x, -overlap + y, thickness, h + overlap * 2);
			var right:b2Body = addBoxToWorld(w, -overlap, thickness, h + overlap * 2);			
		}
		
		protected function addBoxToWorld(x:Number, y:Number, w:Number, h:Number):b2Body
		{
			x /= scale;
			y /= scale;
			w /= scale;
			h /= scale;
            
            var boxShape:b2PolygonShape = new b2PolygonShape();
			var bodyDef:b2BodyDef = new b2BodyDef();
            var body:b2Body;
            
			bodyDef.position.Set(x + w / 2.0, y + h / 2.0);
			//bodyDef.position.Set(x, y);
            boxShape.SetAsBox(w / 2.0, h / 2.0);
            
			//var polyDef:b2PolygonDef = new b2PolygonDef();
			//polyDef.vertexCount = 4;
			//polyDef.vertices[0].Set(0,0);
			//polyDef.vertices[1].Set(w,0);
			//polyDef.vertices[2].Set(w,h);
			//polyDef.vertices[3].Set(0, h);
            
            body = world.CreateBody(bodyDef);
            body.CreateFixture2(boxShape);
			
			return body;			
		}
        
		public function updateMouseWorld():void
        {
			//mouseXWorldPhys = (Input.mouseX)/scale; 
			//mouseYWorldPhys = (Input.mouseY)/scale; 
			//
			//mouseXWorld = (Input.mouseX); 
			//mouseYWorld = (Input.mouseY); 
		}
		
		//override public function addEventListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false):void 
		//{
		//super.addEventListener(type, listener, useCapture, priority, useWeakReference);
		//}
		
        public function updateCamera(elapsed:uint):void 
        {
            
        }
        override public function update(elapsed:uint):void 
        {
            super.update(elapsed);
			// Update mouse joint
			//updateMouseWorld()
			//mouseDestroy();
			//mouseDrag();
			
			// Update physics
			if (isWorldActive)
			{
				var physStart:uint = getTimer();
				world.Step(timeStep, velocityIterations, positionIterations);
				world.ClearForces();
			}
			
			// Render
			world.DrawDebugData();
            
			if (isWorldActive)
			{
				// bodies
				for (var b:b2Body = world.GetBodyList(); b; b = b.GetNext())
				{
					if (b.GetUserData() is Component2D)
					{
						var c2d:Component2D = Component2D(b.GetUserData());
						c2d.updatePhysics(elapsed, b, world);
						c2d.updateView(elapsed, b, scale);
					}
				}
				updateCamera(elapsed);
			}
		}
        
    }
}