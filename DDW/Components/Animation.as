package DDW.Components
{
	import DDW.Screens.Screen;
	
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;

	public class Animation extends Screen
	{
		public var clipClass:Class;
		public var clip:MovieClipPlus;
		
		public function Animation(autoLayout:DisplayObject, clipClass:Class)
		{
			super(null); // ignore autolayout
			this.clipClass = clipClass;
			//this.$clip.completeCallback = onClipComplete;
		}
		
		public override function onAddedToStage(e:Event):void
		{
			super.onAddedToStage(e);
			
			clip = new MovieClipPlus(new clipClass());
			this.addChild(clip);
			clip.playOnce(onClipComplete);	
		}
		public override function onRemovedFromStage(e:Event):void
		{
			super.onRemovedFromStage(e);
			if(clip != null)
			{
				clip.stop();
				if(this.contains(clip))
				{
					this.removeChild(clip);
				}
				clip = null;
			}	
		}
		
		public function onClipComplete(e:Event):void
		{	
		}
	}
}