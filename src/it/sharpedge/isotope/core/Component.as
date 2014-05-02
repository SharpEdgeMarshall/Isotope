package it.sharpedge.isotope.core
{
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
		
		/*public function get transform() : Transform3DComponent
		{
			return _gameObject.get(Transform3DComponent) as Transform3DComponent;
		}
		
		public function get display() : DisplayComponent
		{
			return _gameObject.get(DisplayComponent) as DisplayComponent;
		}
		
		public function get rigidBody2D() : RigidBody2DComponent
		{
			return _gameObject.get(RigidBody2DComponent) as RigidBody2DComponent; 
		}
		
		public function GetComponent(type : Class) : *
		{
			return _gameObject.get(type);
		}*/
	}
}