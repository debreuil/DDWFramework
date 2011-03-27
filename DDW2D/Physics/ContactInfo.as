package DDW2D.Physics
{
    import Box2D.Collision.*;
    import Box2D.Collision.Shapes.*;
    import Box2D.Common.Math.*;
    import Box2D.Dynamics.*;
	
		
	public class ContactInfo
	{
		public var p1:b2Vec2;
		public var p2:b2Vec2;
		public var normal:b2Vec2;
		public var impulse:b2Vec2;
		public var intensity:Number;
		public var fixture1:b2Fixture;
		public var fixture2:b2Fixture;
		
		public function ContactInfo(p1:b2Vec2, p2:b2Vec2, normal:b2Vec2, impulse:b2Vec2, intesity:Number, fixture1:b2Fixture, fixture2:b2Fixture) 
		{
			this.p1 = p1;
			this.p2 = p2;
			this.normal = normal;
			this.impulse = impulse;
			this.intensity = intesity;
			this.fixture1 = fixture1;
			this.fixture2 = fixture2;
		}
		
		public function clone() : ContactInfo
		{
			return new ContactInfo(p1.Copy(), (p2 == null) ? null : p2.Copy(), normal.Copy(), impulse.Copy(), intensity, fixture1, fixture2);
		}
	}

}