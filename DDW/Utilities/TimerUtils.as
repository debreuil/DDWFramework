package DDW.Utilities
{
	public class TimerUtils
	{
		public static function getMinSecFormat(sec:Number):String
		{
			sec = Math.round(sec);
			var m:Number = Math.floor(sec / 60);
			var s:String = (sec % 60).toString();
			s = (s.length < 2) ? "0" + s : s.substr(0, 2)
			var result:String = m + "." + s;
			return result;			
		}

	}
}