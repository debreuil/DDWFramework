package DDW2D.Managers 
{
    import Box2D.Collision.*;
    import Box2D.Collision.Shapes.*;
    import Box2D.Common.Math.*;
    import Box2D.Dynamics.*;
    import Box2D.Dynamics.Joints.*;
    import flash.display.*;
    import flash.events.*;
	
	
	public class RaycastManager
	{
		public var p1:b2Vec2;
		public var p2:b2Vec2;
        
		private var callbackFixture:b2Fixture;
		private var callbackPoint:b2Vec2;
		private var callbackFraction:Number;
		
		private var categoryBits:uint;
		private var maskBits:uint;
		private var groupIndex:int;
		
		public function RaycastManager(startPoint:b2Vec2, endPoint:b2Vec2) 
		{
			this.p1 = startPoint;
			this.p2 = endPoint;
		}
		
		// This is the callback to use
		//
		//    private function OnRaycast(body:b2Body, contactPoint:b2Vec2, direction:b2Vec2) : void
		//
		public function sendRaycast(callback:Function, world:b2World, categoryBits:uint = 1, maskBits:uint = 0xFFFF, groupIndex:int = 0) : Boolean
		{
			//trace(filter);
			//this.filter = filter;
			this.categoryBits = categoryBits;
			this.maskBits = maskBits;
			this.groupIndex = groupIndex;
            var result:Boolean = false;
            
			callbackFixture = null;
			callbackFraction = 1000000;
			world.RayCast(closestPointCallback, p1, p2);
			
			if (callbackFixture != null)
			{
				var direction:b2Vec2 = p2.Copy();
				direction.Subtract(p1);
				direction.Normalize();
				
				if (callback != null)
				{
					callback(callbackFixture.GetBody(), callbackPoint, direction);
					result = true;
				}
			}
			return result;
		}		
		
		private function closestPointCallback(fixture:b2Fixture, point:b2Vec2, normal:b2Vec2, fraction:Number) : Number
		{
			// Is sensor
			if (fixture.IsSensor())
			{
				return fraction;
			}
			
			// Negative group Index
			if (groupIndex < 0 && groupIndex == fixture.GetFilterData().groupIndex)
			{
				return fraction;
			}
			
			// Mask bits or positive group index
			if (!(groupIndex > 0 && groupIndex == fixture.GetFilterData().groupIndex) && 
			((categoryBits & fixture.GetFilterData().maskBits) == 0 || (maskBits & fixture.GetFilterData().categoryBits) == 0 ))
			{
				return fraction;
			}
			
			if (fraction < callbackFraction)
			{
				this.callbackFraction = fraction;
				this.callbackFixture = fixture;
				this.callbackPoint = point;
			}
			
			return fraction;
		}
	}

}