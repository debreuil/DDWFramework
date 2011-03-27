package DDW.Components
{
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	
	public class ElementDescriptor
	{
		public var name:String;
		public var type:String;
		public var isArray:Boolean;
		public var isVector:Boolean;
		public var elementIndex:int;
		public var depth:int;
		public var isDefaultObject:Boolean = false;
		
		public function ElementDescriptor(name:String, type:String, isArray:Boolean, elementIndex:int, depth:int, isVector:Boolean = false)
		{
			this.name = name;
			this.type = type.replace("::", ".");
			this.isArray = isArray;
			this.elementIndex = elementIndex;
			this.depth = depth;
            this.isVector = isVector;
			
			ensureFullTypePath();
		}
		
		private function ensureFullTypePath() : void
		{
				var def:Object = null;
				
				try{def = getDefinitionByName(type);}catch(e:Error){}
				
				// todo: check all namespaces automatically...
				if(def == null) 
				{
					try{def = getDefinitionByName("flash.display." + type);}catch(e:Error){}
				}
				if(def == null)
				{
					try{def = getDefinitionByName("DDW.Components." + type);}catch(e:Error){}
				}
				
				if(def != null)
				{
					type = flash.utils.getQualifiedClassName(def);
				}
				else
				{
					trace("component not found: " + type + ". Are you sure you have at least one reference to in in you program?");
				}
			
		}

	}
}