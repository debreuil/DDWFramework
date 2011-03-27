package DDW.Managers 
{
    import DDW.Media.AssetDescriptor;
    import flash.display.Loader;
    import flash.display.LoaderInfo;
    import flash.net.URLRequest;
    import flash.system.ApplicationDomain;
    import flash.system.LoaderContext;
    
    public class AssetLoadInfo
    {
        public var assetDescriptor:AssetDescriptor;
        public var onLoadedCallback:Function;
        
		public var assetLoaded:Boolean = false;
		public var assetLoader:Loader;
		public var urlRequest:URLRequest;
		public var assetLoadedInfo:LoaderInfo;
        
        public function AssetLoadInfo(assetDescriptor:AssetDescriptor, onLoadedCallback:Function) 
        {            
            this.assetDescriptor = assetDescriptor;
            this.onLoadedCallback = onLoadedCallback;
            
			assetLoader = new Loader();
			urlRequest = new URLRequest(assetDescriptor.assetUrl);
        }
        
		public function load():void
		{   
            var context:LoaderContext = new LoaderContext(false, ApplicationDomain.currentDomain);
            assetLoader.load(urlRequest, context);
        }
		public function dispose():void
		{         
            assetDescriptor = null;
            onLoadedCallback = null;
            assetLoadedInfo = null;
            assetLoader = null;	
        }
    }

}