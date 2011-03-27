package DDW.Cards
{
	import DDW.Components.DefaultButton;
	
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	
	public class Card extends DefaultButton
	{
		public var deck:Deck;
		
		public var frontImage:MovieClip;
		public var backImage:MovieClip;
		public var color:Number;	
		public var value:Number;
		public var cardSuit:Number;
		public var isFaceUp:Boolean = false;
		public var cardTransition:Number = 0;
		public var flipCallback:Function;
						
		public function Card(frontImage:MovieClip, backImage:MovieClip, deck:Deck)
		{
			super(backImage);
			this.frontImage = frontImage;
			this.backImage = backImage;
			this.deck = deck;
			
			this.addChild(frontImage);
			reset();
		}
		public function reset():void
		{		
			this.visible = true;
			this.isFaceUp = false;
			this.frontImage.visible = false;
			this.backImage.visible = true;
		}  
		
		/** override for animation on flipping */
		public function beginFaceUp():void 
		{
			endFaceUp();
		}
		public function endFaceUp():void
		{	 
			this.visible = true;
			this.isFaceUp = true;
			this.frontImage.visible = true;
			this.backImage.visible = false;				
		}
		
		/** override for animation on flipping */
		public function beginFaceDown():void
		{	 
			endFaceDown();
		}
		public function endFaceDown():void
		{	 
			this.visible = true;
			this.isFaceUp = false;
			this.frontImage.visible = false;
			this.backImage.visible = true;
		}
		public function flipCard(callback:Function = null):void
		{
			this.flipCallback = callback;
			if(isFaceUp)
			{
				beginFaceDown();
			}
			else
			{
				beginFaceUp();
			}
		}
		public function draw():void
		{
			if(this.isFaceUp)
			{
				this.backImage._visible = false;
				this.frontImage._visible = true;
			}
			else
			{
				this.backImage._visible = true;
				this.frontImage._visible = false;	
			}	
		}
		protected override function onClick(event:MouseEvent):void
		{
			flipCard();
		}
		public override function toString() : String
		{
			var result:String = "[card " + this.value + "] " + this.cardTransition;
			return result;
		}
	}
}