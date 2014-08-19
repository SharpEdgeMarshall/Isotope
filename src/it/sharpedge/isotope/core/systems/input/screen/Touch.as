package it.sharpedge.isotope.core.systems.input.screen
{
	import flash.geom.Point;
	
	import it.sharpedge.isotope.core.base.isotopeInternal;
	import it.sharpedge.isotope.core.utils.enums.TouchPhase;

	use namespace isotopeInternal;
	
	public class Touch
	{
		isotopeInternal var _oldTime : int;
		isotopeInternal var _deltaPosition : Point = new Point();
		isotopeInternal var _deltaTime : int;
		isotopeInternal var _fingerId : int;
		isotopeInternal var _phase : TouchPhase;
		isotopeInternal var _position : Point = new Point();

		public function get position():Point
		{
			return _position;
		}

		public function get phase():TouchPhase
		{
			return _phase;
		}

		public function get fingerId():int
		{
			return _fingerId;
		}

		public function get deltaTime():Number
		{
			return _deltaTime;
		}

		public function get deltaPosition():Point
		{
			return _deltaPosition;
		}

	}
}