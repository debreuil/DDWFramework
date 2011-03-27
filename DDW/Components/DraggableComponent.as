package DDW.Components
{
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.events.MouseEvent;

	public class DraggableComponent extends Component
	{	
		public var $mc:MovieClip;
		
		public var startDragCallback:Function;
		public var draggingCallback:Function;
		public var dropCallback:Function;
		
		public function DraggableComponent(autoLayout:DisplayObject)
		{
			super(autoLayout);
		}
		
		protected override function initializeComponent():void
		{			
			this.addEventListener(MouseEvent.MOUSE_DOWN, this.onMouseDown, false, 0, true);	
			this.addEventListener(MouseEvent.MOUSE_UP, this.onMouseUp, false, 0, true);	
		}
		protected function onMouseDown(e:MouseEvent):void
		{		
			if(this.$mc != null && this.isEnabled)
			{
				//this.addEventListener(MouseEvent.MOUSE_MOVE, this.onDrag, false, 0, true);	
				//this.parent.setChildIndex(this, this.parent.numChildren - 1);
				//this.startDrag(false);
				if(startDragCallback != null)
				{
					startDragCallback(e);
				}
			}
		}
		public function onMouseUp(e:MouseEvent):void
		{	
			this.removeEventListener(MouseEvent.MOUSE_MOVE, this.onDrag);
			if(this.$mc != null && this.isEnabled)
			{
				this.stopDrag();
				if(dropCallback != null)
				{
					dropCallback(e);
				}
			}
		}
		public function onDrag(e:MouseEvent):void
		{	
			if(draggingCallback != null)
			{
				draggingCallback(e);
			}
		}
		public override function enable():void
		{	
			super.enable();
			if(this.$mc != null)
			{
				this.$mc.gotoAndStop(1);
			}
		}
		public override function disable():void
		{	
			super.disable();
			if(this.$mc != null)
			{
				this.$mc.gotoAndStop(2);
			}
		}
	}
}