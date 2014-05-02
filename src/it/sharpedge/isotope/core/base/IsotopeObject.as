package it.sharpedge.isotope.core.base
{
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
		protected function getAccess():Private { return new Private(); }
		
		public function GetInstanceID() : int { return _id; }
		
		//Static accessors
		public static function Destroy(obj:IsotopeObject):void
		{
			
		}
		
		public static function Instantiate(obj:IsotopeObject) : IsotopeObject
		{
			return null;
		}
		
	}
}

//Class used to Enforce IsotopeObject as AbstractClass
final class Private
{
	
}