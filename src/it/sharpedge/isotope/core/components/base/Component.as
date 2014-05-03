package it.sharpedge.isotope.core.components.base
{
	import flash.errors.IllegalOperationError;
	
	import it.sharpedge.isotope.core.components.Transform;
	import it.sharpedge.isotope.core.GameObject;
	import it.sharpedge.isotope.core.base.IsotopeObject;
	import it.sharpedge.isotope.core.base.isotopeInternal;

	use namespace isotopeInternal;
	
	public class Component extends IsotopeObject
	{
		//TODO: Replace with ID?
		private var _gameObject : GameObject;
		
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
		
		/*public function get display() : DisplayComponent
		{
			return _gameObject.get(DisplayComponent) as DisplayComponent;
		}
		
		public function get rigidBody2D() : RigidBody2DComponent
		{
			return _gameObject.get(RigidBody2DComponent) as RigidBody2DComponent; 
		}*/
		
		public function GetComponent(type : Class) : Component
		{
			if(_gameObject)
				return _gameObject.GetComponent(type);
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