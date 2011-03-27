package DDW.Media
{
	public class TextMetric extends DisplayMetric
	{
		public var text:String; 
		public var align:String; 
		public var bold:Boolean;
		public var font:String; 
		public var fontSize:Number;
		public var leading:Number;
		public var textColor:Number;
			
		public function TextMetric(x:Number, y:Number, width:Number, height:Number, text:String, align:String, bold:Boolean, font:String, fontSize:Number, leading:Number, textColor:Number) 
		{
			super(x, y, width, height);
			this.text = text; 
			this.align = align; 
			this.bold = bold;
			this.font = font; 
			this.fontSize = fontSize;
			this.leading = leading;
			this.textColor = textColor;
		}
	}
}