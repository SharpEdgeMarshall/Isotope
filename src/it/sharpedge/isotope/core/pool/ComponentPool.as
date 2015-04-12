package it.sharpedge.isotope.core.pool
{
	import flash.utils.Dictionary;
	
	import it.sharpedge.isotope.core.base.Component;
	import it.sharpedge.isotope.core.base.isotopeInternal;

	use namespace isotopeInternal;
	
	public class ComponentPool
	{
		private static var MAX_CACHE : int = 100;
		
		private static var pools : Dictionary = new Dictionary();
		
		private static function getPool( componentType:Class ) : Vector.<Object>
		{
			if(pools[componentType])
			{
				return pools[componentType];
			}
			else
			{
				return pools[componentType] = new Vector.<Object>();
			}
		}

		isotopeInternal static function getComponent(componentType:Class) : Component
		{
			var pool:Vector.<Object> = getPool( componentType );
			if( pool.length > 0 )
			{
				return pool.pop() as Component;
			}
			else
			{
				return new componentType() as Component;
			}
		}
		
		isotopeInternal static function disposeComponent(component:Component) : void
		{
			if(component)
			{
				var type : Class = Object(component).constructor as Class;
				var pool:Vector.<Object> = getPool( type );
				
				if(pool.length < MAX_CACHE)
					pool.push(component);
			}
		}
		
		isotopeInternal static function dispose() : void
		{
			pools = new Dictionary();
		}
	}
}