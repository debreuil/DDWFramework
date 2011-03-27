package DDW.Enums
{
	public class ModuleState
	{
		public static var None:int				= 0;
		public static var Playroom :int			= 1000;		

		public static var Drawer:int			= 2000;
		public static var Poster:int			= 3000;		
		public static var Piano:int 			= 4000;
		public static var Bowl:int		 		= 5000;
		public static var Shade:int		 		= 6000;
		public static var Computer:int 			= 7000;
		public static var Door:int		 		= 8000;
		
		private static var strings:Array = 
		[
		"None", "Playroom", "Drawer", "Poster", "Piano", "Bowl", "Shade", "Computer", "Door" ];
		public static function getName(index:int):String
		{
			var err:Boolean = false
			if(index > 8000)
			{
				err = true;
			}
			
			var arIndex:int = Math.floor(index / 1000);
			if(arIndex * 1000 != index)
			{
				err = true;
			}
			
			if(err)
			{
				throw(new Error("index not valid member of ModuleState"));
			}
			else
			{
				return strings[arIndex];
			}
		}
		public static function indexOf(s:String):int
		{
			var result:int = -1;
			var i:int = 0;
			for(; i < strings.length; i++)
			{
				if(s.toLowerCase() == strings[i].toLowerCase())
				{
					break;
				}
			}
			if(i == strings.length)
			{
				i = -1;
			}
			switch(i)
			{
				case -1:
				case 0:
					result = None;
					break;
				case 1:
					result = Playroom;
					break;
				case 2:
					result = Drawer;
					break;
				case 3:
					result = Poster;
					break;
				case 4:
					result = Piano;
					break;
				case 5:
					result = Bowl;
					break;
				case 6:
					result = Shade;
					break;
				case 7:
					result = Computer;
					break;
				case 8:
					result = Door;
					break;
			}
			return result;
		}
	}
}