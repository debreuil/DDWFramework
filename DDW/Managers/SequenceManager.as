package DDW.Managers
{
	import DDW.Components.DefaultButton;
	import DDW.Screens.Screen;
	import DDW.Media.PlayableObject;
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.geom.Rectangle;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	import flash.utils.Timer;
	import flash.utils.getTimer;
	
	public class SequenceManager
	{		
		/*
		private static var manager:SequenceManager;
		private static var singletonLock:Boolean = false;
		
		public var isPlaying:Boolean = false;
		
		private var completeCallback:Function;
		private var completeOnceCallback:Function;
		private var cursorActiveDuringPlay:Boolean = true;	
		
		private var playableArray:Array;
		private var currentObject:PlayableObject;
		private var currentIndex:int;
		private var originalObject:Sprite;
		private var originalObjectDepth:int;
		
		public function SequenceManager()
		{
			if(singletonLock)
			{
				init();
			}
			else
			{
				throw new Error("Sequencer is a singleton class. Use 'getInstance' instead.");
			}			
		}
		public static function getInstance():SequenceManager
		{
			if(manager == null)
			{
				SequenceManager.singletonLock = true;
				manager = new SequenceManager();
				SequenceManager.singletonLock = false;
			}
			return manager;
		}
		public function stop():void
		{
			isPlaying = false;
			if(this.currentObject != null)
			{
				if(currentObject.addedObject is MovieClip)
				{
					if(completeOnceCallback != null)
					{
						MovieClip(currentObject.addedObject).removeEventListener(Event.ENTER_FRAME, completeOnceCallback);
					}
					MovieClip(currentObject.addedObject).removeEventListener(Event.ENTER_FRAME, onPlayOnce);
					var st:SoundTransform = new SoundTransform(0,0);
					MovieClip(currentObject.addedObject).soundTransform = st; // turn off event sounds
					//MovieClip(currentObject.addedObject).stop();
				}
				else if(channel != null)
				{
					channel.stop();
					if(completeOnceCallback != null)
					{
						channel.removeEventListener(Event.SOUND_COMPLETE, completeOnceCallback);
					}
					channel.removeEventListener(Event.SOUND_COMPLETE, onPlayOnce);
					channel = null;
				}
				this.currentObject.stop();
			}
			if(this.originalObject != null)
			{
				var sp:Sprite = PlayableObject(this.playableArray[0]).container;
				if(this.currentObject != null)
				{
					this.currentObject.removeObject();
				}
				if(this.originalObject is DefaultButton)
				{
					DefaultButton(this.originalObject).stopButton();
				}
				sp.addChild(this.originalObject);
				this.originalObject = null;
			}
			//this.completeCallback(); // should we call completed when interrupted? 
			this.currentObject = null;
			this.completeOnceCallback = null;
			this.playableArray = null;
			this.completeCallback = null;
			this.currentIndex = 0;
			TimeoutManager.getInstance().restart();		
		}
		private function init():void
		{
		}
		
		public function playSequence(playableArray:Array, completed:Function, cursorActive:Boolean=true, objectToReplace:Sprite = null):void
		{
			stop();
			isPlaying = true;	
			TimeoutManager.getInstance().stop();
			originalObjectDepth = -1;
			
			this.originalObject = objectToReplace;
			
			// todo: clean up possible previous plays	
			this.currentObject = null;
			this.playableArray = playableArray;
			this.completeCallback = completed;
			this.cursorActiveDuringPlay = cursorActive;
			this.currentIndex = 0;
	
			// turn off all sparkles
			if(playableArray.length > 0 && PlayableObject(playableArray[0]).container is Screen && !cursorActive)
			{
				Screen(PlayableObject(this.playableArray[0]).container).stopAllButtons();
			}
			// todo: handle insertion/removal at depth of original object
			if(this.originalObject != null)
			{
				if(this.originalObject is DefaultButton)
				{
					DefaultButton(this.originalObject).stopButton();
				}
				var sp2:Sprite = PlayableObject(this.playableArray[0]).container;
				originalObjectDepth = sp2.getChildIndex(this.originalObject);
				sp2.removeChild(this.originalObject);
			}
			this.playNext(null);
		}
		private function playNext(event:Event):void
		{
			isPlaying = true;
			TimeoutManager.getInstance().stop();
			if(this.currentObject != null)
			{
				if(currentObject.addedObject is MovieClip && completeOnceCallback != null)
				{
					MovieClip(currentObject.addedObject).removeEventListener(Event.ENTER_FRAME, completeOnceCallback);
				}
				else if(channel != null && completeOnceCallback != null)
				{
					channel.removeEventListener(Event.SOUND_COMPLETE, completeOnceCallback);
				}
				this.currentObject.removeObject();
				this.currentObject = null;
			}
			currentObject = playableArray[currentIndex];
			if(currentIndex < playableArray.length - 1)
			{
				this.completeOnceCallback = playNext;
				playOnce(currentObject);
				currentIndex++;
			}
			else
			{
				this.completeOnceCallback = this.completeCallback;	
				playOnce(currentObject);
				currentIndex = 0;				
			}
		}
		private var channel:SoundChannel;
		private function playOnce(playableObject:PlayableObject):void
		{
			isPlaying = true;
			TimeoutManager.getInstance().stop();
			if(!cursorActiveDuringPlay)
			{
				StateManager.cursor.deactivate();
			}
			else
			{
				StateManager.cursor.activate();
			}
			
			playableObject.addObject();
			if(playableObject.addedObject is MovieClip)
			{
				var m:MovieClip = MovieClip(playableObject.addedObject);
				if(originalObject != null)
				{
					m.x = this.originalObject.x;
					m.y = this.originalObject.y;
					if(originalObjectDepth != -1)
					{
						if(originalObjectDepth < m.parent.numChildren)
						{
							m.parent.setChildIndex(m, originalObjectDepth);
						}
					}
				}
				
				mspf = Math.round(1000 / StateManager.frameRate);
				startTime = getTimer();
				lastPlayedFame = 4;
				m.addEventListener(Event.ENTER_FRAME, this.onPlayOnce, false, 0, true);
				m.gotoAndPlay(1);
			}
			else if(playableObject.soundObject != null)
			{		
				channel = playableObject.soundObject.play();
				channel.addEventListener(Event.SOUND_COMPLETE, this.onPlayOnce, false, 0, true); 
			}
		}
		private var mspf:int;	
		private var startTime:int;	
		private var lastPlayedFame:int;		
		
		private function onPlayOnce(event:Event):void
		{
			var isComplete:Boolean = false;
			
			if(event.target is MovieClip)
			{
				var m:MovieClip = MovieClip(event.target);

				// ensure sync for event sounds
				var curTime:int = getTimer();
				var difTime:int = curTime - startTime;
				var projFrame:int = Math.floor(difTime / mspf);
				projFrame = (projFrame > m.totalFrames) ? m.totalFrames : projFrame;
				

				if(m.currentFrame > lastPlayedFame && projFrame < m.currentFrame) // new code to compensate for zinc playing files too fast
				{
					m.gotoAndPlay(lastPlayedFame);//m.currentFrame);
				}
				else if(m.currentFrame > lastPlayedFame && (projFrame != m.currentFrame))
				{
					if(difTime % 100 > 50)
					{
						lastPlayedFame = projFrame+1;
						for(var i:int = m.currentFrame + 1; i < projFrame; i++)
						{
							m.gotoAndStop(i);// catch any event sounds that might be in this frame
						}		
						m.gotoAndPlay(projFrame);		
					}	
					else
					{			
						// nothing
					}						
				}
				else
				{
					//nothing					
				}


				
				if(projFrame >= m.totalFrames) // change due to zinc running at 17 fps
				{
					isComplete = true;
					m.gotoAndStop(m.totalFrames);
					m.removeEventListener(Event.ENTER_FRAME, this.onPlayOnce);					
				}
			}
			else if(event.target is SoundChannel)
			{	
				isComplete = true;
				if(channel != null && channel.hasEventListener(Event.COMPLETE))
				{
					channel.removeEventListener(Event.COMPLETE, this.onPlayOnce);
				}
				channel = null;	
			}
			
			if(isComplete)
			{
				isPlaying = false;
				StateManager.cursor.activate();
				TimeoutManager.getInstance().restart();		
				
				// restore original object if this is last in sequence					
				if(this.completeOnceCallback != playNext && this.originalObject != null)
				{
					if(this.currentObject != null)
					{
						this.currentObject.removeObject();
						this.currentObject = null;
					}
					var sp:Sprite = PlayableObject(this.playableArray[0]).container;
					sp.addChild(this.originalObject)
					if(originalObjectDepth != -1)
					{
						if(originalObjectDepth < sp.numChildren)
						{
							sp.setChildIndex(this.originalObject, originalObjectDepth);
						}
					}
					this.originalObject = null;
				}
				if(this.completeOnceCallback != null)
				{
					var f:Function = this.completeOnceCallback;
					this.completeOnceCallback = null;
					f(event);
				}
			}
		}
		
		private var tweenTargetObject:Sprite;
		private var tweenStartRect:Rectangle;
		private var tweenDestRect:Rectangle;
		private var tweenCallback:Function;
		private var t:Number = 0;;
		private var tInc:Number;
		private var timerId:Number;
		private var timer:Timer;
		public function delay(duration:int, callback:Function):void
		{
			tweenCallback = callback;			
			timer = new Timer(duration, 1);
			timer.addEventListener(TimerEvent.TIMER_COMPLETE, endTween, false, 0, true);
			timer.start();
			
		}
		public function tweenTo(tweenObject:Sprite, targetRect:Rectangle, steps:int, durationPerStep:int, callback:Function):void
		{
			tweenTargetObject = tweenObject;
			tweenStartRect = tweenObject.getRect(tweenObject.parent);
			tweenDestRect = targetRect;
			tweenCallback = callback;
			t = 0.0;
			tInc = 1.0 / steps;
			
			timer = new Timer(durationPerStep, steps);
			timer.addEventListener(TimerEvent.TIMER_COMPLETE, endTween, false, 0, true);
			timer.addEventListener(TimerEvent.TIMER, stepTween, false, 0, true);
			timer.start();
		}
		private function stepTween(event:TimerEvent = null):void
		{
			t += tInc;
			var r:Rectangle = tweenStartRect.clone();
			tweenTargetObject.x = (tweenDestRect.x - tweenStartRect.x) * t + tweenStartRect.x;
			tweenTargetObject.y = (tweenDestRect.y - tweenStartRect.y) * t + tweenStartRect.y;
			tweenTargetObject.width = (tweenDestRect.width - tweenStartRect.width) * t + tweenStartRect.width;
			tweenTargetObject.height = (tweenDestRect.height - tweenStartRect.height) * t + tweenStartRect.height;
			event.updateAfterEvent();
		}
		private function endTween(event:TimerEvent = null):void
		{
			timer.stop();
			timer.removeEventListener(TimerEvent.TIMER, stepTween);
			timer.removeEventListener(TimerEvent.TIMER_COMPLETE, endTween);
			tweenTargetObject = null;
			tweenStartRect = null;
			tweenDestRect = null;
			var temp:Function = tweenCallback;
			tweenCallback = null;
			if(temp != null)
			{
				temp();
			}
		}
		
		public function redirectCallback(callback:Function):void
		{
			if(this.isPlaying)
			{
				this.completeCallback = callback;
				if(this.completeOnceCallback != playNext)
				{
					this.completeCallback = callback;
					this.completeOnceCallback = callback;
				}
			}
		}
		public function dispose():void
		{
			
			if(currentObject != null && currentObject.addedObject != null)// && currentObject.addedObject is MovieClip)
			{
				if(currentObject.addedObject.hasEventListener(Event.ENTER_FRAME))
				{
					currentObject.addedObject.removeEventListener(Event.ENTER_FRAME, completeOnceCallback);
				}
				if(currentObject.addedObject.hasEventListener(Event.ENTER_FRAME))
				{
					currentObject.addedObject.removeEventListener(Event.ENTER_FRAME, onPlayOnce);
				}
			}
			this.stop();
			if(channel != null)
			{
				channel.removeEventListener(Event.SOUND_COMPLETE, onPlayOnce);
				channel = null;
			}
					
			if(timer != null)
			{
				timer.stop();
				timer.removeEventListener(TimerEvent.TIMER, stepTween);
				timer.removeEventListener(TimerEvent.TIMER_COMPLETE, endTween);
				timer = null;
			}
			tweenTargetObject = null;
			tweenStartRect = null;
			tweenDestRect = null;
			tweenCallback = null;
		}
		*/
	}
}