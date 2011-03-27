package DDW.Components
{
    import DDW.Managers.AnimationManager;
    import DDW.Media.Animator;
    import DDW.Media.DisplayMetric;
	import flash.text.TextField;
	import flash.text.TextFormat;

	public class TextBox extends TextField
	{
		private var format:TextFormat;
		
		public function TextBox(t:TextField)
		{
			super();
			format = t.getTextFormat();
			this.x = t.x;
			this.y = t.y;
			this.width = t.width;
			this.height = t.height;
			this.alpha = t.alpha;
			this.text = t.text;
			
			this.border = t.border;//true;//
			this.borderColor =  t.borderColor;//0x222222;//
			this.autoSize = t.autoSize;
			this.multiline = t.multiline;
			this.selectable = t.selectable;
			this.wordWrap = t.wordWrap;
			this.embedFonts = true;
		}
		
		public override function set text(value:String):void
		{
			super.text = value;
			this.setTextFormat(format);
		}
        
		public function animateTo(dm:DisplayMetric, steps:Number):void
		{         
            var a:Animator = new Animator(this, this.getMetric(), dm, steps);
            AnimationManager.instance.add(a);
        }
		public function getMetric():DisplayMetric
		{
			var result:DisplayMetric = new DisplayMetric();
			
			result.x = this.x;
			result.y = this.y;
			result.width = this.width;
			result.height = this.height;
			result.alpha = this.alpha;	
			
			return result;		
		}
//		public override function set width(value:Number):void
//		{
//			this.setTextFormat(format);
//		}
		
	}
}