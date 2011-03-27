package DDW.Components
{
	import flash.display.MovieClip;
	
	public class FrameButton extends DefaultButton
	{
		public function FrameButton(mc:MovieClip)
		{
			super(mc);
		}
		
		protected override function playButton():void
		{
			if(this.isEnabled || this.$center.totalFrames < 4)
			{
				this.$center.gotoAndStop(2);
			}
			else
			{
				this.$center.gotoAndStop(4);					
			}
		}
		public override function stopButton():void
		{		
			if(this.isEnabled || this.$center.totalFrames < 4)
			{
				this.$center.gotoAndStop(1);
			}
			else
			{
				this.$center.gotoAndStop(4);					
			}
		}
	}
}