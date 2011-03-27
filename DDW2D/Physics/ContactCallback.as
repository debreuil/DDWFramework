package DDW2D.Physics 
{
    public class ContactCallback
    {
		public var callbacks:Vector.<Function>;
		
		public function ContactCallback(f:Function)
		{
			callbacks = new Vector.<Function>();
			addCallback(f);
		}
		
		public function addCallback(f:Function) : void
		{
			callbacks.push(f);
		}
		
		public function removeCallback(f:Function) : void
		{
			for (var i:int = 0; i < callbacks.length; i++) 
			{
				if (callbacks[i] == f)
				{
					callbacks.splice(i, 1);
					break;
				}
			}
		}
    }
}