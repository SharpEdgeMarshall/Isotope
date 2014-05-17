package it.sharpedge.isotope.core
{
	import flash.errors.IllegalOperationError;
	
	import it.sharpedge.isotope.core.base.IsotopeObject;
	import it.sharpedge.isotope.core.base.isotopeInternal;
	import it.sharpedge.isotope.core.components.Transform;

	use namespace isotopeInternal;
	
	public class Component extends IsotopeObject
	{
		//TODO Replace with ID?
		isotopeInternal var _gameObject : GameObject;
		
		isotopeInternal function setGameObject(value:GameObject) : void
		{
			if(!value) return;
			
			_gameObject = value;
		}
		
		public function get gameObject() : GameObject
		{
			return _gameObject;
		}		
		
		
		public function Component(abstractEnforcer:Private, name:String)
		{
			super(getIsotopeAccess(), name);
			
			if ( abstractEnforcer == null )
			{
				throw new Error("AbstractException...");
			}			
			
		}
		
		//Only Class that Inherit can call constructor using getAccess()
		protected function getComponentAccess():Private { return new Private(); }
		
		public function get transform() : Transform
		{
			return GetComponent(Transform) as Transform;
		}
		
		public function GetComponent(componentType : Class) : Component
		{
			if(_gameObject)
				return _gameObject.GetComponent(componentType);
			else
				return null;
		}
		
		public function GetComponents(componentType:Class) : Vector.<Component>
		{
			if(_gameObject)
			{
				return _gameObject.GetComponents(componentType) as Vector.<Component>;
			}
			else
				return null;
		}
		
		public function GetComponentInChildren(componentType:Class) : Component
		{
			if(_gameObject)
				return _gameObject.GetComponentInChildren(componentType);
			else
				return null;
		}
		
		public function GetComponentsInChildren(componentType:Class) : Vector.<Component>
		{
			if(_gameObject)
				return _gameObject.GetComponentsInChildren(componentType) as Vector.<Component>;
			else
				return null;
		}
		
		isotopeInternal function clone() : Component
		{
			throw new IllegalOperationError("clone() method not implemented");
		}
		
		isotopeInternal function dispose() : void
		{
			_gameObject = null;
		}
	}
}

//Class used to Enforce Component as AbstractClass
final class Private
{
	
}