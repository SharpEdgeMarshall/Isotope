package it.sharpedge.isotope.core.base
{
	import it.sharpedge.isotope.core.components.Transform;
	import it.sharpedge.isotope.core.Component;
	import it.sharpedge.isotope.core.GameObject;

	use namespace isotopeInternal;
	
	public class IsotopeObject
	{
		private static var _idCount : int = 0;
		
		private var _id : int;		
		private var _name : String;
		
		
		public function IsotopeObject(abstractEnforcer:Private, name:String)
		{
			if ( abstractEnforcer == null )
			{
				throw new Error("AbstractException...");
			}
			
			_name = name;			
			_id = _idCount++;
		}
		
		//Only Class that Inherit can call constructor using getAccess()
		protected function getIsotopeAccess():Private { return new Private(); }
		
		public function GetInstanceID() : int { return _id; }
		
		public function get name() : String { return _name; }
		
		//Static accessors
		public static function Destroy(obj:IsotopeObject):void
		{
			if(obj is GameObject)
			{
				GameObject(obj).dispose();
			}
			else if(obj is Component)
			{
				if(obj is Transform)
				{
					throw new Error("Cannot Destroy transform component");
					return;
				}
				
				Component(obj).gameObject.disposeComponent(Component(obj));
			}
		}
		
		public static function Instantiate(obj:IsotopeObject) : IsotopeObject
		{
			if(obj is GameObject)
			{
				return GameObject(obj).clone();
			}
			else if(obj is Component)
			{
				//If obj is a Component clone the gameobject
				return Component(obj).gameObject.clone();
			}
			else
			{
				throw new Error("Cannot Clone this object");
				return null;
			}
		}
		
	}
}

//Class used to Enforce IsotopeObject as AbstractClass
final class Private
{
	
}