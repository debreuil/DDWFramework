package DDW2D.Utils 
{
	import Box2D.Common.Math.*;
	import Box2D.Common.*;
	import Box2D.Dynamics.*;
    import DDW2D.Screens.Screen2D;
	import flash.display.*;
	import flash.geom.Rectangle;
	
    // todo: camera should not be dependant on box2d if easy
    // (non box2d games may want to use it)
	public class ScreenCamera
	{
		private var target:b2Vec2;
		private var position:b2Vec2;
		private var velocity:b2Vec2;
		
		private var targetOffset:b2Vec2;
		public var offset:b2Vec2;
		private var velocityOffset:b2Vec2;
		
		public var screenSize:b2Vec2;
		
		public var offsetEnabled:Boolean = false;
		
		//Shake
		private var shakeIntensity:Number = 0.0;
		private const shakeIntensityDamping:Number = 0.9;
		
		private var shakeLocation:b2Vec2;
		private var shakeVelocity:b2Vec2;
		private const shakeVelocityDamping:Number = 0.85;
		private const shakeSpringStrength:Number = 0.2;
		
		private var clampedPosition:b2Vec2;
		public function get Position():b2Vec2
		{
			return clampedPosition;
		}
		
		public function ScreenCamera(screenSize:b2Vec2) 
		{
			this.screenSize = screenSize;
			
			target = new b2Vec2(0, 0);
			position = new b2Vec2(0, 0);
			velocity = new b2Vec2(0, 0);
			clampedPosition = new b2Vec2(0, 0);
			
			targetOffset = new b2Vec2(0, 0);
			offset = new b2Vec2(0, 0);
			velocityOffset = new b2Vec2(0, 0);
			
			shakeLocation = new b2Vec2(0, 0);
			shakeVelocity = new b2Vec2(0, 0);
		}
		
		public function setCameraShake(intensity:Number):void
		{
			shakeIntensity = intensity * 2;
			//shakeLocation.x += (Math.random() - 0.5) * 2 * intensity;
			//shakeLocation.y += (Math.random() - 0.5) * 2 * intensity;
		}
		
		public function update(timeStep:Number) : void
		{
			// Spring
			var diff:b2Vec2 = target.Copy();
			diff.Subtract(position);
			diff.Multiply(0.02);
			velocity.Add(diff);
			
			var diff2:b2Vec2 = targetOffset.Copy();
			diff2.Subtract(offset);
			diff2.Multiply(0.5);
			velocityOffset.Add(diff2);
			
			// Update position
			position.Add(velocity);
			offset.Add(velocityOffset);
			
			// Damping
			velocity.Multiply(0.8);
			offset.Multiply(0.2);
			
			//Shake
			shakeLocation.Add(shakeVelocity);
			
			var springForce:b2Vec2 = shakeLocation.Copy();
			springForce.Multiply(shakeSpringStrength);
			shakeVelocity.Subtract(springForce);
			
			shakeVelocity.Multiply(shakeVelocityDamping);
			
			shakeVelocity.x += (Math.random() - 0.5) * 2 * shakeIntensity;
			shakeVelocity.y += (Math.random() - 0.5) * 2 * shakeIntensity;
			
			shakeIntensity *= shakeIntensityDamping;
		}
		
		public function updateView(screen:DisplayObject, bounds:Rectangle, scale:Number) : void
		{
			var drawPosition:b2Vec2 = position.Copy();
			if (offsetEnabled)
			{
				drawPosition.Add(offset);
			}
			
			// Update screen
			screen.x = drawPosition.x * scale * -1 + screenSize.x / 2;
			screen.y = drawPosition.y * scale * -1 + screenSize.y / 2;
			
			clampToBounds(screen, bounds);
			
			//Camera shake
			screen.x += shakeLocation.x;
			screen.y += shakeLocation.y;
			
			clampedPosition = new b2Vec2(screen.x, screen.y);
			//clampToBounds(screen, bounds);
		}
		
		private function clampToBounds(screen:DisplayObject, bounds:Rectangle):void
		{
			if (screen.x > bounds.x)
			{
				screen.x = bounds.x;
			}
			
			if (screen.y > bounds.y)
			{
				screen.y = bounds.y;
			}
			
			if (screen.y < bounds.height - screenSize.y)
			{
				screen.y = bounds.height - screenSize.y;
			}
			
			if (screen.x < -(bounds.width - screenSize.x))
			{
				screen.x = -(bounds.width - screenSize.x);
			}
		}
		
		public function setPosition(xPos:Number, yPos:Number) : void
		{
			this.position = new b2Vec2(xPos, yPos);
			this.target = new b2Vec2(xPos, yPos);
		}
        
		public function updateTarget(xPos:Number, yPos:Number) : void
		{
			this.target = new b2Vec2(xPos, yPos);
		}
		
		public function updateTargetOffset(xPos:Number, yPos:Number) : void
		{
			this.targetOffset = new b2Vec2(xPos, yPos);
		}
		
		public function findTargetOffset(screen:Screen2D, scaleToScreen:Boolean = false) : b2Vec2
		{
			var diff:b2Vec2 = target.Copy();
			diff.Subtract(position);
			//diff.Add(positionOffset);
			if (scaleToScreen)
			{
				diff.Multiply(screen.scale);
			}
			return diff;
		}
	}

}