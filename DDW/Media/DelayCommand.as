package DDW.Media 
{
    import DDW.Managers.Sequencer;
    public class DelayCommand extends MediaCommand
    {        
        public var msDelay:uint;
        public var curMs:uint = 0;
        
        public function DelayCommand(msDelay:uint, callback:Function = null, disableCursor:Boolean = false) 
        {
            super(null, callback, disableCursor);
            this.msDelay = msDelay;
        }        
        
		public override function reset():void
		{        
            super.reset();
            curMs = 0;
        }
        
		public override function update(elapsed:uint):void
        {
            curMs += elapsed;
            if (curMs >= msDelay)
            {
                onComplete();
            }
        }
        
        public static function createDelay(msDelay:uint, callback:Function = null, disableCursor:Boolean = false):DelayCommand
        {            
            var result:DelayCommand = new DelayCommand(msDelay, callback, disableCursor);
            Sequencer.instance.append(result);
            return result;
        }
    }

}