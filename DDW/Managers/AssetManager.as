package DDW.Managers
{
	import DDW.Enums.*;
	import DDW.Interfaces.*;
    import DDW.Media.AssetDescriptor;
    import flash.media.SoundTransform;
	
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.net.URLRequest;
    import flash.system.ApplicationDomain;
	
	public class AssetManager extends Manager implements IDisposable
	{		
        private static var _instance:AssetManager;

        private static var singletonLock:Boolean = false;
		private var onLoadedCallback:Function;
		
		protected var assetLoaded:Boolean = false;	
		protected var assetUrl:String;
		protected var assetLoader:Loader;
		protected var assetLoadedInfo:LoaderInfo;	
        
		[Embed(source="../Library/Loader.swf", symbol="loaderUI")]	
		public var LoaderUIClass:Class;		
		public var loaderUI:Sprite;	
		
        private var queue:Array = [];		
		
		public function AssetManager()
		{
            if (!singletonLock)
            {
                throw(new Error("AssetManager is a singleton."));
            }
		}
        
        public static function get instance():AssetManager
        {
            if (_instance == null)
            {
                singletonLock = true;
                _instance = new AssetManager();
                singletonLock = false;
            }
            return _instance;
        }
		
        // returns asset from currentDomain, or first name match from loaded domain if url is empty 
		public function getLoadedDefinition(libraryName:String, url:String = "") : Class
		{	
            var result:Class = null;
            var o:Object = null;
            
            if (url != "") // default to the specified domain
            {
                //AssetLoadInfo[]
                var ais:Array = getSwfAssetInfo(url);
                for (var i:int = 0; i < ais.length; i++) 
                {
                    if (ais[i].assetLoadedInfo != null)
                    {
                        o = ai.assetLoadedInfo.applicationDomain.getDefinition(libraryName);                    
                    }                    
                }
            }
            else
            {
                // try domain we're in first
                o = ApplicationDomain.currentDomain.getDefinition(libraryName);
                
                // if not, try all domains, first one wins 
                // (will throw on conflict, maybe non current domains should require a url though).
                if (o == null)
                {         
                    for (var i2:int = 0; i2 < queue.length; i2++) 
                    {
                        var ai:AssetLoadInfo = AssetLoadInfo(queue[i2]);
                        if (ai.assetLoadedInfo != null)
                        {
                            var temp:Object = ai.assetLoadedInfo.applicationDomain.getDefinition(libraryName);
                            if (temp != null)
                            {
                                if (o != null)
                                {
                                    throw new Error("There are two symbols with the name " + libraryName + " in loaded swfs. Specify a url when dynamically loading.");
                                }
                                else
                                {
                                    o = temp;
                                }
                            }   
                        }
                    }
                }  
            }
            
            if (o != null)
            {
                result = Class(o);
            }
            
            return result;
        }
        
		public function createLoaderUI() : void
		{			
			this.loaderUI = new LoaderUIClass();
		}
        
		public function destroyLoaderUI() : void
		{			
//			if(this.loaderUI != null && StateManager.gameManager.contains(this.loaderUI))
//			{
//              StateManager.gameManager.removeChild(this.loaderUI);	 			
//			}
			this.loaderUI = null;
		}
        
		public function unloadAsset(assetUrl:String) : void
		{
            var assetInfos:Array = getSwfAssetInfo(assetUrl); 
            
            if (assetInfos.length > 0)
            {
                var loader:Loader = null;
                for (var i:int = 0; i < assetInfos.length; i++)
                {
                    var ai:AssetLoadInfo = assetInfos[i]
                    if (ai.assetLoadedInfo != null && ai.assetLoadedInfo.loader != null)
                    {
                        loader = ai.assetLoadedInfo.loader;
                    }
                }
                
                if (loader != null)
                {
                    //loader.close();
                    if (loader.hasOwnProperty("unloadAndStop"))
                    {
                        loader.unloadAndStop(true); // flash player 10
                    }
                    else
                    {
                        loader.unload(); // player 9 and lower
                    }
                }
                
                for (i = queue.length - 1; i >= 0; i--)
                {
                    var qi:int = assetInfos.indexOf(queue[i]);
                    if (qi > -1)
                    {
                        queue.splice(i, 1);
                    }
                }
            }     
        }
        
		public function loadAssets(assetDescriptor:AssetDescriptor, onLoadedCallback:Function) : void
		{
			if(assetDescriptor.assetUrl == null)
			{
				throw new Error("assetUrl or module url is null");
			}	
            var assetInfos:Array = getSwfAssetInfo(assetDescriptor.assetUrl); // AssetLoadInfo objects
            
            // add to queue either way, so callback can happen once loaded
            var ai:AssetLoadInfo = new AssetLoadInfo(assetDescriptor, onLoadedCallback);
            queue.push(ai);  
            
            if (assetInfos.length == 0)
            {                            
                ai.assetLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, onActivityLoaded, false, 0, true);
                ai.assetLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler, false, 0, true);
                ai.load();
                
                createLoaderUI();
                this.loaderUI.mouseEnabled = false;	
                this.loaderUI["loadMeter0"].height = 3;	
                MovieClip(loaderUI).stop();
                var silence:SoundTransform = new SoundTransform(0, 0);
                MovieClip(loaderUI).soundTransform = silence;
                    
                ai.assetLoader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, preloadProgress, false, 0, true);
            }
            else // if (assetInfos[0].isLoaded)
            {
                // todo: look for symbol matches for second call, and just reset the callback 
                // (avoid growing queue with multiple calls)
                loadPendingAssets(ai.assetDescriptor.assetUrl);
            }
            //else 
            //{
                // asset was loaded by other call to swf
            //}
		}
		
		protected function preloadProgress(e:ProgressEvent):void
		{
			var m:MovieClip = MovieClip(loaderUI);
			if(m.currentFrame == 1)
			{
				MovieClip(loaderUI).play();
			}
			else if(m.currentFrame > m.totalFrames - 5)
			{
				//m.gotoAndStop(m.totalFrames);
				this.loaderUI["loaderBar"].alpha = 1;
				this.loaderUI["loadMeter0"].alpha = 1;
				this.loaderUI["bkg"].alpha = 1;
			}

			var ratio:Number = e.bytesLoaded / e.bytesTotal;
			var w:Number = this.loaderUI["loaderBar"].width;
			var wr:Number = w * ratio;
			this.loaderUI["loadMeter0"].width = wr;
		}
        
        protected function getSwfAssetInfo(url:String):Array
        {
            var result:Array = [];//AssetLoadInfo
            for (var i:int = 0; i < queue.length; i++) 
            {
                var ai:AssetLoadInfo = AssetLoadInfo(queue[i]);
                var aurl:String = ai.assetDescriptor.assetUrl;
                
                var n:int = url.indexOf(aurl);
                if (n != -1 && n == url.length - aurl.length)
                {
                    result.push(ai);
                }
            }
            return result;
        }
		protected function onActivityLoaded(event:Event):void
		{
            destroyLoaderUI();
			var assetLoadedInfo:LoaderInfo = LoaderInfo(event.target);
            //var ai:AssetLoadInfo = getAssetInfo(assetLoadedInfo.url);
            loadPendingAssets(assetLoadedInfo.url, assetLoadedInfo);
		}
		private function loadPendingAssets(url:String, assetLoadedInfo:LoaderInfo = null):void 
		{            
            var assetInfos:Array = getSwfAssetInfo(url);
            
            if (assetLoadedInfo == null)
            {
                for (var ct:int = 0; ct < assetInfos.length; ct++) 
                {
                    if (assetInfos[ct].assetLoadedInfo != null)
                    {
                        assetLoadedInfo = assetInfos[ct].assetLoadedInfo;   
                        break;
                    }
                }
            }
            
            if (assetLoadedInfo != null)
            {
                for (var i:int = 0; i < assetInfos.length; i++) 
                {      
                    var ai:AssetLoadInfo = assetInfos[i];
                    
                    if (ai.assetLoader != null)
                    {
                        ai.assetLoader.contentLoaderInfo.removeEventListener(ProgressEvent.PROGRESS, preloadProgress);	
                        ai.assetLoader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
                    }
                                    
                    ai.assetLoaded = true;
                    ai.assetLoadedInfo = assetLoadedInfo;
                    
                    if(ai.onLoadedCallback != null)
                    {
                        var tempFn:Function = ai.onLoadedCallback;
                        ai.onLoadedCallback = null;                
                        tempFn(assetLoadedInfo);
                    }
                    ai.assetLoader = null;
                }
            }
        }
		protected function ioErrorHandler(event:IOErrorEvent):void 
		{
			throw new Error("load error in " + this + ". " + event.text);
		}
		public function loadBitmap(path:String, bmpCallback:Function):Loader
		{			
			var loader:Loader = new Loader();
			var ur:URLRequest = new URLRequest(path);
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, bmpCallback);
			loader.load(ur);
			return loader;
		}
		public override function disposeView():void
		{
			super.disposeView();
			
            for (var i:int = 0; i < queue.length; i++) 
            {            
                var ai:AssetLoadInfo = queue[i];  
                if(	ai.assetLoader != null && ai.assetLoader.contentLoaderInfo != null)
                {
                    ai.assetLoader.contentLoaderInfo.removeEventListener(ProgressEvent.PROGRESS, preloadProgress);
                }	
                ai.dispose();
            }
            
			this.loaderUI = null;	
		}
	}
}	