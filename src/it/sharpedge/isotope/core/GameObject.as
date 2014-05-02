package it.sharpedge.isotope.core
{
	import flash.utils.Dictionary;
	
	import it.sharpedge.isotope.core.base.IsotopeObject;
	import it.sharpedge.isotope.core.base.isotopeInternal;

	use namespace isotopeInternal;
	
	public class GameObject extends IsotopeObject
	{
		private var _components : Dictionary;
		
		private var _activeSelf : Boolean = true;
		
		isotopeInternal var _activeInHierarchy : Boolean;
		
		public function GameObject(name:String = "")
		{
			super(getAccess(), name);
			
			_components = new Dictionary();
		}
		
		public function get activeInHierarchy() : Boolean
		{
			return _activeSelf && _activeInHierarchy;
		}
		
		public function get activeSelf() : Boolean
		{
			return _activeSelf;
		}
		
		public function AddComponent(componentType:Class): void
		{
			var component : Component = new componentType() as Component;
			if(component == null)
			{
				throw new Error("The Class doesn't inherit from Component");
				return;
			}
			
			_components[component.GetInstanceID()] = component;			

		}
		
		public function SetActive(state:Boolean) : void
		{
			if(_activeSelf == state) return;
			
			_activeSelf = state;
			
			//Dispatch to childrens only if activeInHierarchy is true
			if(_activeInHierarchy)
				setChildrensActiveHierarchy(_activeSelf);
		}
		
		isotopeInternal function SetActiveInHierarchy(state:Boolean) : void
		{
			if(state == _activeInHierarchy) return;
			
			_activeInHierarchy = state;
			
			//Childrens are activeInHierarchy only if this is active and activeInHierarchy
			setChildrensActiveHierarchy(_activeInHierarchy && _activeSelf);
		}
		
		private function setChildrensActiveHierarchy(state:Boolean) : void
		{
			//TODO: Iterate childrens and call SetActiveInHierarchy
		}
		
		public function GetComponent(componentType:Class) : Component
		{
			return null;
		}
		
		public function GetComponentInChildren(componentType:Class) : Component
		{
			return null;
		}
		
		public function GetComponents(componentType:Class) : Vector.<Component>
		{
			return null;
		}
		
		public function GetComponentsInChildren(componentType:Class) : Vector.<Component>
		{
			return null;
		}
		
		//Static		
		public static function Find(name:String) : GameObject
		{
			return null;
		}
	}
}