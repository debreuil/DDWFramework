package DDW.Media
{
	import flash.display.Sprite;
	import flash.display.DisplayObject;
	
	public class DisplayMetric
	{
		public var x:Number;
		public var y:Number;
		public var width:Number;
	 	public var height:Number;
	 	public var alpha:Number;
	 	public var scale:Number = 1;
	 	public var depth:int = -1;
	 	public var visible:Boolean = true;

		public function DisplayMetric(x:Number=0, y:Number=0, width:Number=1, height:Number=1, alpha:Number = 1, scale:Number = 1, depth:int = 0, visible:Boolean = true)
		{		
			this.x = x;
			this.y = y;
			this.width = width;
			this.height = height;
			this.alpha = alpha;	
			this.scale = scale;	
			this.depth = depth;	
			this.visible = visible;	
		}
		public static function getMetric(d:Sprite):DisplayMetric
		{
			var m:DisplayMetric = new DisplayMetric();
			if(m != null)
			{
				m.x = d.x;
				m.y = d.y;
				m.width = d.width;
				m.height = d.height;
				m.alpha = d.alpha;	
				m.scale = d.scaleX;
				m.visible = d.visible;
                
                if (d.parent != null)
                {
                    m.depth = (d.parent != null) ? d.parent.getChildIndex(d) : 0;
                }
			}
			return m;		
		}
		public function clone():DisplayMetric
		{
			var m:DisplayMetric = new DisplayMetric();
			m.x = this.x;
			m.y = this.y;
			m.width = this.width;
			m.height = this.height;
			m.alpha = this.alpha;	
			m.scale = this.scale;	
			m.depth = this.depth;	
			m.visible = this.visible;	
			return m;		
		}
		public function applyTo(target:Sprite, useScale:Boolean):void
		{
			target.x = this.x;
			target.y = this.y;
			target.alpha = this.alpha;
			target.visible = this.visible;	
            
            if (useScale)
            {
                target.scaleX = this.scale;
                target.scaleY = this.scale;
                if (target.parent != null)
                {
                    target.parent.setChildIndex(target, depth); 
                }                
            }
            else
            {
                target.width = this.width;
                target.height = this.height;
            }
		}
        
		public function toString():String
		{
			return "x:" + this.x + " y:" + this.y + " w:" + this.width + " h:" + this.height + " a:" + this.alpha + " s:" + this.scale + " d:" + this.depth + " v:" + this.visible;
		}

	}
}