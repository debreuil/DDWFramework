package DDW.Interfaces 
{
    import DDW.Flow.FlowBase;
    public interface IFlowable
    {
        function get flowEngine():FlowBase;
        function set flowEngine(engine:FlowBase):void;
        
        function redraw():void;
    }
    
}