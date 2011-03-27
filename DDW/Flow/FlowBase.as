package DDW.Flow 
{	
    import DDW.Components.Component;
    import DDW.Interfaces.IFlowable;
    import flash.display.DisplayObject;
    
    public class FlowBase
    {        
        public function FlowBase() 
        {			
        }		
        
        public function redraw(container:Component, bkg:DisplayObject):void
        {
            // do nothing by default
        }
    }
}