package DDW.Media
{
	import flash.display.DisplayObjectContainer;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundLoaderContext;
	import flash.media.SoundTransform;
	import flash.net.URLRequest;
	
	public class AudioObject extends PlayableObject
	{	
		protected var image:Loader;
		protected var imageLoaded:Boolean;
		protected var snd:Sound;
		protected var ch:SoundChannel;
		private var pausePosition:Number = 0;
		
		public function AudioObject()
		{
			super();
			skipAmount = skipAmount;
		}		
		
		public override function setContent(path:String, container:DisplayObjectContainer, completeCallback:Function = null, x:int = 0, y:int = 0, w:int = -1, h:int = -1):void
		{
			super.setContent(path, container, completeCallback);
				
			if(snd != null)
			{
				snd.removeEventListener(Event.COMPLETE, onLoaded);
				snd.removeEventListener(Event.SOUND_COMPLETE, onComplete);
				snd.removeEventListener(IOErrorEvent.IO_ERROR, onError);				
				try
				{
					snd.close();
				}
				catch(e:Error){}
			}
			snd = new Sound(); 
			snd.addEventListener(Event.COMPLETE, onLoaded, false, 0, true);
			snd.addEventListener(Event.SOUND_COMPLETE, onComplete, false, 0, true);
			snd.addEventListener(Event.ID3, onID3, false, 0, true);
			snd.addEventListener(IOErrorEvent.IO_ERROR, onError, false, 0, true);
			var slc:SoundLoaderContext = new SoundLoaderContext(1000, false);
			slc.checkPolicyFile = true;
			snd.load(new URLRequest(path), slc);
		}
		private var _duration:Number = -1;
		public override function get duration():Number 
		{
			var result:Number = 100;
			if(_duration != -1)
			{
				result = _duration;
			}
			else
			{
				result = aproximateDuration();
			}
			return result;
		}
		private function onID3(e:Event):void 
		{
			if(snd.id3.TLEN != null)
			{
				_duration = parseInt(snd.id3.TLEN) / 1000;
			}
			else if(snd.id3.TIME != null)
			{
				_duration = parseInt(snd.id3.TIME) / 1000;
			}
		}
		private function onLoaded(e:Event):void 
		{
			if(_duration == -1)
			{
				this._duration = snd.length / 1000;
			}
		}
		private function aproximateDuration():Number 
		{
		    var pct:Number = snd.bytesLoaded / snd.bytesTotal;
		    var dur:Number = snd.length / 1000;
		    var result:Number = dur / pct;
		    if(isNaN(result))
		    {
		    	result = 300;
		    }
		    return result;
		}
		private function onComplete(e:Event):void 
		{ 
		}
		private function onError(e:IOErrorEvent):void { trace("error: " + e); }
		
		public override function setDefaultImage(path:String, x:int=0, y:int=0):void
		{
			if(path != null && path != "")
			{
				image = new Loader();
				image.contentLoaderInfo.addEventListener(Event.COMPLETE, onImageComplete);
				var request:URLRequest = new URLRequest(path);
				image.load(request);
				image.x = x;
				image.y = y;
				this.container.addChild(image);
				imageLoaded = false;
			}
		}
		 private function onImageComplete(e:Event):void
		 {
			imageLoaded = true;
		 }
		public override function getCurrentTime():Number
		{
			var result:Number = (ch == null) ? -1 : ch.position / 1000;
			if(isPaused)
			{
				result = pausePosition;
			}
			return result;
		}
		public override function pause():void
		{
			super.pause();
			if(ch != null)
			{
				ch.stop();
				pausePosition = ch.position / 1000;
			} 
		}	
		public override function resume():void
		{
			super.resume();
			if(ch != null)
			{
				ch.stop();
			} 
			ch = snd.play(pausePosition * 1000);
		}
		public override function seek(location:Number):void
		{
			super.seek(location);
			if(ch != null)
			{
				ch.stop();
			} 
			ch = snd.play(location * 1000);
			if(this.isPaused)
			{
				ch.stop();
				pausePosition = location;
			}
		}	
		public override function setVolume(amount:Number):void
		{
			super.setVolume(amount);
			if(ch != null)
			{
				if(!isMuted)
				{
					ch.soundTransform = new SoundTransform(amount, 0);
				}
			}
		}	
		public override function toggleMute():void
		{
			if(ch != null)
			{
				super.toggleMute(); // toggles isMuted
				if(isMuted)
				{
					volume = ch.soundTransform.volume;
					ch.soundTransform = new SoundTransform(0, 0);				
				}
				else
				{
					ch.soundTransform = new SoundTransform(volume, 0);				
				}
			}
		}	
		
		public override function disposeView():void
		{
			if(this.image != null)
			{
				if(!imageLoaded && image != null)
				{
					try
					{
						image.close();
					}
					catch(e:Error){}
				}
				if(this.container != null && this.container.contains(image))
				{
					this.container.removeChild(image);
				}
				this.image = null;				
			}
			if(this.container != null)
			{
				this.container = null;
			}
			
			if(ch != null)
			{
				ch.stop();
			} 
			
			if(snd != null)
			{
				try
				{
					snd.close();
				}
				catch(e:Error){}
				
				snd.removeEventListener(Event.COMPLETE, onLoaded);
				snd.removeEventListener(Event.SOUND_COMPLETE, onComplete);
				snd.removeEventListener(IOErrorEvent.IO_ERROR, onError);				
			}
			
			
			snd = null;
			ch = null;	
		}
		
	}
}