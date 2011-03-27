package DDW.Components
{
	import DDW.Media.AudioObject;
	import DDW.Media.PlayableObject;
	import DDW.Media.VideoObject;
	import DDW.Screens.Screen;
	import DDW.Utilities.TimerUtils;
	
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	
	public class VideoPlayerComponent extends Component
	{
		/*
		protected var nc:NetConnection;
		protected var ns:NetStream;	
		protected var video:Video;	
		protected var completeCallback:Function;	
		
		public var duration:Number = 0;
		public var skipAmount:Number = 5;
		public var volume:Number = 1;
		public var isPaused:Boolean = false;
		public var isMuted:Boolean = false;
		*/
		protected var po:PlayableObject;
		protected var isDraggingLoc:Boolean = false;
		protected var isDraggingVol:Boolean = false;
		
		protected var startButton:DefaultButton;
		protected var restartButton:DefaultButton;
		protected var rewindButton:DefaultButton;
		protected var playButton:DefaultButton;
		protected var pauseButton:DefaultButton;
		protected var fastForwardButton:DefaultButton;
		protected var muteButtonOn:DefaultButton;
		protected var muteButtonOff:DefaultButton;
		protected var locationButton:DefaultButton;
		protected var locationBar:MovieClip;
		protected var volumeButton:DefaultButton;
		protected var volumeBar:MovieClip;
		protected var txTime:TextBox;
		protected var vol:Number = 1;
		private var locY:Number;
		private var volY:Number;
		public var prevTrackCallback:Function;
		public var nextTrackCallback:Function;
		
		public function VideoPlayerComponent(autoLayout:MovieClip, layoutContainer:Screen = null)
		{
			super(autoLayout);
			if(autoLayout != null && layoutContainer != null)
			{				
				createButtons(autoLayout, layoutContainer);
			}
			po = new VideoObject();
		}
		
		protected function createButtons(layoutMc:MovieClip, layoutContainer:Screen):void
		{			
//			layoutContainer.generateLayout(layoutMc);
			
			startButton = DefaultButton(layoutContainer.getChildByName("_start"));	
			if(startButton != null)
			{
				startButton.addEventListener(MouseEvent.CLICK, onStartClick, false, 0, true);
			}
			
			restartButton = DefaultButton(layoutContainer.getChildByName("_restart"));	
			if(restartButton != null)
			{
				restartButton.addEventListener(MouseEvent.CLICK, onRestartClick, false, 0, true);
				restartButton.visible = false;
			}
			
			rewindButton = DefaultButton(layoutContainer.getChildByName("_rew"));	
			if(rewindButton != null)
			{
				rewindButton.addEventListener(MouseEvent.CLICK, onRewind, false, 0, true);
			}
			playButton = DefaultButton(layoutContainer.getChildByName("_play"));	
			if(playButton != null)
			{
				playButton.addEventListener(MouseEvent.CLICK, onPlay, false, 0, true);
			}
			pauseButton = DefaultButton(layoutContainer.getChildByName("_pause"));
			if(pauseButton != null)
			{
				pauseButton.addEventListener(MouseEvent.CLICK, onPause, false, 0, true); 
				pauseButton.visible = false;
			}
			fastForwardButton = DefaultButton(layoutContainer.getChildByName("_ff"));	 
			if(fastForwardButton != null)
			{
				fastForwardButton.addEventListener(MouseEvent.CLICK, onFastForward, false, 0, true);
			}	 
			muteButtonOn = DefaultButton(layoutContainer.getChildByName("_muteOn"));	
			if(muteButtonOn != null)
			{
				muteButtonOn.addEventListener(MouseEvent.CLICK, onMuteOn, false, 0, true);
			}
			muteButtonOff = DefaultButton(layoutContainer.getChildByName("_muteOff"));	
			if(muteButtonOff != null)
			{
				muteButtonOff.addEventListener(MouseEvent.CLICK, onMuteOff, false, 0, true);
				muteButtonOff.visible = false;
			}
			
			locationButton = DefaultButton(layoutContainer.getChildByName("_loc"));	
			if(locationButton != null)
			{
				locationButton.addEventListener(MouseEvent.MOUSE_DOWN, onLocationDown, false, 0, true);
				locY = locationButton.y + .5; // add glow
			}
			locationBar = MovieClip(layoutContainer.getChildByName("_locBar"));	
			
			volumeButton = DefaultButton(layoutContainer.getChildByName("_vol"));	
			if(volumeButton != null)
			{
				volumeButton.addEventListener(MouseEvent.MOUSE_DOWN, onVolumeDown, false, 0, true);
				volY = volumeButton.y + .5; // add glow
			}				
			volumeBar = MovieClip(layoutContainer.getChildByName("_volBar"));
			txTime = TextBox(layoutContainer.getChildByName("_txTime"));
				
		}
		private function onPlay(e:MouseEvent):void
		{
			po.resume();
			if(playButton != null)
			{
				playButton.visible = false;
			}
			if(pauseButton != null)
			{
				pauseButton.visible = true;
			}
		}
		private function onPause(e:MouseEvent):void
		{
			po.pause();
			if(playButton != null)
			{
				playButton.visible = true;
			}
			if(pauseButton != null)
			{
				pauseButton.visible = false;
			}
		}
		private function onRewind(e:MouseEvent):void
		{
			if(prevTrackCallback == null)
			{
				po.skipBack();
			}
			else
			{
				prevTrackCallback();
			}
		}
		private function onFastForward(e:MouseEvent):void
		{
			if(nextTrackCallback == null)
			{
				po.skipForward();
			}
			else
			{
				nextTrackCallback();
			}
		}
		private function onMuteOn(e:MouseEvent):void
		{
			if(!po.isMuted)
			{
				po.toggleMute();
				if(muteButtonOn != null)
				{
					muteButtonOn.visible = false;
				}
				if(muteButtonOff != null)
				{
					muteButtonOff.visible = true;
				}
			}
				
		}
		private function onMuteOff(e:MouseEvent):void
		{
			if(po.isMuted)
			{
				po.toggleMute();
				if(muteButtonOn != null)
				{
					muteButtonOn.visible = true;
				}
				if(muteButtonOff != null)
				{
					muteButtonOff.visible = false;
				}
			}
				
		}
		private function onMouseUp(e:MouseEvent):void
		{
			if(isDraggingLoc)
			{
				onLocationUp(e);
			}
			if(isDraggingVol)
			{
				onVolumeUp(e);
			}
		}
		private var wasPaused:Boolean;
		private function onLocationDown(e:MouseEvent):void
		{
			if(po != null && po.duration > 0)
			{
				isDraggingLoc = true;
				wasPaused = po.isPaused;
				po.pause();
				stage.addEventListener(MouseEvent.MOUSE_UP, onLocationUp, false, 0, true);
				stage.addEventListener(MouseEvent.MOUSE_MOVE, onLocationMove, false, 0, true);
				var r:Rectangle = new Rectangle(locationBar.x, locY, locationBar.width, 0); 
				locationButton.startDrag(false, r);
			}
		}
		private function onLocationMove(e:MouseEvent):void
		{			
			var r:Number = (locationButton.x - locationBar.x) / locationBar.width;
			var t:Number = po.duration * r;
			po.seek(t);
		}
		private function onLocationUp(e:MouseEvent):void
		{
			isDraggingLoc = false;
			stage.removeEventListener(MouseEvent.MOUSE_UP, onLocationUp);
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, onLocationMove);
			locationButton.stopDrag();
			po.isPaused = wasPaused;
			if(!po.isPaused)
			{
				po.resume();
			}
		}
		private function onVolumeDown(e:MouseEvent):void
		{
			isDraggingVol = true;
			stage.addEventListener(MouseEvent.MOUSE_UP, onVolumeUp, false, 0, true);
			stage.addEventListener(MouseEvent.MOUSE_MOVE, onVolumeMove, false, 0, true);
			var r:Rectangle = new Rectangle(volumeBar.x, volY, volumeBar.width - volumeButton.width, 0); 
			volumeButton.startDrag(false, r);
		}
		private function onVolumeMove(e:MouseEvent):void
		{			
			var r:Number = (volumeButton.x - volumeBar.x) / volumeBar.width;
			
			po.setVolume(r);
			vol = po.volume;
		}
		private function onVolumeUp(e:MouseEvent):void
		{
			isDraggingVol = false;
			stage.removeEventListener(MouseEvent.MOUSE_UP, onVolumeUp);
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, onVolumeMove);
			volumeButton.stopDrag();
			vol = po.volume;
		}
		private function onStartClick(e:MouseEvent):void
		{
			startButton.visible = false;
			po.playFromStart();	
			if(playButton != null)
			{
				playButton.visible = false;
			}
			if(pauseButton != null)
			{
				pauseButton.visible = true;
			}
		}
		private function onRestartClick(e:MouseEvent):void
		{
			restartButton.visible = false;
			po.playFromStart();	
			if(playButton != null)
			{
				playButton.visible = false;
			}
			if(pauseButton != null)
			{
				pauseButton.visible = true;
			}			
		}
		
		
		public function setContent(path:String, completeCallback:Function = null, x:int = 0, y:int = 0, w:int = -1, h:int = -1):void
		{
			if(path.indexOf(".flv") > -1)
			{
				if(po != null)
				{
					po.disposeView();
				}
				po = new VideoObject();
				po.setContent(path, this, completeCallback, x, y, w, h);
			}
			else if(path.indexOf(".mp3") > -1)
			{
				if(po != null)
				{
					po.disposeView();
				}
				po = new AudioObject();
				po.setContent(path, this, completeCallback, x, y, w, h);				
			}
			
			resetButtons();
			if(po != null)
			{
				po.setVolume(vol);
			}
		}			
		
		public function setDefaultImage(path:String, x:int=0, y:int=0):void
		{
			if(path != null && path != "")
			{
				po.setDefaultImage(path, x, y);
			}
		}
		
		public function playFromStart():void
		{
			if(po != null)
			{
				po.playFromStart();
				if(playButton != null)
				{
					playButton.visible = false;
				}
				if(pauseButton != null)
				{
					pauseButton.visible = true;
				}
			}
		}
		public function atStart():Boolean
		{
			return po == null ? true : po.atStart();
		}
		public function atEnd():Boolean
		{
			return po == null ? false : po.atEnd();
		}
		public function isPaused():Boolean
		{
			return po == null ? true : po.isPaused;
		}
		public function isMuted():Boolean
		{
			return po == null ? true : po.isMuted;
		}		
		public function resetButtons():void
		{
			if(playButton != null)
			{
				playButton.visible = true;
			}
			if(pauseButton != null)
			{
				pauseButton.visible = false;
			}			
		}
		
		// must be called by container if using buttons passed in (updates location etc).
		public function update(elapsed:Number):void
		{
			if(po != null)
			{
				var ct:Number = po.getCurrentTime();
				var dur:Number = po.duration;
				var t:Number = (dur > 0) ? ct / dur : 0;
				
				if(txTime != null)
				{
					var tx:Number = (t < 0) ? 0 : t;
					txTime.text = TimerUtils.getMinSecFormat(dur * tx) + "/" + TimerUtils.getMinSecFormat(dur);
				}
				
				if(!isDraggingLoc && locationBar != null && locationButton != null)
				{
					var loc:Number = locationBar.width * t;
					locationButton.x = loc + locationBar.x - locationButton.width / 2;
					if(locationButton.x > locationBar.x + locationBar.width - locationButton.width / 2)
					{
						locationButton.x= locationBar.x + locationBar.width - locationButton.width / 2;
					}
				}
				
				if(po.isVideo)
				{
					if(po.atStart())
					{
						if(po.isPaused && startButton != null)
						{
							startButton.visible = true;
						}
					}
					else if(po.atEnd() && restartButton != null)
					{
						restartButton.visible = true;
					}
					else if((startButton != null && startButton.visible) ||  (restartButton != null && restartButton.visible)) // try not to hit too much while playing
					{
						startButton.visible = false;
						restartButton.visible = false;
					}
				}
				else
				{
					startButton.visible = false;
					restartButton.visible = false;					
				}
			}
		}
		public override function disposeView():void
		{				
			super.disposeView();
			
			if(po != null)
			{
				po.disposeView();
			}
					
			if(isDraggingLoc)
			{
				onLocationUp(null);
			}				
			if(isDraggingVol)
			{
				onVolumeUp(null);
			}
			
			if(rewindButton != null)
			{
				rewindButton.removeEventListener(MouseEvent.CLICK, onRewind);
			}
			if(playButton != null)
			{
				playButton.removeEventListener(MouseEvent.CLICK, onPlay);
			}
			if(pauseButton != null)
			{
				pauseButton.removeEventListener(MouseEvent.CLICK, onPause); 
			}	 
			if(fastForwardButton != null)
			{
				fastForwardButton.removeEventListener(MouseEvent.CLICK, onFastForward);
			}	 
			if(muteButtonOn != null)
			{
				muteButtonOn.removeEventListener(MouseEvent.CLICK, onMuteOn);
			}	
			if(muteButtonOff != null)
			{
				muteButtonOff.removeEventListener(MouseEvent.CLICK, onMuteOff);
			}
			
			if(locationButton != null)
			{
				locationButton.removeEventListener(MouseEvent.MOUSE_DOWN, onLocationDown);
			}			
			if(volumeButton != null)
			{
				volumeButton.removeEventListener(MouseEvent.MOUSE_DOWN, onVolumeDown);
			}				
			
			rewindButton = null;
			playButton = null;
			pauseButton = null;
			fastForwardButton = null;
			muteButtonOn = null;
			muteButtonOff = null;
			locationButton = null;
			locationBar = null;
			volumeButton = null;
			volumeBar = null;
			txTime = null;
			
		}
		
	}
}