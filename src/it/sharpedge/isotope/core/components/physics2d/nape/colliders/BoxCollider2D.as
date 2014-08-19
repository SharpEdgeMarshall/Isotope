package it.sharpedge.isotope.core.components.physics2d.nape.colliders
{
	import flash.geom.Vector3D;
	
	import it.sharpedge.isotope.core.Component;
	import it.sharpedge.isotope.core.base.isotopeInternal;
	
	import nape.phys.Body;
	import nape.shape.Polygon;
	
	use namespace isotopeInternal;
	
	public class BoxCollider2D extends Collider2D
	{		
		private var _center : Vector3D = new Vector3D;
		
		private var _width : Number = 10;
		private var _height : Number = 10;

		
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
			
			updateMeasures();
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
			
			updateMeasures();
		}		
		
		private function updateMeasures():void
		{

			if(shape && shape.body)
			{
				var bd : Body = shape.body;
				bd.shapes.remove(shape);
				shape = new Polygon(Polygon.rect(_center.x, center.y, _width, _height, true));
				bd.shapes.add(shape);
			}
			else
			{			
				shape = new Polygon(Polygon.rect(_center.x, center.y, _width, _height, true));
			}
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