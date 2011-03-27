package DDW.Components 
{
    import DDW.Interfaces.IButtonContainer;
    import DDW.Interfaces.ICollection;
    import flash.display.DisplayObject;
    import flash.display.MovieClip;
    import flash.events.Event;
    import flash.events.MouseEvent;
    
    public class TabControl extends Component implements IButtonContainer, ICollection
    {        
        public var $tab:Vector.<DefaultButton>;
        //public var $tabPage:Vector.<TabPage>;
        public var $bkg:MovieClip
        
        //private var _selectedIndex:int;
        //public var selectedTab:MovieClip
        
        public function TabControl(autoLayout:DisplayObject)
		{
			super(autoLayout);
        }
        
        override public function onAddedToStage(e:Event):void 
        {
            super.onAddedToStage(e);
            setSelected(0);
        }
        
		public function clickButtonHandler(btn:DefaultButton, event:MouseEvent):void
        {
            setSelected(btn.creationIndex);
        }
		public function rollOverButtonHandler(btn:DefaultButton, event:MouseEvent):void
        {
        }
		public function rollOutButtonHandler(btn:DefaultButton, event:MouseEvent):void
        {
        }
        
        public function getSelected():int
        {
            var result:int = -1;
            for (var i:int = 0; i < $tab.length; i++) 
            {
                if ($tab[i].isEnabled)
                {
                    result = i;
                    break;
                }
            }  
            return result;
        }
        
        public function setSelected(index:int):void
        {
            for (var i:int = 0; i < $tab.length; i++) 
            {
                if (i == index)
                {
                    $tab[i].disable();
                    defaultCollection[i].visible = true;
                }
                else
                {
                    $tab[i].enable();
                    defaultCollection[i].visible = false;
                }
            }            
        }
        
    }

}