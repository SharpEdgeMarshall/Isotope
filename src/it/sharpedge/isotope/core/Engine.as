package it.sharpedge.isotope.core
{
	import flash.errors.IllegalOperationError;
	import flash.utils.Dictionary;
	
	import it.sharpedge.isotope.core.base.IsotopeObject;
	import it.sharpedge.isotope.core.base.isotopeInternal;
	import it.sharpedge.isotope.core.lists.NodeList;
	import it.sharpedge.isotope.core.lists.SystemList;
	import it.sharpedge.isotope.core.pool.ComponentPool;
	import it.sharpedge.isotope.core.providers.ComponentMatchingFamily;
	import it.sharpedge.isotope.core.providers.IFamily;
	import it.sharpedge.isotope.core.providers.NodeListProvider;
	
	import org.osflash.signals.Signal;
	import org.swiftsuspenders.Injector;
	import it.sharpedge.isotope.core.base.Component;

	use namespace isotopeInternal;
	
	public class Engine
	{		
		private static var _instance : Engine;
		
		private var _injector : Injector;
		private var _gameObjects : Vector.<GameObject>;
		private var _systems : SystemList;
		private var _families : Dictionary;
		
		//Update
		private var _updating : Boolean = false;
		
		public var updateComplete : Signal;
		
		public function Engine(enforcer : SingletonEnforcer, injector : Injector = null)
		{
			if(!enforcer)
			{
				throw new IllegalOperationError("Cannot istantiate Singleton Engine Class");
				return;
			}
			
			updateComplete = new Signal();
			
			_gameObjects = new Vector.<GameObject>();
			_systems = new SystemList();
			_families = new Dictionary();
			
			_injector = injector != null ? injector : new Injector();
			_injector.map(NodeList).toProvider(new NodeListProvider());
		}

		public function get injector():Injector
		{
			return _injector;
		}

		public function get updating():Boolean
		{
			return _updating;
		}

		public static function getInstance() : Engine
		{
			if( _instance == null ) _instance = new Engine( new SingletonEnforcer() );
			return _instance;
		}
		
		public static function dispose() : void
		{
			if(_instance)
				_instance.dispose();
		}
		
		private function dispose() : void
		{
			
			//Destroy All GameObject
			while(_gameObjects.length > 0)
			{
				IsotopeObject.Destroy(_gameObjects[0]);
			}
			
			//Dispose Systems
			while(_systems.head)
			{
				removeSystem(_systems.head);
			}
			
			//Dispose nodes and Families
			for each(var family : IFamily in _families)
			{
				family.dispose();
			}			
			
			//Dispose Pool			
			ComponentPool.dispose();
			
			_instance = null;
		}
		
		isotopeInternal function addGameObject(gameObject:GameObject) : void
		{
			_gameObjects.push(gameObject);
			gameObject.componentAdded.add(onComponentAdded);
			gameObject.componentRemoved.add(onComponentRemoving);
			gameObject.componentRemoved.add(onComponentRemoved);
		}
				
		isotopeInternal function removeGameObject(gameObject:GameObject) : void
		{
			var index : int = _gameObjects.indexOf(gameObject);
			
			if(index != -1)
			{				
				gameObject.componentAdded.remove(onComponentAdded);
				gameObject.componentRemoved.remove(onComponentRemoving);
				gameObject.componentRemoved.remove(onComponentRemoved);
				_gameObjects.splice(index, 1);
			}
		}
		
		public function addSystem(system:System, priority:int) : void
		{
			_injector.injectInto(system);
			system.priority = priority;
			system.addToEngine();
			_systems.add(system);
		}
		
		public function removeSystem(system:System) : void
		{
			_systems.remove(system);
			system.removeFromEngine();
		}
		
		public function GetSystem(type:Class) : System
		{
			for( var system : System = _systems.head; system; system = system.next )
			{
				if(system is type)
					return system;
			}
			
			return null;
		}
		
		isotopeInternal function find(name:String) : GameObject
		{
			for each(var gObj : GameObject in _gameObjects)
			{
				if(gObj.name == name)
					return gObj;
			}
			
			return null;
		}
		
		isotopeInternal function getNodeList( nodeClass : Class ) : NodeList
		{
			if( _families[nodeClass] )
			{
				return IFamily( _families[nodeClass] ).nodeList;
			}
			
			var family : IFamily = new ComponentMatchingFamily(nodeClass) as IFamily;
			
			_families[nodeClass] = family;
			for each(var gameObject : GameObject in _gameObjects)
			{
				family.newGameObject( gameObject );
			}
			return family.nodeList;
		}
		
		private function onComponentAdded(gameObject:GameObject, component:Component) : void
		{
			injector.injectInto(component);
			
			var type : Class = Object(component).constructor;
			
			for each( var family : IFamily in _families )
			{
				family.componentAddedToGameObject( gameObject, type );
			}
		}
		
		private function onComponentRemoving(gameObject:GameObject, component:Component):void
		{
			var type : Class = Object(component).constructor;
			
			for each( var family : IFamily in _families )
			{
				family.componentRemovedFromGameObject( gameObject, type );
			}	
		}
		
		private function onComponentRemoved(gameObject:GameObject, component:Component) : void
		{
			
		}
		
		public function update( time : int ) : void
		{
			_updating = true;
			for( var system : System = _systems.head; system; system = system.next )
			{
				system.Update( time );
			}
			_updating = false;
			
			updateComplete.dispatch();
		}
	}
}
final class SingletonEnforcer
{
	
}