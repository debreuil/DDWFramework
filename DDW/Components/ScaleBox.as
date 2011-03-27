package DDW.Components
{
	import DDW.Components.*;
	
	import flash.display.DisplayObject;
	import flash.display.Graphics;
	import flash.events.Event;
	import flash.geom.Point;
	
	import mx.core.MovieClipAsset;
	
	public class ScaleBox extends Component
	{
		 
		public var $top:DisplayObject;
		public var $bottom:DisplayObject;	
		public var $left:DisplayObject;
		public var $right:DisplayObject;	
		
		public var $topLeft:DisplayObject;
		public var $topRight:DisplayObject;
		public var $bottomLeft:DisplayObject;
		public var $bottomRight:DisplayObject;
		
		public var tMask:MovieClipAsset;
		public var rMask:MovieClipAsset;
		public var bMask:MovieClipAsset;
		public var lMask:MovieClipAsset;
		
		protected var topBorder:int = 0;
		protected var bottomBorder:int = 0;
		protected var leftBorder:int = 0;
		protected var rightBorder:int = 0;
		
		public function ScaleBox(autoLayout:DisplayObject = null, 
			topBorder:int = -1, rightBorder:int = -1, bottomBorder:int = -1, leftBorder:int = -1):void
		{
			super(autoLayout);
			this.topBorder = topBorder;
			this.rightBorder = rightBorder;
			this.bottomBorder = bottomBorder;
			this.leftBorder = leftBorder;
		}
		
		protected override function initializeComponent():void
		{
			super.initializeComponent();
			
			tMask = new MovieClipAsset();
			this.addChild(tMask);
			$top.mask = tMask;
			
			rMask = new MovieClipAsset();
			this.addChild(rMask);
			$right.mask = rMask;
			
			bMask = new MovieClipAsset();
			this.addChild(bMask);
			$bottom.mask = bMask;
			
			lMask = new MovieClipAsset();
			this.addChild(lMask);
			$left.mask = lMask;
			
			this.setChildIndex($topLeft, this.numChildren - 1);
			this.setChildIndex($bottomLeft, this.numChildren - 1);
			this.setChildIndex($topRight, this.numChildren - 1);
			this.setChildIndex($bottomRight, this.numChildren - 1);
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
				$topRight.x = _w - $topRight.width;	
				$bottomRight.x = _w - $bottomRight.width;
				
				$right.x = _w - rightBorder;
				
				drawHMask(tMask.graphics, $top);
				drawHMask(bMask.graphics, $bottom);
				drawVMask(rMask.graphics, $right);	
				
				_prevW = _w;
			}
			
			if(_prevH != _h)
			{
				$bottomLeft.y = _h - $bottomLeft.height;
				$bottomRight.y = _h - $bottomRight.height;
				
				$bottom.y = _h - bottomBorder;
				
				drawVMask(lMask.graphics, $left);
				drawVMask(rMask.graphics, $right);	
				drawHMask(bMask.graphics, $bottom);			
				
				_prevH = _h;				
			}
		}
		
		private function drawHMask(g:Graphics, d:DisplayObject):void
		{		
			g.clear();
			g.beginFill(0xFF0000);
			g.drawRect(d.x, d.y, _w - $topRight.width - d.x, d.height); 
			g.endFill();	
		}
		private function drawVMask(g:Graphics, d:DisplayObject):void
		{		
			g.clear();
			g.beginFill(0xFF0000);
			g.drawRect(d.x, d.y, d.width, _h - $bottomLeft.height - d.y); 
			g.endFill();	
		}
		
		public function get innerX():int
		{
			return  this.x + leftBorder;
		}
		public function get innerY():int
		{
			return  this.y + topBorder;
		}
		public function get innerWidth():int
		{
			return  this.width - leftBorder - rightBorder;
		}
		public function get innerHeight():int
		{
			return  this.height - topBorder - bottomBorder;
		}
		public function get innerTop():int
		{
			return  this.y + topBorder;
		}
		public function get innerLeft():int
		{
			return  this.x + leftBorder;
		}
		public function get innerRight():int
		{
			return  this.x + this.width - rightBorder;
		}
		public function get innerBottom():int
		{
			return  this.y + this.height - bottomBorder;
		}		

		
	}
}