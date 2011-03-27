package DDW.Interfaces 
{
    import DDW.Managers.StateManager;
    public interface IGameState
    {
        function initialize(manager:StateManager):void; 
        function setMainState():void;
        function setState(stateName:String):void;
        function exitGame():void;
    }

}