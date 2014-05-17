package it.sharpedge.isotope.core
{
	import flash.errors.IllegalOperationError;
	import flash.utils.Dictionary;
	
	import it.sharpedge.isotope.core.base.IsotopeObject;
	import it.sharpedge.isotope.core.base.isotopeInternal;
	import it.sharpedge.isotope.core.components.Transform;
	import it.sharpedge.isotope.core.pool.ComponentPool;
	
	import org.osflash.signals.Signal;

	use namespace isotopeInternal;
	
	public class GameObject extends IsotopeObject
	{
		private static var gObjCount : int = 0;
		
		private var _components : Dictionary;
		
		private var _activeSelf : Boolean = true;		
		isotopeInternal var _activeInHierarchy : Boolean = true;
		
		private var _componentAdded : Signal;
		private var _componentRemoving : Signal;	
		private var _componentRemoved : Signal;	
		private var _destroying : Signal;
		private var _destroyed : Signal;
		


		public function get componentRemoving():Signal
		{
			return _componentRemoving;
		}

		public function get componentRemoved():Signal
		{
			return _componentRemoved;
		}

		public function get componentAdded():Signal
		{
			return _componentAdded;
		}
		
		public function get destroying():Signal
		{
			return _destroying;
		}		
		
		public function get destroyed():Signal
		{
			return _destroyed;
		}
		
		//Components accessor
		public function get transform() : Transform
		{
			return _components[Transform];
		}
		
		
		public function GameObject(name:String = "")
		{
			
			super(getIsotopeAccess(), (name == "") ? "GameObject " + ++gObjCount : name);
			
			//Init vars
			_components = new Dictionary();
			createSignals();
			
			Engine.getInstance().addGameObject(this);
			
			AddComponent(Transform);
			
		}
		
		private function createSignals() : void
		{
			_componentAdded = new Signal();
			_componentRemoving = new Signal();
			_componentRemoved = new Signal();
			_destroying = new Signal();
			_destroyed = new Signal();
		}
		
		private function disposeSignals() : void
		{
			_componentAdded.removeAll();
			_componentRemoving.removeAll();
			_componentRemoved.removeAll();
			_destroying.removeAll();
			_destroyed.removeAll();
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
			for each(var childTransf : Transform in transform._children)
			{
				childTransf._gameObject.SetActiveInHierarchy(state);
			}
		}		
		
		public function AddComponent(componentType:Class): void
		{
			
			if(_components[componentType])
			{
				disposeComponent(Component(_components[componentType]));				
			}
			
			//Get component from Pool
			var component : Component = ComponentPool.getComponent(componentType);
			
			if(!component)
			{
				throw new IllegalOperationError("The Class doesn't inherit from Component");
				return;
			}
			
			component.setGameObject(this);			
			
			_components[componentType] = component;			
			_componentAdded.dispatch();
		}
		
		isotopeInternal function RemoveComponent(componentType:Class) : void
		{
			var component : Component = _components[ componentType ] as Component;
			
			if(component)
			{
				delete _components[componentType];
			}			
		}
		
		public function GetComponent(componentType:Class) : Component
		{
			for each(var comp : Component in _components)
			{
				if(comp is componentType)
					return comp;
			}
			
			return null;
		}
		
		public function GetComponents(componentType:Class) : Vector.<Component>
		{
			
			var comps : Vector.<Component> = new Vector.<Component>();
			
			for each(var comp : Component in _components)
			{
				if(comp is componentType)
					comps.push(comp);
			}
			
			return comps;
		}
		
		public function GetComponentInChildren(componentType:Class) : Component
		{
			var comp : Component = GetComponent(componentType);
			
			if(comp)
				return comp;
			else
			{
				for each(var childTransf : Transform in transform._children)
				{
					comp = childTransf._gameObject.GetComponentInChildren(componentType);
					
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

			for each(var childTransf : Transform in transform._children)
			{					
				comps = comps.concat(childTransf.gameObject.GetComponentsInChildren(componentType));					
			}
			
			
			return comps;
		}
		
		public function SendMessage(methodName : String, value : * = null, requireReceiver : Boolean = false) : void
		{
			if(!executeMessage(methodName, value))
			{
				//TODO LOG error
				trace("SendMessage receiver not Found");
			}
		}
		
		public function SendMessageUpwards(methodName : String, value : * = null, requireReceiver : Boolean = false) : void
		{
			if(!executeMessageUpdwards(methodName, value))
			{
				//TODO LOG error
				trace("SendMessage receiver not Found");
			}
		}
		
		private function executeMessage(methodName : String, value : *) : Boolean
		{
			var found : Boolean = false;
			
			for each(var component : Component in _components)
			{
				if(methodName in component)
				{
					found = true;
					component[methodName](value);
				}
			}
			
			return found;
		}
		
		isotopeInternal function executeMessageUpdwards(methodName : String, value : *) : Boolean
		{
			var found : Boolean = executeMessage(methodName, value);
			
			if(this.transform.parent)
			{
				found = found || this.transform.parent.gameObject.executeMessageUpdwards(methodName, value);
			}
			
			return found;
		}
		
		isotopeInternal function clone() : GameObject
		{
			var cGObj : GameObject = new GameObject(this.name + " (Clone)");
			var cComp : Component;
			var cChildGObj : GameObject;
			
			cGObj._activeSelf = this._activeSelf;
			
			//Clone components
			for each(var component : Component in _components)
			{
				cComp = component.clone();
				cComp.setGameObject(cGObj);
				cGObj._components[Object(component).constructor] = cComp;
			}
			
			//Clone child
			for each(var child : Transform in transform._children)
			{
				cChildGObj = child.gameObject.clone();
				cChildGObj.transform.parent = cGObj.transform;
			}
			
			return cGObj;
		}
		
		//Static
		/**
		 * Search for a GameObject by name
		 * @param name The name of the GameObject
		 * @return The GameObject if found else null
		 */
		public static function Find(name:String) : GameObject
		{
			return Engine.getInstance().find(name);
		}
		
		/**
		 * Dispose the GameObject
		 */
		isotopeInternal function dispose() : void
		{
			//Say all that we are destroying this game object
			_destroying.dispatch();
			
			//Recursive destroy children from the deepest
			for each(var child : Transform in transform._children)
			{
				child._gameObject.dispose();
			}			
			
			//Remove all components
			for each(var component : Component in _components)
			{
				disposeComponent(component);
			}
			
			_components = null;
			
			//Say all that we finished destroying this game object
			_destroyed.dispatch();
			
			Engine.getInstance().removeGameObject(this);						
			
			//Clear Signal listeners
			disposeSignals();
		}
		
		/**
		 * Called by IsotopeObject.Destroy() when destroying component
		 * Removes the component from the GameObject and dispose it
		 */
		isotopeInternal function disposeComponent(component:Component) : void
		{
			//Say all that the component is going to be removed
			_componentRemoving.dispatch();
			
			//Remove the component from this gameobject
			RemoveComponent(Object(component).constructor);			
			//Dispose the component
			component.dispose();
			//Send component to Pool to reuse
			ComponentPool.disposeComponent(component);	
			
			//Say all that the component has been removed
			_componentRemoved.dispatch();
		}
	}
}