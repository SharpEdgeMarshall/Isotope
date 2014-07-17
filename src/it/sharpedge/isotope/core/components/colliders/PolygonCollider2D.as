package it.sharpedge.isotope.core.components.colliders
{
	import it.sharpedge.isotope.core.Component;
	import it.sharpedge.isotope.core.base.isotopeInternal;
	
	public class PolygonCollider2D extends Collider2D
	{
		private var _radius : Number = 5;		

		public function get radius():Number
		{
			return _radius;
		}
		
		public function set radius(value:Number):void
		{
			_radius = value;
		}

		
		public function PolygonCollider2D()
		{
			super("PolygonCollider2D");
		}		

		override isotopeInternal function dispose():void
		{

		}
		
		override isotopeInternal function clone():Component
		{
			return null;
		}

	}
}