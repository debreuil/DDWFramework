package DDW.Utilities
{
	import DDW.Interfaces.*;
	
	public class ShuffledList implements ISerializable
	{
		public var length:int;
		private var list:Array;
		public var index:uint = 0;
		private var firstShuffle:Boolean = true;
		
		public function ShuffledList(list:Array)
		{
			if(list.length == 0)
			{
				//throw;
			}
			this.length = list.length;
			this.list = list;
			this.reset();
			this.reset();
		}
		public function getCurrent():Object
		{
			var result:Object = list[index];
			return result;
		}
		public function getNext():Object
		{
			var result:Object = list[index];
			index++;
			if(index >= list.length)
			{
				reset();
			}
			return result;
		}
		public function peekNext():Object
		{
			var result:Object = list[index];
			return result;
		}
		public function reset():void
		{
			this.index = 0;
			this.shuffle();			
		}
		
		private function shuffle():void
		{
			if(list.length < 3) // dont shuffle 2 items - this results in the desired repeating 121212.
			{
				return;
			}
			var prevLastItem:Object = list[list.length - 1];
			var temp:int;
			var obj:Object;
			for(var i:int = 0; i < list.length; i++)
			{
				temp = Math.floor(Math.random() * list.length);
				obj = list[i];
				list[i] = list[temp];
				list[temp] = obj;
			}
			// prevent possible repeat of last and first objects after shuffle
			if(!firstShuffle && list.length > 1 && (list[0] == prevLastItem))
			{
				temp = Math.floor(Math.random() * (list.length - 1) + 1);
				obj = list[0];
				list[0] = list[temp];
				list[temp] = obj;				
			}
			firstShuffle = false;
		}
		public function contains(o:Object):Boolean
		{
			var result:Boolean = false;
			for(var i:int = 0; i < this.list.length; i++)
			{
				if(o == list[i])
				{
					result = true;
					break;
				}
			}
			return result;
		}
		public function serialize():Object
		{
			return {index:index,list:list};
		}
		public function deserialize(o:Object):void
		{
			if(o.index != null && o.list != null)
			{
				this.index = o.index;
				this.list = o.list;
			}
		}
		
		public static function shuffleArray(lst:Array):void
		{
			for(var i:int = 0; i < lst.length; i++)
			{
				var rnd:Number = Math.floor(Math.random() * lst.length);
				var temp:Object = lst[i];
				lst[i]= lst[rnd];
				lst[rnd] = temp;
			}
		}
		
		public function toString():String
		{
			return this.list.toString();
		}
	}
}