package DDW2D.Physics 
{	
    import Box2D.Collision.*;
    import Box2D.Collision.Shapes.*;
    import Box2D.Common.Math.*;
    import Box2D.Dynamics.*;
    import Box2D.Dynamics.Contacts.b2Contact;
    import DDW2D.Components.*;
    import DDW2D.Managers.ContactManager;
	
	public class ContactListener extends b2ContactListener
	{
		private var contactManager:ContactManager;
		
		public function ContactListener(contactManager:ContactManager) 
		{
			this.contactManager = contactManager;
		}
		
		override public function BeginContact(contact:b2Contact):void 
		{
			super.BeginContact(contact);
			
			// Special case for sensors, since there is no "Post Solve" for them
			contact.GetManifold().m_localPoint
			var bodyA:b2Body = contact.GetFixtureA().GetBody();
			var bodyB:b2Body = contact.GetFixtureB().GetBody();
			
			if (bodyA.GetFixtureList().IsSensor() || bodyB.GetFixtureList().IsSensor())
			{
				var contactInfo:ContactInfo = new ContactInfo(new b2Vec2(0, 0), new b2Vec2(0, 0), new b2Vec2(0, 0), new b2Vec2(0, 0), 0, contact.GetFixtureA(), contact.GetFixtureB());
				contactManager.raiseContactEvent(bodyA, bodyB, contactInfo);
			}
		}
		
		override public function EndContact(contact:b2Contact):void 
		{
			super.EndContact(contact);
		}
		
		override public function PreSolve(contact:b2Contact, oldManifold:b2Manifold):void 
		{
			super.PreSolve(contact, oldManifold);
		}
		
		override public function PostSolve(contact:b2Contact, impulse:b2ContactImpulse):void 
		{
			super.PostSolve(contact, impulse);
			
			contact.GetManifold().m_localPoint
			var bodyA:b2Body = contact.GetFixtureA().GetBody();
			var bodyB:b2Body = contact.GetFixtureB().GetBody();
			
			// Gets the contact point
			var worldManifold:b2WorldManifold = new b2WorldManifold();
			contact.GetWorldManifold(worldManifold);
			var p1:b2Vec2 = worldManifold.m_points[0];
			var p2:b2Vec2 = worldManifold.m_points[1];
			if (contact.GetManifold().m_pointCount < 2)
			{
				p2 = null;
			}
			
			// Impact vector
			var normalImpulse:b2Vec2 = worldManifold.m_normal.Copy();
			normalImpulse.Multiply(impulse.normalImpulses[0]);
			var perpImpulse:b2Vec2 = new b2Vec2(-worldManifold.m_normal.y, worldManifold.m_normal.x);
			perpImpulse.Multiply(impulse.tangentImpulses[0]);
			if (contact.GetManifold().m_pointCount > 1)
			{
				normalImpulse.Multiply(impulse.normalImpulses[1]);
				perpImpulse.Multiply(impulse.tangentImpulses[1]);
			}
			normalImpulse.Add(perpImpulse);
			
			// Intensity of impact
			var intensity:Number = (normalImpulse.x * normalImpulse.x) + (normalImpulse.y * normalImpulse.y);
			intensity = Math.sqrt(intensity);
			
			// Raises event in Contact Manager
			var contactInfo:ContactInfo = new ContactInfo(p1, p2, worldManifold.m_normal.Copy(), normalImpulse, intensity, contact.GetFixtureA(), contact.GetFixtureB());
			contactManager.raiseContactEvent(bodyA, bodyB, contactInfo);
		}
	}

}