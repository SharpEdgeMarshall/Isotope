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

	use namespace isotopeInternal;
	
	public class Engine
	{		
		private static var _instance : Engine;
		
		private var _injector : Injector;
		private var _gameObjects : Vector.<GameObject>;
		private var _systems : SystemList;
		private var _families : Dictionary;
		
		private var _updating : Boolean = false;
		
		public var updateComplete : Signal;
		
		public function Engine(enforcer : SingletonEnforcer)
		{
			if(!enforcer)
			{
				throw new IllegalOperationError("Cannot istantiate Singleton Engine Class");
				return;
			}
			
			_gameObjects = new Vector.<GameObject>();
			_systems = new SystemList();
			_families = new Dictionary();
			
			_injector = new Injector();
			_injector.map(NodeList).toProvider(new NodeListProvider());
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
			
			//Destroy All GameObject
			while(_gameObjects.length > 0)
			{
				IsotopeObject.Destroy(_gameObjects.pop());
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
		
		isotopeInternal function addSystem(system:System, priority:int) : void
		{
			_injector.injectInto(system);
			system.priority = priority;
			system.addToEngine();
			_systems.add(system);
		}
		
		isotopeInternal function removeSystem(system:System) : void
		{
			_systems.remove(system);
			system.removeFromEngine();
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
			
			var family : IFamily = new ComponentMatchingFamily( nodeClass );
			_families[nodeClass] = family;
			for each(var gameObject : GameObject in _gameObjects)
			{
				family.newGameObject( gameObject );
			}
			return family.nodeList;
		}
		
		private function onComponentAdded() : void
		{
			
		}
		
		private function onComponentRemoving():void
		{
			
			
		}
		
		private function onComponentRemoved() : void
		{
			
		}
		
		public function update( time : Number ) : void
		{
			_updating = true;
			for( var system : System = _systems.head; system; system = system.next )
			{
				system.update( time );
			}
			_updating = false;
			updateComplete.dispatch();
		}
	}
}
final class SingletonEnforcer
{
	
}