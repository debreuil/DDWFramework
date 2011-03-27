package DDW.Media 
{
    import flash.display.DisplayObject;
    import flash.display.DisplayObjectContainer;
    import flash.display.Sprite;
    public class InstanceDescriptor
    {        
        public var displayObject:Sprite;
        public var originalDisplayMetric:DisplayMetric;
		public var originalParent:DisplayObjectContainer;	
        
        public function InstanceDescriptor(displayObject:Sprite) 
        {
            this.displayObject = displayObject;
            originalParent = displayObject.parent;
            originalDisplayMetric = DisplayMetric.getMetric(displayObject);
        }        
    }
}