package DDW.Interfaces
{
	import DDW.Components.DefaultButton;	
	import flash.events.MouseEvent;
	import DDW.Components.DefaultButton;	
	import flash.events.MouseEvent;
	
	public interface IButtonContainer
	{
		function clickButtonHandler(btn:DefaultButton, event:MouseEvent):void;
		function rollOverButtonHandler(btn:DefaultButton, event:MouseEvent):void;
		function rollOutButtonHandler(btn:DefaultButton, event:MouseEvent):void;
        
        
		//public function clickButtonHandler(btn:DefaultButton, event:MouseEvent):void
        //{
        //}
		//public function rollOverButtonHandler(btn:DefaultButton, event:MouseEvent):void
        //{
        //}
		//public function rollOutButtonHandler(btn:DefaultButton, event:MouseEvent):void
        //{
        //}
	}
}