package it.sharpedge.isotope.core
{
	import flash.errors.IllegalOperationError;
	import flash.utils.Dictionary;
	
	import it.sharpedge.isotope.core.base.IsotopeObject;
	import it.sharpedge.isotope.core.base.isSubclassOf;
	import it.sharpedge.isotope.core.base.isotopeInternal;
	import it.sharpedge.isotope.core.components.ScriptBehaviour;
	import it.sharpedge.isotope.core.components.ScriptsContainer;
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
		
		//Component Cache
		private var _transform : Transform;
		private var _scriptsCont : ScriptsContainer;


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
			return _transform;
		}
		
		
		public function GameObject(name:String = "")
		{
			
			super(getIsotopeAccess(), (name == "") ? "GameObject " + ++gObjCount : name);
			
			//Init vars
			_components = new Dictionary();
			createSignals();
			
			Engine.getInstance().addGameObject(this);
			
			_transform = AddComponent(Transform) as Transform;
			_scriptsCont = AddComponent(ScriptsContainer) as ScriptsContainer;
			
		}
		
		private function createSignals() : void
		{
			_componentAdded = new Signal(GameObject, Component);
			_componentRemoving = new Signal(GameObject, Component);
			_componentRemoved = new Signal(GameObject, Component);
			_destroying = new Signal(GameObject);
			_destroyed = new Signal(GameObject);
		}
		
		private function disposeSignals() : void
		{
			_componentAdded.removeAll();
			_componentAdded = null;
			
			_componentRemoving.removeAll();
			_componentRemoving = null;
			
			_componentRemoved.removeAll();
			_componentRemoved = null;
			
			_destroying.removeAll();
			_destroying = null;
			
			_destroyed.removeAll();
			_destroyed = null;
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
			for each(var childTransf : Transform in _transform._children)
			{
				childTransf._gameObject.SetActiveInHierarchy(state);
			}
		}		
		
		public function AddComponent(componentType:Class): Component
		{
			//Check if we are adding a Component
			if(!isSubclassOf(componentType, Component))
			{
				throw new IllegalOperationError("The Class: " + componentType + " doesn't inherit from Component");
				return null;
			}
			
			//Check if we already have that Component
			if(_components[componentType])
			{
				throw new IllegalOperationError("The Component: " + componentType + " is already added to the GameObject!");
				return null;
			}
			
			//Get component from Pool
			var component : Component = ComponentPool.getComponent(componentType);
			
			component.setGameObject(this);
			
			//Check if want to add a Script
			if(component is ScriptBehaviour)
			{
				_scriptsCont.addScript(component as ScriptBehaviour);
				
			}
			else
			{				
				_components[componentType] = component;	
				
				_componentAdded.dispatch(this, component);
			}			
			
			
			
			return component;
		}
		
		isotopeInternal function RemoveComponent(componentType:Class) : void
		{
			
			var component : Component = _components[ componentType ] as Component;
			
			if(component)
			{
				delete _components[componentType];
			}			
		}
		
		isotopeInternal function RemoveScript(script:ScriptBehaviour) : void
		{
			_scriptsCont.removeScript(script);
		}
		
		public function GetComponent(componentType:Class) : Component
		{
			//Search script or component
			if(isSubclassOf(componentType, ScriptBehaviour))
			{
				return _scriptsCont.getScript(componentType);
			}
			else
			{
			
				for each(var comp : Component in _components)
				{
					if(comp is componentType)
						return comp;
				}
				
				return null;
			}
		}
		
		public function GetComponents(componentType:Class) : Vector.<Component>
		{
			//Search script or component
			if(isSubclassOf(componentType, ScriptBehaviour))
			{
				return Vector.<Component>(_scriptsCont.getScripts(componentType));
			}
			else
			{
			
				var comps : Vector.<Component> = new Vector.<Component>();			
				
				for each(var comp : Component in _components)
				{
					if(comp is componentType)
						comps.push(comp);
				}
				
				return comps;
			}
		}
		
		public function GetComponentInChildren(componentType:Class) : Component
		{
			var comp : Component = GetComponent(componentType);
			
			if(comp)
				return comp;
			else
			{
				for each(var childTransf : Transform in _transform._children)
				{
					comp = childTransf._gameObject.GetComponentInChildren(componentType);
					
					if(comp)
						return comp;
				}
			}
			
			return null;
		}
		
		public function GetComponentInParent(componentType:Class) : Component
		{
			var comp : Component = GetComponent(componentType);
			
			if(comp)
				return comp;
			else
			{
				if(transform.parent)
					return transform.parent._gameObject.GetComponentInParent(componentType);
					
				else
					return null;
				
			}
		}
		
		
		//TODO optimize all GetComponents passing the Vector around
		public function GetComponentsInChildren(componentType:Class) : Vector.<Component>
		{
			var comps : Vector.<Component> = GetComponents(componentType);			

			for each(var childTransf : Transform in _transform._children)
			{					
				comps = comps.concat(childTransf.gameObject.GetComponentsInChildren(componentType));					
			}			
			
			return comps;
		}
		
		public function GetComponentsInParent(componentType:Class) : Vector.<Component>
		{
			var comps : Vector.<Component> = GetComponents(componentType);
			
			if(transform.parent)
				comps = comps.concat(transform.parent.gameObject.GetComponentsInParent(componentType));				
			
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
		
		isotopeInternal function executeMessage(methodName : String, value : *) : Boolean
		{
			var found : Boolean = false;
			for each(var script : ScriptBehaviour in _scriptsCont.scripts)
			{
				if(methodName in script)
				{
					found = true;
					script[methodName](value);
				}
			}
			
			return found;
		}
		
		isotopeInternal function executeMessageUpdwards(methodName : String, value : *) : Boolean
		{
			var found : Boolean = executeMessage(methodName, value);
			
			if(this.transform.parent)
			{
				found = found || _transform.parent.gameObject.executeMessageUpdwards(methodName, value);
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
			
			//clone scripts
			for each(var script : ScriptBehaviour in _scriptsCont.scripts)
			{
				cComp = script.clone();
				cComp.setGameObject(cGObj);
				ScriptsContainer(cGObj._components[ScriptsContainer]).addScript(cComp as ScriptBehaviour);
			}
			
			//Clone child
			for each(var child : Transform in _transform._children)
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
			_destroying.dispatch(this);
			
			//Recursive destroy children from the deepest
			for each(var child : Transform in _transform._children)
			{
				child._gameObject.dispose();
			}			
			
			//Remove scripts			
			for each(var script : ScriptBehaviour in _scriptsCont.scripts)
			{
				disposeComponent(script);
			}
			
			//Remove all components
			for each(var component : Component in _components)
			{
				disposeComponent(component);				
			}
			
			_components = null;
			
			_transform = null;
			_scriptsCont = null;
			
			//Say all that we finished destroying this game object
			_destroyed.dispatch(this);
			
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
			
			
			//Remove the component from this gameobject
			if(component is ScriptBehaviour)
			{
				RemoveScript(component as ScriptBehaviour); //If script just remove and dispose
			}
			else
			{
				//Say all that the component is going to be removed
				_componentRemoving.dispatch(this, component); //If not Script dispatch event
				
				RemoveComponent(Object(component).constructor);
			}
			//Dispose the component
			component.dispose();
			//Send component to Pool to reuse
			ComponentPool.disposeComponent(component);	
			
			if(!(component is ScriptBehaviour))
			{
				//Say all that the component has been removed
				_componentRemoved.dispatch(this, component); //If not Script dispatch event
			}
		}
	}
}