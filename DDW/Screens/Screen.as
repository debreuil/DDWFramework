package DDW.Screens
{
	import DDW.Components.Component;
    import DDW.Components.DefaultButton;
    import DDW.Interfaces.IButtonContainer;
	import DDW.Interfaces.ISerializable;
    import DDW.Interfaces.ITimeoutPlayer;
    import DDW.Managers.AssetManager;
    import DDW.Managers.ButtonManager;
    import DDW.Managers.TimeoutManager;
    import flash.display.DisplayObjectContainer;
    import flash.display.MovieClip;
    import flash.events.MouseEvent;
    import flash.media.SoundTransform;
    import flash.system.ApplicationDomain;
	
	import flash.display.DisplayObject;
	
	// should be treated as an abstract class (don't create instances of it, only of subclasses)
	public class Screen extends Component implements  ITimeoutPlayer, IButtonContainer, ISerializable
	{
		protected var buttonManager:ButtonManager;        
        private var getRootName:RegExp = new RegExp(/([a-zA-Z$_]*)([0-9]+)/);
		
        protected function get traceUnusedWarnings():Boolean {return true;}
		
		public function Screen(autoLayout:DisplayObject):void
		{
            stopAll(autoLayout);
            
			super(autoLayout);
            
            // remove remaining objects and trace unused. Not strictly needed.
            if (autoLayout is DisplayObjectContainer)
            {
                var doc:DisplayObjectContainer = DisplayObjectContainer(autoLayout);
                while (doc.numChildren > 0)
                {
                    // trace any unused elements
                    var nm:String = doc.getChildAt(0).name;
					var ar:Array = getRootName.exec(nm);
					nm = ar != null ? ar[1] : nm;

                    if (traceUnusedWarnings && (!this.hasOwnProperty("$" + nm) || this["$" + nm] == null))
                    {
                        trace("unused: " + nm + " in " + this);
                    }
                    doc.removeChildAt(0);
                }
            }
            autoLayout = null;
            
			buttonManager = ButtonManager.instance;
		}		
		
        // for overriding default stack behaviour (eg splash screens)
        public function get previousScreen():String { return null; }
        //public function get NextScreen():String { return null; }
        
        // completely destroy and remove from memory when unloaded (caution: based on loader url).
        public function get unloadWhenRemoved():Boolean { return false; }
        
		public static function stopAll(obj:DisplayObject):void
		{
            if (obj is DisplayObjectContainer)
            {
                var d:DisplayObjectContainer = DisplayObjectContainer(obj);
                for (var i:int = 0; i < d.numChildren; i++) 
                {
                    var o:DisplayObject = d.getChildAt(i);
                    if (o is MovieClip)
                    {
                        MovieClip(o).gotoAndStop(1);
                        MovieClip(o).soundTransform = new SoundTransform(0, 0);
                    }
                    stopAll(o);
                }
                if (obj is MovieClip)
                {
                    MovieClip(obj).gotoAndStop(1);
                    MovieClip(obj).soundTransform = new SoundTransform(0, 0);
                }
            }
        }
		public static function playAll(obj:DisplayObject):void
		{
            if (obj is DisplayObjectContainer)
            {
                var d:DisplayObjectContainer = DisplayObjectContainer(obj);
                for (var i:int = 0; i < d.numChildren; i++) 
                {
                    var o:DisplayObject = d.getChildAt(i);
                    if (o is MovieClip)
                    {
                        MovieClip(o).play();
                    }
                    playAll(o);
                }
                
                if (obj is MovieClip)
                {
                    MovieClip(obj).play();
                }
            }
        }
        
		// ISerializable
		public function serialize():Object
		{
			var result:Object = {};
			
			return result;
		}
		public function deserialize(o:Object):void
		{
		}
		// IButtonContainer
		public function clickButtonHandler(btn:DefaultButton, event:MouseEvent):void
		{
			buttonManager.setFocus(btn);
		}
		public function rollOverButtonHandler(btn:DefaultButton, event:MouseEvent):void
		{
			buttonManager.setFocus(btn);
			TimeoutManager.instance.currentTimeoutObject = btn;
		}
		public function rollOutButtonHandler(btn:DefaultButton, event:MouseEvent):void
		{
			if(this.parent != null) // prevent roll over as object is deleted from display list
			{
				buttonManager.releaseFocus(btn);
				TimeoutManager.instance.currentTimeoutObject = this;
			}
		}
				
		public function onShortTimeout():Boolean
		{
			return false;
		}
		public function onLongTimeout():Boolean
		{			
			return false;
		}
        
		public function update(elapsed:uint):void
		{            
        }
        
		// IDisposable
		public override function disposeView():void
		{
			super.disposeView();
            disposeObject(this);
			buttonManager.removeAllButtons();
		}
	}
}