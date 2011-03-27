package DDW.Components
{
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	
	public class ScaleButton extends DefaultButton
	{
		public var $left:MovieClip;
		public var $right:MovieClip;
		//public var $center:MovieClip; // from base class
		public var $label:TextBox;
		
		public var border:int = 5;
		
		public function ScaleButton(autoLayout:DisplayObject = null)
		{
			super(autoLayout);
		}
		
		protected override function initializeComponent():void
		{
			super.initializeComponent();
			
			this.setChildIndex($center, 0);
			
			this.scaleX = 1;
			this.scaleY = 1;
			
			$center.x = $left.width - 1;
			this.setChildIndex($center, 0);
			$label.x = border;;
			$label.width = this.width - border * 2;
		}
		
		public function get text():String
		{	
			return $label.text;
		}
		public function set text(value:String):void
		{		
			$label.text = value;
		}
		
		private var _w:int = -1;
		private var _prevW:int = -1;
		private var isResizing:Boolean = false;
		public override function get width():Number
		{	
			return _w;
		}
		public override function set width(value:Number):void
		{		
			if(!isResizing)
			{
				this._w = int(value);
				isResizing = true;	
				setSize();
				isResizing = false;
			}
		}
		protected function setSize():void
		{
			if(_prevW != _w)
			{
				if($left != null && $right != null)
				{
					$right.x = Math.floor(_w - $right.width);	
					$center.width = Math.ceil(_w - $right.width - $left.width) + 2;
				}
				else
				{
					$center.width = _w;	
				}
				
				if($label != null)
				{	
					$label.x = border;;
					$label.width = this.width - border * 2;
				}
				
				_prevW = _w;
			}			
		}
		
		
		
		
	}
}