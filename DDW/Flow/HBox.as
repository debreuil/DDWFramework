package DDW.Flow 
{	
    import DDW.Components.Component;
    import DDW.Flow.FlowBase;
    import DDW.Media.DisplayMetric;
    import flash.display.DisplayObject;
    import flash.display.MovieClip;
    
    public class HBox extends FlowBase
    {          
        public var spacer:int = 5;
        
        public function HBox()
        {
        }	        
        
        public override function redraw(container:Component, bkg:DisplayObject):void
        {
            if (container.defaultCollection != null)
            {
                var elements:Vector.<*> = container.defaultCollection;
                
                var curX:int = spacer;
                var curY:int = spacer;
                
                for (var i:int = 0; i < elements.length; i++) 
                {
                    elements[i].x = curX;
                    elements[i].y = curY;
                    
                    curX += elements[i].width + spacer;
                    
                    if (curX > bkg.width - (spacer * 2))
                    {
                        curX = spacer;
                        curY += elements[i].height + spacer;
                    }
                }
            }    
        }
    }
}