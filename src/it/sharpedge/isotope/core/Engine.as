package it.sharpedge.isotope.core
{
	import it.sharpedge.isotope.core.base.isotopeInternal;

	public class Engine
	{		
		private static var _instance : Engine;
		private var _gameObjects : Vector.<GameObject>;
		
		public function Engine(enforcer : SingletonEnforcer)
		{
		}
		
		public static function getInstance() : Engine
		{
			if( _instance == null ) _instance = new Engine( new SingletonEnforcer() );
			return _instance;
		}
		
		isotopeInternal function addGameObject(gameObject:GameObject) : void
		{
			var index : int = _gameObjects.indexOf(gameObject);
			
			if(index == -1)
				_gameObjects.push(gameObject);
		}
		
		isotopeInternal function removeGameObject(gameObject:GameObject) : void
		{
			var index : int = _gameObjects.indexOf(gameObject);
			
			if(index != -1)
				_gameObjects.splice(index, 1);
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
		
		
	}
}
final class SingletonEnforcer
{
	
}