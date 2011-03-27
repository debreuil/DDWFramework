package DDW.Utilities
{
	import flash.display.MovieClip;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	public class DrawingUtils
	{
		public static function SetHtmlText(s:String, tf:TextField, format:TextFormat)  : void
		{
			// tf.border = true; // for testing
			tf.selectable = false;
			tf.embedFonts = true;
			tf.multiline = true;
			tf.wordWrap = true;
			tf.antiAliasType = "advanced";
			tf.htmlText = s;
			tf.setTextFormat(format);
		}
		public static function SetInputTextFormat(tf:TextField, format:TextFormat)  : void
		{
			// tf.border = true; // for testing
			tf.type = "input";
			tf.background = true;
			tf.backgroundColor = 0xFFFFFF;
			tf.selectable = true;
			tf.embedFonts = true;
			tf.antiAliasType = "advanced";
			tf.setTextFormat(format);
		}
		public static function DrawRectangle(clip:MovieClip, rect:Rectangle, color:Number = -1, alpha:Number = -1, lineWidth:Number = -1, lineColor:Number = -1)  : void
		{		
			if(color != -1)
			{
				var al:Number = (alpha == -1) ? 1 : alpha;
				clip.graphics.beginFill(color, al);
			}
			if(lineWidth > 0)
			{
				clip.graphics.lineStyle(lineWidth, lineColor);
			}
			clip.graphics.moveTo(rect.left, rect.top);
			clip.graphics.lineTo(rect.right, rect.top);
			clip.graphics.lineTo(rect.right, rect.bottom);
			clip.graphics.lineTo(rect.left, rect.bottom);
			clip.graphics.lineTo(rect.left, rect.top);
			if(color != -1)
			{
				clip.graphics.endFill();
			}		
		}
		public static function DrawRoundedRectangle(clip:MovieClip, rect:Rectangle, roundness:Number = -1, color:Number = -1, alpha:Number = -1, lineWidth:Number = -1, lineColor:Number = -1) : void
		{			
			if(color != -1)
			{
				var al:Number = (alpha == -1) ? 100 : alpha;
				clip.graphics.beginFill(color, al);
			}
			if(lineWidth > 0)
			{
				clip.graphics.lineStyle(lineWidth, lineColor);
			}
			
			var wx:Number = rect.width + rect.left;
			var hy:Number = rect.height + rect.top;
			var ctrl:Number = roundness * 0.144;
			clip.graphics.moveTo(rect.left + roundness, rect.top);
			clip.graphics.lineTo(wx - roundness, rect.top);
	
			clip.graphics.curveTo(wx-ctrl, rect.top+ctrl, wx, rect.top + roundness);
			clip.graphics.lineTo(wx, hy - roundness);
	
			clip.graphics.curveTo(wx-ctrl, hy - ctrl, wx - roundness, hy);
			clip.graphics.lineTo(rect.left + roundness, hy);
	
			clip.graphics.curveTo(rect.left+ctrl, hy-ctrl, rect.left, hy - roundness);
			clip.graphics.lineTo(rect.left, rect.top + roundness);
	
			clip.graphics.curveTo(rect.left+ctrl, rect.top+ctrl, rect.left + roundness, rect.top);
					
			if(color != -1)
			{
				clip.graphics.endFill();
			}	
		}
	}
}