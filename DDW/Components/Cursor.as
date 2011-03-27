package DDW.Components
{
	import DDW.Enums.*;	
	import DDW.Managers.*;	
    import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.ui.Mouse;
	
	public class Cursor extends Sprite
	{			
		[Embed(source="../Library/Cursor.swf", symbol="cursor")]	
		public var CursorSprite:Class;
		
		public static var isActive:Boolean = true;
		public var activeCursor:Sprite;		
		public var isSystemMouseShowing:Boolean;	
        
		private var dragObject:Sprite;			
		
		public function Cursor()
		{				
			this.mouseEnabled = false;					
			this.activeCursor = new CursorSprite();
			this.activeCursor.mouseEnabled = false;				
			this.addChild(this.activeCursor);			
			this.addEventListener(Event.ADDED_TO_STAGE, this.onAddedToStage, false, 0, true);
			
            this.hideSystemMouse();
			this.activate();
		}
		private function hideSystemMouse(event:MouseEvent=null):void
		{
			isSystemMouseShowing = false;
			Mouse.show(); // for mac bug on right click
			Mouse.hide();
		}
		private function showSystemMouse(event:MouseEvent=null):void
		{
			isSystemMouseShowing = true;
			this.visible = false;
			Mouse.show();
		}
		public function activate():void
		{
			Cursor.isActive = true;
			this.visible = true;
		}
		public function deactivate():void
		{
			Cursor.isActive = false;
			this.visible = false;
		}
		public function onAddedToStage(target:Object):void
		{					
			this.stage.addEventListener(Event.MOUSE_LEAVE, this.onMouseLeave, false, 0, true);	
			this.stage.addEventListener(MouseEvent.MOUSE_MOVE, this.onMouseMove, false, 0, true);
			//this.activeCursor.startDrag(true);					
			this.activate();
            this.x = stage.mouseX;
            this.y = stage.mouseY;
		}
		public function onMouseMove(event:MouseEvent):void
		{
			//this.stage.removeEventListener(MouseEvent.MOUSE_MOVE, this.onMouseMove);
            if (isSystemMouseShowing)
            {
                hideSystemMouse();
                activate();
            }
            this.x = event.stageX;
            this.y = event.stageY;
            event.updateAfterEvent();
        }
        
		public function getDragObject():Sprite
		{
            return dragObject;
        }
		public function addDragObject(obj:Sprite):void
		{
            clearDragObject();
            this.addChild(obj);
            this.setChildIndex(obj, 0);
            dragObject = obj;
        }
		public function clearDragObject():void
		{
            if (dragObject != null && this.getChildIndex(dragObject) != -1)
            {
                this.removeChild(dragObject);
            }
            dragObject = null;
        }
		public function onMouseLeave(event:Event = null):void
		{
			showSystemMouse();
        }
		public function disposeView():void
		{
            showSystemMouse();
			this.stage.removeEventListener(MouseEvent.MOUSE_MOVE, this.onMouseMove);
			this.stage.removeEventListener(Event.MOUSE_LEAVE, this.onMouseLeave);
			for(var i:int = 0; i < this.activeCursor.numChildren; i++)
			{
				this.activeCursor.removeChildAt(0);
			}
			this.removeChild(activeCursor);
			
			for(var j:int = 0; j < this.numChildren; j++)
			{
				this.removeChildAt(0);
			}
		}
		
	}
	
}