package DDW.Enums
{
	public class GameType
	{
		public static var None:int		= 0;
		public static var CD :int		= 1;
		public static var Online:int	= 2;
		
		public static function indexOf(s:String):int
		{
			var result:int = -1;
			switch(s.toUpperCase())
			{
				case "NONE":
					result = None;
					break;
				case "CD":
					result = CD;
					break;
				case "ONLINE":
					result = Online;
					break;
				default :
					throw(new Error("string not member of GameType"));
			}
			return result;
		}
		public function getName(index:int):String
		{			
			var result:String = "";
			switch(index)
			{				
				case None:
					result = "None";
					break;
				case CD:
					result = "CD";
					break;
				case Online:
					result = "Online";
					break;	
				default :
					throw(new Error("index not member of GameType"));
			}
			return result;
		}
	}
}