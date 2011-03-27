package DDW.Components
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	
	public class NineBox extends Component
	{		 
		public var $top:DisplayObject;
		public var $bottom:DisplayObject;	
		public var $left:DisplayObject;
		public var $right:DisplayObject;	
		
		public var $topLeft:DisplayObject;
		public var $topRight:DisplayObject;
		public var $bottomLeft:DisplayObject;
		public var $bottomRight:DisplayObject;
		
		public var $center:DisplayObject;
		
		private var _topBorder:int = -1;
		private var _bottomBorder:int = -1;
		private var _leftBorder:int = -1;
		private var _rightBorder:int = -1;
		
		public function NineBox(autoLayout:DisplayObject = null, 
			topBorder:int = -1, rightBorder:int = -1, bottomBorder:int = -1, leftBorder:int = -1):void
		{
			super(autoLayout);
			this._topBorder = topBorder;
			this._rightBorder = rightBorder;
			this._bottomBorder = bottomBorder;
			this._leftBorder = leftBorder;
		}
		
		protected override function initializeComponent():void
		{
			super.initializeComponent();
			
			this.setChildIndex($topLeft, this.numChildren - 1);
			this.setChildIndex($bottomLeft, this.numChildren - 1);
			this.setChildIndex($topRight, this.numChildren - 1);
			this.setChildIndex($bottomRight, this.numChildren - 1);
			
			if($center != null)
			{
				this.setChildIndex($center, this.numChildren - 1);
				var lb:int = (this._leftBorder == -1) ? $topLeft.width : this._leftBorder;
				var tb:int = (this._topBorder == -1) ? $topLeft.height : this._topBorder;			
				$center.x = lb;
				$center.y = tb;
			}
			
			this.scaleX = 1;
			this.scaleY = 1;
		}
		public override function onAddedToStage(e:Event):void
		{
			super.onAddedToStage(e);
		}
		public override function onRemovedFromStage(e:Event):void
		{	
			super.onRemovedFromStage(e);
		}	
		
		private var _w:int = -1;
		private var _h:int = -1;
		private var _prevW:int = -1;
		private var _prevH:int = -1;
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
		public override function get height():Number
		{	
			return _h;			
		}
		public override function set height(value:Number):void
		{		
			if(!isResizing)
			{
				this._h = int(value);
				isResizing = true;		
				setSize();
				isResizing = false;
			}
		}
		
		private function setSize():void
		{
			if(_prevW != _w)
			{
				var lb:int = (_leftBorder == -1) ? $topLeft.width : _leftBorder;
				var rb:int = (_rightBorder == -1) ? $topRight.width : _rightBorder;
				
				
				$top.x = $topLeft.width;
				$top.width = _w - $topLeft.width - $topRight.width;	
				$bottom.width = $top.width;		
				$bottom.x = $top.x;	
				
				$right.x = _w - $right.width;
				$topRight.x = $topLeft.width + $top.width;
				$bottomRight.x = $topRight.x;
				
				if($center != null)
				{
					$center.width = Math.ceil(_w - lb - rb) + 2;
					$center.x = lb - 1;	
				}			
				
				_prevW = _w;
			}
			
			if(_prevH != _h)
			{
				var tb:int = (_topBorder == -1) ? $topLeft.height : _topBorder;
				var bb:int = (_bottomBorder == -1) ? $bottomLeft.height : _bottomBorder;
				
				$left.y = $topLeft.height;
				$left.height = _h - $bottomLeft.height - $topLeft.height;	
				$right.height = $left.height;		
				$right.y = $left.y;	
				
				$bottom.y = _h - $bottom.height;
				$bottomLeft.y = $topLeft.height + $left.height;
				$bottomRight.y = $bottomLeft.y;
				
				if($center != null)
				{
					$center.height = Math.ceil(_h - tb - bb) + 2;
					$center.y = tb - 1;
				}
				

				
				_prevH = _h;				
			}
		}		
	}
}