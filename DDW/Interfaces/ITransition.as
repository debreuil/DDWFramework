package DDW.Interfaces 
{
    import DDW.Media.Animator;
    public interface ITransition
    {        
		function get hideCompletionCallback() : Function;
		function set hideCompletionCallback( n:Function ) : void;
        
		function get showCompletionCallback() : Function;
		function set showCompletionCallback( n:Function ) : void;
                
		function fadeInBegin():void;
		function fadeInEnd(an:Animator, args:Array):void;
		function fadeOutBegin():void;
		function fadeOutEnd(an:Animator, args:Array):void;		
    }
}