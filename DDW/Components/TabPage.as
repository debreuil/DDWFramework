package DDW.Components 
{
    import adobe.utils.CustomActions;
    import DDW.Flow.FlowBase;
    import DDW.Flow.HBox;
    import DDW.Interfaces.ICollection;
    import DDW.Interfaces.IFlowable;
    import flash.display.DisplayObject;
    import flash.display.MovieClip;
    
    public class TabPage extends Component implements IFlowable, ICollection
    {           
        public var $bkg:DisplayObject;
        
        public function TabPage(autoLayout:DisplayObject)
		{
			super(autoLayout);    
        }            
        
        private var _flowEngine:FlowBase = new HBox();
        public function get flowEngine():FlowBase{return _flowEngine};
        public function set flowEngine(engine:FlowBase):void { _flowEngine = engine };    
        
        public function redraw():void
        {
            if (_flowEngine != null)
            {
                _flowEngine.redraw(this, $bkg);
            }
        }
    }
}