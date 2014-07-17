package it.sharpedge.isotope.core.components.colliders
{
	import it.sharpedge.isotope.core.Component;
	import it.sharpedge.isotope.core.base.isotopeInternal;
	
	public class BoxCollider2D extends Collider2D
	{
		private var _width : Number = 10;
		private var _height : Number = 10;

		public function get width():Number
		{
			return _width;
		}
		
		public function set width(value:Number):void
		{
			if(_width == value) return;
			
			_width = value;
			_changed.dispatch(this);
		}
		
		public function get height():Number
		{
			return _height;
		}

		public function set height(value:Number):void
		{
			if(_width == value) return;
			
			_height = value;
			_changed.dispatch(this);
		}

		
		public function BoxCollider2D()
		{
			super("BoxCollider2D");
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