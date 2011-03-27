package DDW.Managers
{
	import DDW.Components.DefaultButton;
	
	public class ButtonManager extends Manager
	{
		private static var _instance:ButtonManager;
		private static var singletonLock:Boolean = false;
		
		private var buttonList:Array;
		private var focusBtn:DefaultButton;
		
		function ButtonManager()
		{
			if(singletonLock)
			{
				init();
			}
			else
			{
				throw new Error("ButtonManager is a singleton class. Use 'getInstance' instead.");
			}
		}
		
        public static function get instance():ButtonManager
		{
			if(_instance == null)
			{
				ButtonManager.singletonLock = true;
				_instance = new ButtonManager();
				ButtonManager.singletonLock = false;
			}
			return _instance;
		}
		
		private function init():void
		{
			buttonList = new Array();
			focusBtn = null;
		}
		
		public function addButton(btn:DefaultButton):void
		{
			buttonList.push(btn);
		}

		public function removeButton(btn:DefaultButton):void
		{
			var idx:int = buttonList.indexOf(btn);
		
			//delete if found	
			if ( idx != -1 )
            {
				buttonList.splice(idx, 1);
            }
		}

		public function removeAllButtons():void
		{
			buttonList = [];
		}
		
		public function setFocus(btn:DefaultButton):void
		{
			var idx:int = buttonList.indexOf(btn);
			
			//reset focus if found
			if( idx != -1 )
			{
				if ( focusBtn != null )
                {
					focusBtn.stopButton();
                }
					
				//set new focus
				focusBtn = btn;
			}
		}

		public function releaseFocus(btn:DefaultButton):void
		{
			var idx:int = buttonList.indexOf(btn);
			
			//reset focus if found
			if( idx != -1 )
			{
				if( focusBtn == btn )
				{
					focusBtn.stopButton();
					focusBtn = null;
				}	
			}			
		}
	}
}