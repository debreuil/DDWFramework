package DDW.Managers 
{
    import DDW.Media.MediaCommand;
    public class Sequencer
    {
        private static var _instance:Sequencer;
		private static var singletonLock:Boolean = false;
        
		private var playlist:Array = [];
                
        
        public function Sequencer() 
        {            
            if (singletonLock != true)
            {
                throw new Error("Sequencer is a singleton");
            }
        }
        public static function get instance():Sequencer
        {
            if (_instance == null)
            {
                singletonLock = true;
                _instance = new Sequencer();
                singletonLock = false;
            }
            return _instance;
        }
        
		public function get currentCommand():MediaCommand
		{
            var result:MediaCommand = null;
            if (playlist.length > 0)
            {
                result = MediaCommand(playlist[0]);
            }
            return result;
        }
		public function get isPlaying():Boolean
		{
            var result:Boolean = playlist.length > 0;
            if (result)
            {
                result = MediaCommand(playlist[0]).isPlaying;
            }
			return result;
		}
		public function get isPaused() :Boolean
		{
            var result:Boolean = playlist.length > 0;
            if (result)
            {
                result = MediaCommand(playlist[0]).isPaused;
            }
			return result;
		}
        
		public function append(command:MediaCommand):void
		{
            playlist.push(command);
        }
		public function appendList(commands:Array):void
		{
            for (var i:int = 0; i < commands.length; i++) 
            {
                if (commands[i] is MediaCommand)
                {
                    playlist.push(commands[i]);  
                }
                else
                {
                    throw new Error("Only MediaCommand elements can be appended to Sequencer.");
                }
            }
        }
		public function play():void
		{
            if (playlist.length > 0 && !MediaCommand(playlist[0]).isPlaying)
            {
                MediaCommand(playlist[0]).play();
            }
		}
		public function pause():void
		{
            if (playlist.length > 0)
            {
                MediaCommand(playlist[0]).pause();
            }
		}
		public function resume():void
		{
            if (playlist.length > 0)
            {
                MediaCommand(playlist[0]).resume();
            }
		}
		public function stop():void
		{
            if (playlist.length > 0)
            {
                MediaCommand(playlist[0]).stop();
                playlist.shift();
            }
		}
		public function stopAndClear():void
		{
			stop();
            playlist.splice(0); 
		}
        
		public function next():void
		{
            playlist.shift();
            play();
		}
        
		public function update(elapsed:uint):void
		{
            if (playlist.length > 0) 
            {
                MediaCommand(playlist[0]).update(elapsed);
                if (MediaCommand(playlist[0]).isComplete)
                {
                    next();
                }
            }
        }

		public function dispose():void
		{
            stopAndClear(); 
            playlist = null;
		}
        
    }

}