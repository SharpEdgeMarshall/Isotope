package it.sharpedge.isotope.core.components.colliders
{
	import it.sharpedge.isotope.core.Component;
	import it.sharpedge.isotope.core.base.isotopeInternal;
	
	public class CircleCollider2D extends Collider2D
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

		
		public function CircleCollider2D()
		{
			super("CircleCollider2D");
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