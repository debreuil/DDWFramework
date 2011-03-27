package DDW.Components
{
	import DDW.Interfaces.*;
	import DDW.Managers.*;
	
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import flash.text.TextField;
	
	public class DefaultButton extends Component implements ITimeoutPlayer
	{
		public var $center:MovieClip;
		public var $txLabel:TextField; // optional
		
		public var isOver:Boolean;
		public var userVar:int = 0;
		public var userObject:Object = {};
		public static var glow:Array = [new GlowFilter(0xFFFFFF)];
		public var userGlow:GlowFilter;
		
		public function DefaultButton(autoLayout:DisplayObject):void
		{
			super(autoLayout);
		}
		
		protected override function initializeComponent():void
		{			
			this.addEventListener(MouseEvent.MOUSE_UP, this.onClick, false, 0, true);	
			this.addEventListener(MouseEvent.ROLL_OVER, this.onRollOver, false, 0, true);
			this.addEventListener(MouseEvent.ROLL_OUT, this.onRollOut, false, 0, true);
			
			this.isOver = false;
            
			if(this.$center != null)
			{
				this.$center.gotoAndStop(1);
			}	
		}
		
		public override function enable():void
		{
			super.enable();
			if(this.$center != null && this.$center.totalFrames > 1)
			{
				this.$center.gotoAndStop(1);
			}
		}
		public override function disable():void
		{
			super.disable();
			this.stopButton();
		}
		public function manualClick():void
		{			
			onClick(new MouseEvent("MANUAL"))
		}
		public function manualOver():void
		{			
			onRollOver(new MouseEvent("MANUAL"))
		}
		public function manualOut():void
		{			
			onRollOut(new MouseEvent("MANUAL"))
		}
		protected function onDown(event:MouseEvent):void
		{            
        }
		protected function onClick(event:MouseEvent):void
		{
			if(this.isEnabled && isCursorActive())
			{
                clickButton();
			
				if(this.parent is IButtonContainer)
				{
					IButtonContainer(this.parent).clickButtonHandler(this, event);
				}
				else if(this.parent.parent is IButtonContainer)
				{
					IButtonContainer(this.parent.parent).clickButtonHandler(this, event);
				}
				event.updateAfterEvent();
				//clickCallback(event);
			}
		}
		protected function onRollOver(event:MouseEvent):void
		{
			if(this.isEnabled && isCursorActive() && !this.isOver)
			{
				if(this.parent is IButtonContainer)
				{
					IButtonContainer(this.parent).rollOverButtonHandler(this, event);
				}
				else if(this.parent.parent is IButtonContainer)
				{
					IButtonContainer(this.parent.parent).rollOverButtonHandler(this, event);
				}
				playButton();
			}	
			this.isOver = true;	
		}
		protected function onRollOut(event:MouseEvent):void
		{
			if(this.isEnabled && isCursorActive())
			{
				this.stopButton();
				if(this.parent is IButtonContainer)
				{
					IButtonContainer(this.parent).rollOutButtonHandler(this, event);
				}
				else if(this.parent.parent is IButtonContainer)
				{
					IButtonContainer(this.parent.parent).rollOutButtonHandler(this, event);
				}
			}	
			this.isOver = false;		
		}
        
		protected function clickButton():void
		{		            
            if(this.$center != null && this.$center.totalFrames > 2)
            {
                this.$center.gotoAndStop(3);
            }
        }
		protected function playButton():void
		{		
			if(this.$center != null && this.$center.totalFrames > 1)
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
			else
			{
				if(userGlow != null)
				{
					this.filters = [userGlow];					
				}
				else
				{
					this.filters = glow;
				}
			}
		}
		public function stopButton():void
		{		
			if(this.$center != null  && this.$center.totalFrames > 1)
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
			else
			{
				this.filters = null;
			}
		}
        
		// ITimeoutPlayer
		public function onShortTimeout():Boolean
		{
			var result:Boolean = false;
			return result;
		}
		public function onLongTimeout():Boolean
		{			
			return false;
		}
        
//		public function isPointOnObject():Boolean
//		{
//			var result:Boolean = false;
//			var pt:Point = StateManager.gameManager.getTopLeft();
//			if(this.hitTestPoint(StateManager.cursor.activeCursor.x + pt.x, StateManager.cursor.activeCursor.y + pt.y, true))
//			{
//				result = true;
//			}
//			return result;
//		}
		
	}
}