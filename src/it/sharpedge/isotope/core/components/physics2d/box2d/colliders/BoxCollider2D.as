package it.sharpedge.isotope.core.components.physics2d.box2d.colliders
{
	import flash.geom.Vector3D;
	
	import Box2D.Collision.Shapes.b2PolygonShape;
	import Box2D.Collision.Shapes.b2Shape;
	
	import it.sharpedge.isotope.core.Component;
	import it.sharpedge.isotope.core.base.isotopeInternal;
	
	use namespace isotopeInternal;
	
	public class BoxCollider2D extends Collider2D
	{
		private var _shape : b2PolygonShape;
		
		private var _center : Vector3D = new Vector3D;
		
		private var _width : Number = 10;
		private var _height : Number = 10;

		

		override isotopeInternal function get shape() : b2Shape
		{
			return fixture ? fixture.GetShape() : _shape;
		}
		
		public function get width():Number
		{
			return _width;
		}		
		
		public function get center():Vector3D
		{
			return _center;
		}
		
		public function set center(value:Vector3D):void
		{
			if(_center.equals(value)) return;
			
			_center = value;
		}
		
		public function set width(value:Number):void
		{
			if(_width == value) return;
			
			_width = value;
			
			updateMeasures();
		}
		
		public function get height():Number
		{
			return _height;
		}

		public function set height(value:Number):void
		{
			if(_height == value) return;
			
			_height = value;
			
			updateMeasures();
		}

		
		public function BoxCollider2D()
		{
			super("BoxCollider2D");
			
			_shape = b2PolygonShape.AsBox(_width, _height);
		}		
		
		private function updateMeasures():void
		{
			b2PolygonShape(shape).SetAsBox(_width, _height);
		}

		override isotopeInternal function dispose():void
		{
			_shape = b2PolygonShape.AsBox(_width, _height);
		}
		
		override isotopeInternal function clone():Component
		{
			return null;
		}

	}
}