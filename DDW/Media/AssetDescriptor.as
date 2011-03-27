package DDW.Media 
{
    import DDW.Components.Component;
    import DDW.Components.MovieClipPlus;
    import flash.display.DisplayObject;
    import flash.display.LoaderInfo;
    import DDW.Managers.*;
    import flash.display.MovieClip;
    import flash.display.Sprite;
    import flash.media.SoundTransform;
    import flash.utils.*;
    
    public class AssetDescriptor
    {        
		protected var _name:String;  
		protected var _assetUrl:String;	
		protected var _libraryName:String;	
		protected var _classType:Class;	    
		protected var _instance:DisplayObject;  
        
        public function AssetDescriptor(name:String, classType:Class, assetUrl:String = null, libraryName:String = null, instance:DisplayObject = null) 
        {          
            this._name = name;
			this._classType = classType;
            this._assetUrl = assetUrl;
            this._libraryName = libraryName;  
            this._instance = instance;
        }
		public function get name():String
		{
			return _name;
		}
		public function get classType():Class
		{
			return _classType;
		}
		public function get assetUrl():String
		{
			return _assetUrl;
		}
		public function get libraryName():String
		{
			return _libraryName;
		}
		public function get instance():DisplayObject
		{
			return _instance;
		}
		
        protected var instanceLoadedCallback:Function;
		public function getInstanceAsync(stateInstanceLoadedCallback:Function):void
		{
            if (_instance == null)
            {
                this.instanceLoadedCallback = stateInstanceLoadedCallback;
                ensureStateInstance();
            }
            else
            {
                stateInstanceLoadedCallback(_instance);
            }
        }
		protected function ensureStateInstance():void
		{
			if(_instance == null)
			{
                // loaded
                if (_assetUrl != null)
                {
                    AssetManager.instance.loadAssets(this, onLoaded);
                }
                else // embed
                {
                    _instance = new classType(); // add args
					if (instanceLoadedCallback != null && _instance != null)
					{
						instanceLoadedCallback(_instance); 
					}
                }
			}			
		}	
        
		public function onLoaded(loaderInfo:LoaderInfo):void
		{             
            var inst:DisplayObject;
            if (_libraryName != null && _libraryName != "")
            {
                // issue: This can sometimes load from the existing domains with an asset of the same name.
                // probably something to do with security domains.
                var cls:Class = Class(loaderInfo.applicationDomain.getDefinition(_libraryName));
                var obj:Object = new cls();
                inst = DisplayObject(obj);               
            }
            else if(loaderInfo != null)
            {
                inst = loaderInfo.content;     
            }
            
            if (inst != null && Component.prototype.isPrototypeOf(_classType.prototype))
            {
                _instance = new _classType(inst); // _stateInstance
            }
            else
            {
                _instance = inst;                
            }
            
            inst = null;
            
            if (instanceLoadedCallback != null && _instance != null)
            {
                instanceLoadedCallback(_instance); 
            }
        }      
    }

}