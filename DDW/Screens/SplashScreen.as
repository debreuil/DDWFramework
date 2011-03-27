package DDW.Screens
{
    import DDW.Components.DefaultButton;
    import DDW.Components.MovieClipPlus;
	import flash.display.DisplayObject;
    import flash.display.Sprite;
			
	public class SplashScreen extends Screen
	{ 				
        public var $bkg:MovieClipPlus;
        public var $btnContinue:DefaultButton;
        
		public function SplashScreen(autoLayout:DisplayObject = null)
		{
			super(autoLayout);
		}
	}
}