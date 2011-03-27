package DDW.Components
{
	import DDW.Interfaces.*;
	import DDW.Managers.*;
    import DDW.Media.Animator;
	import DDW.Media.DisplayMetric;
	import DDW.Screens.Screen;
    import flash.media.SoundTransform;
    import flash.system.System;
    import flash.utils.getQualifiedClassName;
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.utils.describeType;
	import flash.utils.getDefinitionByName;
	
	public class Component extends Sprite implements IDisposable
	{		
		public static const USE$:Boolean = true; 
		
		public static var stringBundle:Object = {};
		public static var guidCounter:uint = 0;
		
		public var guid:uint;
		public var rootName:String;
		public var creationIndex:int = 0;
		public var isEnabled:Boolean = true;
		public var autoDispose:Boolean = false;
		public var wasAddedToStage:Boolean = false;
        public var defaultCollection:Vector.<*>;
        
        private var elementDescriptors:Array;
		
		public function Component(autoLayout:DisplayObject)
		{
            this.guid = guidCounter++;
            
			if(autoLayout != null)
			{           
				createLayout(autoLayout);
			}            
            
			initializeComponent();
			
			this.addEventListener(Event.ADDED_TO_STAGE, onAddedToStage, false, 0, true);
			this.addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage, false, 0, true);

            autoLayout = null;
		}
		
		public function getString(id:String):String
		{
			return stringBundle.hasOwnProperty(id) ? stringBundle[id] : "";
		}
		
		protected function initializeComponent():void
		{
			redrawText();	
		}
        
		public function onAddedToStage(e:Event):void
		{		
			wasAddedToStage = true;
		}
        
		public function onRemovedFromStage(e:Event):void
		{		
			if(this.autoDispose)
			{
				this.disposeView();
			}
		}        
        
        //private static var edList:Object = { };
		private function createLayout(autoLayout:DisplayObject):void
		{
            //var cn:String = getQualifiedClassName(autoLayout); // Note: this is just "moveiclip" when compiling with CS5
            //if (edList[cn] == null)
            //{
                var typeDesc:XML = describeType(this);
                var clipList:XMLList = USE$ ? typeDesc.variable.(@name.charAt(0) == "$") : typeDesc.variable;
                elementDescriptors = getElementDescriptors(clipList, autoLayout);
                //edList[cn]  = elementDescriptors;
            //}
            //else
            //{
              //elementDescriptors = edList[cn];
            //}

			for(var i:int = 0; i < elementDescriptors.length; i++)
			{
				var ed:ElementDescriptor = elementDescriptors[i];
				var n:String = ed.name;
				var t:String = ed.type;
				var sn:String = USE$ ? n.substr(1) : n;
				var isArray:Boolean = ed.isArray;
                var isVector:Boolean = false;
				
				var hasProp:Boolean = autoLayout.hasOwnProperty(sn);
				
				// for case where the layout element should be the backing clip
				if(ed.isDefaultObject)
				{
					this[n] = addElement(autoLayout, ed);
				}
				else if(isArray)
				{
                    insureArray(ed);
                    if (ed.elementIndex > -1) // may just be array declaration for dynamic creation
                    {
                        this[n][ed.elementIndex] = addElement(autoLayout[sn + ed.elementIndex], ed);
                        this[n][ed.elementIndex]["creationIndex"] = ed.elementIndex;	
                    }
				}
				else if(autoLayout[sn] != null)
				{
					this[n] = addElement(autoLayout[sn], ed);					
				}
			}                 
		}
        
		private function insureArray(ed:ElementDescriptor, elementIndex:int = -1):void
		{            
            if(this[ed.name] == null)
            {
                if (ed.isVector)
                {
                    var cls:Class = getClassFromString(ed.type);
                    this[ed.name] = new cls(0, false);
                    if (this is ICollection && defaultCollection == null)
                    {
                        defaultCollection = this[ed.name];
                    }
                }
                else
                {
                    this[ed.name] = [];
                }
            }
            
            var index:int = Math.max(ed.elementIndex, elementIndex);
            if (ed.isVector && (index >= this[ed.name].length || ed.elementIndex == -1))
            {
                this[ed.name].length = index + 1;
            }
        }
        
		private function addElement(element:DisplayObject, ed:ElementDescriptor, addAsChild:Boolean = true):DisplayObject
		{
			var result:DisplayObject = null;
            
			// fp10 vectors are: __AS3__.vec::Vector.<flash.display::MovieClip>
            var t:String = ed.isVector ? ed.type.substring(ed.type.indexOf("<") + 1, ed.type.indexOf(">")) : ed.type;
            //var orgWidth:Number = element.width;
			//var orgHeight:Number = element.height;
			
			if(t.indexOf("flash.") == 0)
			{
				if(element is MovieClip)
				{
					var m:MovieClip = MovieClip(element);
					m.stop();
				}	
                
                if (addAsChild)
                {
                    this.addChild(element);
                }
                
				result = element;
				result.alpha = element.alpha;
				//result.rotation = element.rotation; // object is placed pre rotated
				result.opaqueBackground = element.opaqueBackground;
				result.visible = element.visible;
			}
			else
			{
                var componentType:Class = getClassFromString(t);
                result = createComponentFromClass(element, componentType, addAsChild);
			}
            
			if(result != null && result is Component)
			{               
                Component(result).rootName = ed.name;
			}
            
			return result;		
		}
		
		private function createComponentFromClass(element:DisplayObject, componentType:Class, addAsChild:Boolean = true):DisplayObject
		{
			var result:DisplayObject = null;            
            
            if(componentType != null)
            {
                var tx:int = element.x;
                var ty:int = element.y;
                element.x = 0;
                element.y = 0;
                result = new componentType(element);
                result.transform.matrix = element.transform.matrix.clone();
                result.x = tx;
                result.y = ty;	
                
                if (addAsChild)
                {
                    this.addChild(result);
                }
                
				result.alpha = element.alpha;
				//result.rotation = element.rotation; // object is placed pre rotated
				result.opaqueBackground = element.opaqueBackground;
				result.visible = element.visible;
            }   
            
            return result;
        }
        
		private function getClassFromString(className:String):Class
		{
            var result:Class = null;
            
            var t:String = className;
            t.replace("::", ".");

            var def:Object = null;
            try{def = getDefinitionByName(t);}catch(e:Error){}

            if(def != null)
            {
                result = def as Class; 
            }
            return result;
        }
        
		private function getElementDescriptor(instanceName:String):ElementDescriptor
		{   
            var result:ElementDescriptor = null;
            for (var i:int = 0; i < elementDescriptors.length; i++) 
            {
                var ed:ElementDescriptor = elementDescriptors[i];
                if (ed.name == instanceName)
                {
                    result = ed;
                    break;
                }
            }
            return result;
        }
        
		protected function getElementDescriptors(clipList:XMLList, autoLayout:DisplayObject):Array
		{
			var descriptors:Array = [];
			var len:int = clipList.length();
            
            var movieclipTypeCount:int = 0;
            var movieclipDescriptor:ElementDescriptor = null;
            
            var isDefined:Boolean = false;
            
			for(var i:int = 0; i < len; i++)
			{
				var n:String = clipList[i].@name; 
				var t:String = clipList[i].@type;
				var sn:String = USE$ ? n.substr(1) : n;
				var isArray:Boolean = (t == "Array");
				var isVector:Boolean = false;
				var elementCount:int = 0; 
				var depth:int = 0; 
                
				if(isArray)
				{
					var aetMeta:XMLList = clipList[i].(metadata.(@name=="ArrayElementType"));
					if(aetMeta != null)
					{
						t = String(aetMeta[0].metadata.(@name == "ArrayElementType").arg.(@key == "" || @key == "type").@value);
					}
				}
                else if (t.indexOf("::Vector.<") > -1) // t = "__AS3__.vec::Vector.<flash.display::MovieClip>"
                {
                    isArray = true;
                    isVector = true;
                }
                
				var hasProp:Boolean = autoLayout.hasOwnProperty(sn);
				
				if(!hasProp && isArray)
				{
					var index:int = 0;
                    if (!autoLayout.hasOwnProperty(sn + index)) // for dynamically populated arrays
                    {
                        descriptors.push(new ElementDescriptor(n, t, true, -1, -1, isVector));                        
                    }
                    else
                    {
                        while(autoLayout.hasOwnProperty(sn + index))
                        {
                            if(autoLayout.hasOwnProperty(sn + index) && autoLayout is DisplayObjectContainer)
                            {
                                if(autoLayout[sn + index] != null)
                                {
                                    depth = DisplayObjectContainer(autoLayout).getChildIndex(autoLayout[sn + index]);
                                }
                                else
                                {
                                    break;
                                }
                            }
                            isDefined = true;
                            descriptors.push(new ElementDescriptor(n, t, true, index, depth, isVector));
                            index++;
                        }
					}
				}
				else if(autoLayout is DisplayObjectContainer) // && hasProp)
				{
					if(autoLayout[sn] != null)
					{
                        isDefined = true;
						depth = DisplayObjectContainer(autoLayout).getChildIndex(autoLayout[sn]);
					}
					descriptors.push(new ElementDescriptor(n, t, false, elementCount, depth, isVector));
				}
                
                // used to detect and assign to default movieclip object when autolayout clip should be used as is
                if(!isArray && t == "flash.display::MovieClip")
                {
                    movieclipTypeCount++;
                    movieclipDescriptor = new ElementDescriptor(n, t, false, index, depth, isVector);
                }
			}
			
			descriptors.sortOn(["depth"], Array.NUMERIC);
            
            // for case where the layout element should be the backing clip
            if(!isDefined)
            {
                if (movieclipTypeCount == 1)
                {
                    movieclipDescriptor.isDefaultObject = true;
                    descriptors.push(movieclipDescriptor);
                }
                /* hmm, its handy to ignore defined $autos when reusing a component with a new view
                // ignore blank clips that are used as placeholders
                else if (   movieclipTypeCount == 0 && 
                            autoLayout is DisplayObjectContainer && 
                            DisplayObjectContainer(autoLayout).numChildren > 0
                        )
                {
                    throw new Error("No default movieclips to assign unmapped symbol to in " + this + "."); 
                }
                */
                else if (movieclipTypeCount > 1)
                {
                    //throw new Error("More than one default movieclip to assign unmapped symbol to in " + this + ".");                     
                }
            }
                
			return descriptors;
		}
        
		
		public function createTypedInstance(libraryName:String, componentType:Class):DisplayObject
		{            
            var cls:Class = AssetManager.instance.getLoadedDefinition(libraryName);
            var element:DisplayObject = DisplayObject(new cls());
            var result:DisplayObject = createComponentFromClass(element, componentType, false);
            return result;
        }
        // use this to create instance dynamically at runtime (doesn't add to stage)
		public function assignInstance(libraryName:String, instanceName:String):DisplayObject
		{
            return addInstance(libraryName, instanceName, null, false);            
        }
        
        
        // use this to create and add instance dynamically at runtime        
		public function addInstance(libraryName:String, instanceName:String, metrics:DisplayMetric = null, addAsChild:Boolean = true):DisplayObject
		{
            var cls:Class = AssetManager.instance.getLoadedDefinition(libraryName);
            if (cls != null)
            {
                var element:DisplayObject = DisplayObject(new cls());
                var ed:ElementDescriptor = getElementDescriptor(instanceName);
                var createdObject:DisplayObject = null;
                if (ed != null)
                {
                    if (ed.isArray)
                    {
                        var num:int = ed.elementIndex;
                        if (instanceName != ed.name)// && !ed.isVector)
                        {
                            num = parseInt(instanceName.substring(ed.name.length));
                            if (!isNaN(num))
                            {
                                ed.elementIndex = num;
                            }
                        }
                        else if (ed.elementIndex == -1)
                        {
                            num = this[ed.name].length;
                        }
                        insureArray(ed, num);
                        createdObject = addElement(element, ed, addAsChild);
                        this[ed.name][num] = createdObject;
                        this[ed.name][num]["creationIndex"] = num;
                    }
                    else
                    {
                        createdObject = addElement(element, ed, addAsChild);
                        this[ed.name] = createdObject;		
                    }
                }
            }
            
            if (metrics != null && cls != null && createdObject != null && createdObject is Sprite)
            {
                metrics.applyTo(Sprite(createdObject), false);
            }
            
            if (this is IFlowable && IFlowable(this).flowEngine != null)
            {
                IFlowable(this).redraw();
            }
            
            return createdObject;
        }
        
		public function redrawText():void
		{			
		}
		
		public function isCursorActive():Boolean
		{
			return Cursor.isActive;
		}
		public function animateTo(dm:DisplayMetric, steps:Number):void
		{         
            var a:Animator = new Animator(this, this.getMetric(), dm, steps);
            AnimationManager.instance.add(a);
        }
		public function getMetric():DisplayMetric
		{
			var result:DisplayMetric = new DisplayMetric();
			
			result.x = this.x;
			result.y = this.y;
			result.width = this.width;
			result.height = this.height;
			result.alpha = this.alpha;	
			
			return result;		
		}
		public function enable():void
		{	
			this.isEnabled = true;
			for(var i:int = 0; i < this.numChildren; i++)
			{
				var d:DisplayObject = this.getChildAt(i);
				if(d is Component)
				{
					Component(d).enable();
				}
				else if(d is MovieClip)
				{
					MovieClip(d).enable = true;
				}
			}
		}
		public function disable():void
		{	
			this.isEnabled = false;
			for(var i:int = 0; i < this.numChildren; i++)
			{
				var d:DisplayObject = this.getChildAt(i);
				if(d is Component)
				{
					Component(d).disable();
				}
				else if(d is MovieClip)
				{
					MovieClip(d).enable = false;
				}
			}
		}
		protected function disposeObject(obj:DisplayObject):void
		{
			if(obj == null)
			{
				return;
			}
			if(this.contains(obj))
			{
				this.removeChild(obj);
			} 
			if(obj is IDisposable)
			{
				IDisposable(obj).disposeView();
			}
		}
		public function disposeView():void
		{
			for(var i:int = this.numChildren - 1; i >= 0; i--)
			{
				disposeObject(this.getChildAt(i));
			}
		}
		
	}
}