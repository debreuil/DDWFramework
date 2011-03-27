package DDW.Media
{
	import flash.display.DisplayObjectContainer;
	import flash.events.AsyncErrorEvent;
	import flash.events.NetStatusEvent;
	import flash.media.SoundTransform;
	import flash.media.Video;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	
	public class VideoObject extends PlayableObject
	{
		protected var nc:NetConnection = new NetConnection();
		protected var ns:NetStream;	
		protected var video:Video;	

		
		public function VideoObject()
		{
			this.isVideo = true;
			super();
			nc.connect(null);
			ns = new NetStream(nc);	
			var _client:Object = {};
			_client.onMetaData = this.onMetaData;
			ns.client = _client;
			ns.bufferTime = 3;	
			ns.addEventListener(NetStatusEvent.NET_STATUS, netStatusHandler, false, 0, true);
			ns.addEventListener(AsyncErrorEvent.ASYNC_ERROR, videoErrorHandler, false, 0, true);
		}
		protected function netStatusHandler( event:NetStatusEvent) :void
		{
		
			if(event.info.code == "NetStream.Play.Stop")
			{
				if(completeCallback != null)
				{
					completeCallback(this);
				}
			}
			else if(event.info.code == "NetStream.Play.Start")
			{		
				//this.seek (1); // *** dont do this or it will skip the metadata
				//this.pause(); 
			}
			else if(event.info.code == "NetStream.Seek.Notify")
			{		
				//trace("Seek");		
				//ns.resume();
			}
			else(event.info.code == "NetStream.Buffer.Full")
			{
				//trace("full: " + ns.bytesLoaded + " : " + ns.bytesTotal);
				//seek(0);
				//ns.resume();
			}
		}
		private function videoErrorHandler(event:AsyncErrorEvent):void
		{			
			trace("error: " + event)
		}
		private var x:int = -1;
		private var y:int = -1;
		private var w:int = -1;
		private var h:int = -1;
		public override function setContent(path:String, container:DisplayObjectContainer, completeCallback:Function = null, x:int = 0, y:int = 0, w:int = 428, h:int = 240):void
		{
			super.setContent(path, container, completeCallback);
			isPaused = true;
			
			if(video == null)
			{
				video = new Video(w, h);
				container.addChild(video);
			}
			else
			{
				video.clear();
			}
			this.x = x;
			this.y = y;
			this.w = w;
			this.h = h;
			
			video.x = x;
			video.y = y;
			if(h != -1)
			{
				video.width = (h / video.height) * video.width;	
				video.x = (w - video.width) / 2 + x;
				video.height = h;				
			}
			video.attachNetStream(ns);
			ns.bufferTime = 3;
			ns.play(path);
			
		}
		public override function getCurrentTime():Number
		{
			return (ns == null) ? -1 : ns.time;
		}
		public override function playFromStart():void
		{
			super.playFromStart();
			//trace("play from start: " + ns.bytesLoaded + " : " + ns.bytesTotal);
		}
		public override function pause():void
		{
			super.pause();
			ns.pause();
		}	
		public override function resume():void
		{
			super.resume();
			ns.resume();
		}
		public override function seek(location:Number):void
		{
			super.seek(location);
			ns.seek(location);
		}	
		public override function setVolume(amount:Number):void
		{
			if(ns != null)
			{
				super.setVolume(amount);
				if(!isMuted)
				{
					ns.soundTransform = new SoundTransform(amount, 0);
				}
			}
		}	
		public override function toggleMute():void
		{
			super.toggleMute(); // toggles isMuted
			if(isMuted)
			{
				volume = ns.soundTransform.volume;
				ns.soundTransform = new SoundTransform(0, 0);				
			}
			else
			{
				ns.soundTransform = new SoundTransform(volume, 0);				
			}
		}	
		private var _duration:Number = 100;
		public override function get duration():Number 
		{
			return _duration;
		}
		public function onMetaData(metadata:Object):void
		{
			this._duration = metadata.duration;
			this.seek(1);
			if(isPaused)
			{
				this.pause();
			}
			if(metadata.width != null)
			{
				video.width = metadata.width;
				video.height = metadata.height;	
				video.width = (h / video.height) * video.width;	
				video.x = (w - video.width) / 2 + x;
				video.height = h;				
			}
		}
		
		public override function disposeView():void
		{
			if(this.container != null)
			{
				if(video != null && this.container.contains(video))
				{
					this.container.removeChild(video);
				}
				this.container = null;
			}
			if(nc != null) 
			{
				try
				{
					nc.close();
				}
				catch(e:Error){}
			}
			
			if(ns != null)
			{
				ns.removeEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
				ns.removeEventListener(AsyncErrorEvent.ASYNC_ERROR, videoErrorHandler);
				ns.pause();
				try
				{
					ns.close();
				}
				catch(e:Error){}
			} 
			
			video = null;
			nc = null;	
			ns = null;	
		}		
		public override function atStart():Boolean
		{
			return getCurrentTime() < 3;
		}
		
	}
}