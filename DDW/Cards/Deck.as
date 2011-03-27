package DDW.Cards
{
	import DDW.Screens.Screen;
	
	import flash.display.MovieClip;
	
	public class Deck
	{
		public var dealFaceUp:Boolean = false;
		public var index:Number = 0;	
		public var topCard:Card;
		public var cards:Array;		
		public var color:Number;	
		public var backImageUri:String;	
		public var isTiled:Boolean;		
		
		public function Deck(cards:Array)
		{
			this.cards = cards;
		}
	/*
		public function LoadFromXml(deckData:XMLNode, parent:Screen) : Boolean
		{	
			var result:Boolean = false;
			
			this.color = parseInt(deckData.attributes.color);
			this.backImageUri = deckData.attributes.backImage;
			GameManager.assetManager.LoadAsset(this.backImageUri);
			this.isTiled = deckData.attributes.isTiled == "false" ? false : true;
			
			var cardsNode:XMLNode = deckData.firstChild;
			if(cardsNode.nodeName.toLowerCase() == "cards")
			{
				this.cards = new Array();
				var attribs:Object = cardsNode.attributes;
				var w:Number = parseInt(attribs.width);
				var h:Number = parseInt(attribs.height);
				
				var cardFont:String = attribs.font;
				var cardFontColor:Number = parseInt(attribs.color);
				var cardFontSize:Number = parseInt(attribs.size);
				
				var hoverType:String = (attribs.hoverType == null) ? "glow" : attribs.hoverType;
				var hoverColor:Number = (attribs.hoverColor == null) ? 0xAAAA22 : parseInt(attribs.hoverColor);
				var correctType:String = (attribs.correctType == null) ? "border" : attribs.correctType;
				var correctColor:Number = (attribs.correctColor == null) ? 0x22CC22 : parseInt(attribs.correctColor);
				
				var cardNode:XMLNode = cardsNode.firstChild;
				while(cardNode != null)
				{
					if(cardNode.nodeName.toLowerCase() == "card")
					{
						var card:Card = new Card(this.parent, this);
						result = card.LoadFromXml(cardNode);
						card.width = w;
						card.height = h;
						card.font = cardFont;
						card.fontColor = cardFontColor;
						card.fontSize = cardFontSize;
						card.hoverType = hoverType;
						card.hoverColor = hoverColor;
						card.correctType = correctType;
						card.correctColor = correctColor;
						
						card.id = this.cards.length;
						this.cards.push(card);
					}
					cardNode=cardNode.nextSibling;
					
					if(result == false)
					{
						break;
					}
				}
			}
			return result;
		}
		*/
		public function addBackImage(card:Card, clip:MovieClip):void
		{
			if(this.isTiled)
			{
				//GameManager.assetManager.DrawAssetInto(this.backImageUri, clip, 0, 0, card.width, card.height, 1); 
			}
			else
			{
				//GameManager.assetManager.DrawAssetInto(this.backImageUri, clip, card.x, card.y, card.width, card.height, 1); 
			}
		}
		public function nextCard():void
		{
			if(!this.isLastCard())
			{
				this.index++;
				this.cards[this.index].isFaceUp = this.dealFaceUp;
			}
		}
	
		public function flipCard():void
		{
			var c:Card = this.cards[this.index];
			c.flipCard();
		}
	
		public function prevCard():void
		{
			if(!this.isFirstCard())
			{
				this.index--;
			}
			this.cards[this.index].isFaceUp = this.dealFaceUp;
			
		}
	
		public function resetDeck():void
		{	
			this.cards = [];
			this.index = 0;
		}
	
		public function shuffle():void
		{
			for(var i:int = 0; i < this.cards.length; i++)
			{
				var rnd:Number = Math.floor(Math.random() * this.cards.length);
				var temp:Card = this.cards[i];
				this.cards[i]= this.cards[rnd];
				this.cards[rnd] = temp;
			}
			this.index = 0;
		}
		public function isFirstCard():Boolean
		{
			return (this.index == 0);
		}
	
		public function isLastCard():Boolean
		{
			return (this.index < this.cards.length - 1);
		}
		
		public function toString() : String
		{
			var result:String = "Deck: ";
			var comma:String = "";
			for (var i:Number = 0; i < cards.length; i++) 
			{
				result += comma + cards[i].toString();
				comma = ", ";
			}
			return result;
		}

	}
}