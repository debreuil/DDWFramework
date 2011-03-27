package DDW.Components 
{
    import flash.display.DisplayObject;
    public class PlayableButton extends DefaultButton
    {
        
        public function PlayableButton(autoLayout:DisplayObject):void
		{
			super(autoLayout);
        }
        
        override protected function playButton():void 
        {
            $center.filters = glow;
        }
        override public function stopButton():void 
        {
            $center.filters = null;
        }
        override protected function clickButton():void 
        {
            $center.filters = null;
            if ($center.currentFrame == 1)
            {
                $center.gotoAndPlay(2);
            }
        }
    }

}