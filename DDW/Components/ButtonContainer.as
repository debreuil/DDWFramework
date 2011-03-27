package DDW.Components
{
	import DDW.Interfaces.*;	
	import DDW.Managers.*;
	
	import flash.events.MouseEvent;
	import flash.display.MovieClip;

	public class ButtonContainer extends Component implements IButtonContainer, ICollection
	{
		public var _clickButtonHandler:Function;
		public var _rollOverButtonHandler:Function;
		public var _rollOutButtonHandler:Function;
		
		public function ButtonContainer(autoLayout:MovieClip)
		{
			super(autoLayout);
		}
		
		public function clickButtonHandler(btn:DefaultButton, event:MouseEvent):void
		{
			if(_clickButtonHandler != null)
			{
				_clickButtonHandler(btn, event);
			}
		}
		
		public function rollOverButtonHandler(btn:DefaultButton, event:MouseEvent):void
		{
			if(_rollOverButtonHandler != null)
			{
				_rollOverButtonHandler(btn, event);
			}
		}
		
		public function rollOutButtonHandler(btn:DefaultButton, event:MouseEvent):void
		{
			if(this.parent != null) // prevent roll over as object is deleted from display list
			{
			}
			if(_rollOutButtonHandler != null)
			{
				_rollOutButtonHandler(btn, event);
			}
		}
		public override function disposeView():void
		{
			super.disposeView();
			this._clickButtonHandler = null;
			this._rollOverButtonHandler = null;
			this._rollOutButtonHandler = null;
		}
		
	}
}