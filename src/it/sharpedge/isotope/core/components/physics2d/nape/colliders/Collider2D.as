package it.sharpedge.isotope.core.components.physics2d.nape.colliders
{

	
	import it.sharpedge.isotope.core.Behaviour;
	import it.sharpedge.isotope.core.Component;
	import it.sharpedge.isotope.core.base.isotopeInternal;
	
	import nape.phys.Material;
	import nape.shape.Shape;
	
	use namespace isotopeInternal;
	
	//TODO need to update pos if transform change
	public class Collider2D extends Behaviour
	{	
		private var _shape : Shape;
		
		private var _material : Material;
		
		
		public function get material():Material
		{
			return _material;
		}

		public function set material(value:Material):void
		{
			_material = value;
			
			_shape.material = _material;
		}

		isotopeInternal function get shape() : Shape
		{
			return _shape;
		}
		
		isotopeInternal function set shape(value:Shape):void
		{
			_shape = value;
			
			
			if(_material)
				_shape.material = _material;
			else
				_material = _shape.material;
		}	
		
		
		public function Collider2D(name:String)
		{
			super(name);
		}		

		override isotopeInternal function dispose():void
		{
			_material = null;
		}
		
		override isotopeInternal function clone():Component
		{
			return null;
		}
	}
}