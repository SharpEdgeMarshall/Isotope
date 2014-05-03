package it.sharpedge.isotope.core
{
	import flash.errors.IllegalOperationError;
	import flash.utils.Dictionary;
	
	import it.sharpedge.isotope.core.components.Transform;
	import it.sharpedge.isotope.core.components.base.Component;
	import it.sharpedge.isotope.core.base.IsotopeObject;
	import it.sharpedge.isotope.core.base.isotopeInternal;

	use namespace isotopeInternal;
	
	public class GameObject extends IsotopeObject
	{
		private static var gObjCount : int = 0;
		
		private var _components : Dictionary;
		
		private var _activeSelf : Boolean = true;
		
		isotopeInternal var _activeInHierarchy : Boolean;
		
		//Components accessor
		public function get transform() : Transform
		{
			return _components[Transform];
		}
		
		
		public function GameObject(name:String = "")
		{
			
			super(getIsotopeAccess(), (name == "") ? "GameObject " + ++gObjCount : name);
			
			_components = new Dictionary();
			
			AddComponent(Transform);
			
			//Dispatch event?
			Engine.getInstance().addGameObject(this);
		}
		
		public function get activeInHierarchy() : Boolean
		{
			return _activeSelf && _activeInHierarchy;
		}
		
		public function get activeSelf() : Boolean
		{
			return _activeSelf;
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
			for each(var childTransf : Transform in transform.children)
			{
				childTransf.gameObject.SetActiveInHierarchy(state);
			}
		}		
		
		public function AddComponent(componentType:Class): void
		{
			var component : Component = new componentType() as Component;
			if(component == null)
			{
				throw new IllegalOperationError("The Class doesn't inherit from Component");
				return;
			}
			
			component.setGameObject(this);
			
			if(_components[componentType])
			{
				disposeComponent(Component(_components[componentType]));				
			}
			
			_components[componentType] = component;			
			
		}
		
		isotopeInternal function RemoveComponent(componentType:Class) : void
		{
			_components[componentType] = null;
		}
		
		public function GetComponent(componentType:Class) : Component
		{
			return _components[componentType];
		}
		
		public function GetComponentInChildren(componentType:Class) : Component
		{
			var comp : Component = GetComponent(componentType);
			
			if(comp)
				return comp;
			else
			{
				for each(var childTransf : Transform in transform.children)
				{
					comp = childTransf.gameObject.GetComponentInChildren(componentType);
					
					if(comp)
						return comp;
				}
			}
			
			return null;
		}
		
		public function GetComponentsInChildren(componentType:Class) : Vector.<Component>
		{
			var comps : Vector.<Component> = new Vector.<Component>();
			
			var comp : Component = GetComponent(componentType);
			
			if(comp)
				comps.push(comp);

			for each(var childTransf : Transform in transform.children)
			{					
				comps = comps.concat(childTransf.gameObject.GetComponentsInChildren(componentType));					
			}
			
			
			return comps;
		}
		
		isotopeInternal function clone() : GameObject
		{
			var cGObj : GameObject = new GameObject(this.name + " (Clone)");
			var cComp : Component;
			var cChildGObj : GameObject;
			
			//Clone components
			for each(var componentType : Class in _components)
			{
				cComp = Component(_components[componentType]).clone();
				cComp.setGameObject(cGObj);
				cGObj._components[componentType] = cComp;
			}
			
			//Clone child
			for each(var child : Transform in transform.children)
			{
				cChildGObj = child.gameObject.clone();
				cChildGObj.transform.parent = cGObj.transform;
			}
			
			return cGObj;
		}
		
		//Static		
		public static function Find(name:String) : GameObject
		{
			return Engine.getInstance().find(name);
		}
		
		isotopeInternal function dispose() : void
		{
			for each(var child : Transform in transform.children)
			{
				child.gameObject.dispose();
			}			
			
			for each(var componentType : Class in _components)
			{
				disposeComponent(Component(_components[componentType]));
			}
			
			_components = null;
			
			Engine.getInstance().removeGameObject(this);
		}
		
		isotopeInternal function disposeComponent(component:Component) : void
		{
			RemoveComponent(Object(component).constructor);
			component.dispose();
		}
	}
}