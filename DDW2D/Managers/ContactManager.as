package DDW2D.Managers 
{
    import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2Fixture;
    import DDW2D.Components.Component2D;
    import DDW2D.Physics.ContactCallback;
    import DDW2D.Physics.ContactInfo;
	
	public class ContactManager
	{
		private var eventHash:Object = {};
		
		public function ContactManager() 
		{
		}
		
        private static var _instance:ContactManager;
        public static function get instance():ContactManager 
        { 
            if (_instance == null)
            {
                _instance = new ContactManager();
            }
            return _instance;
        }
        
		// This callback returns two Component2Ds
		// a = Component2D passed in
		// b = Component2D colliding with
		// contactInfo = information about collision
		//  -- example --
		// private function OnContact(a:Component2D, b:Component2D, contactInfo:ContactInfo) : void
		//  -------------
		public function addEvent(component2d:Component2D, callback:Function) : void
		{
			if (eventHash[component2d.guid] == null)
			{
				eventHash[component2d.guid] = new ContactCallback(callback);
			}
			else
			{
				ContactCallback(eventHash[component2d.guid]).addCallback(callback);
			}
		}
		
		public function removeEvents(component2D:Component2D) : void
		{
			eventHash[component2D.guid] = null;
		}
		
		public function raiseContactEvent(a:b2Body, b:b2Body, contactInfo:ContactInfo) : void
		{
			onCollision(a, b, contactInfo.clone());
			
			// Flip normal for object B
			contactInfo.normal.Multiply( -1);
			contactInfo.impulse.Multiply( -1);
			var temp:b2Fixture = contactInfo.fixture1;
			contactInfo.fixture1 = contactInfo.fixture2;
			contactInfo.fixture2 = temp;
			onCollision(b, a, contactInfo);
		}
		
		private function onCollision(a:b2Body, b:b2Body, contactInfo:ContactInfo) : void
		{
			if (a != null && a.GetUserData() is Component2D)
            {
                var c:Component2D = Component2D(a.GetUserData());
                if(eventHash[c.guid] != null)
                {
                    for each (var callback:Function in ContactCallback(eventHash[c.guid]).callbacks) 
                    {
                        callback(a, b, contactInfo);
                    }
                }
            }
		}
		
	}
}