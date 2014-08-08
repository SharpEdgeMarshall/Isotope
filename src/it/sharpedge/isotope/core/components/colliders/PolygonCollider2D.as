package it.sharpedge.isotope.core.components.colliders
{
	import flash.geom.Vector3D;
	
	import it.sharpedge.isotope.core.Component;
	import it.sharpedge.isotope.core.base.isotopeInternal;
	
	public class PolygonCollider2D extends Collider2D
	{
		private var _vertices : Vector.<Vector3D> = new Vector.<Vector3D>();

		public function get vertices():Vector.<Vector3D>
		{
			return _vertices;
		}
		
		public function get verticesCount():int
		{
			return _vertices.length;
		}
		
		public function PolygonCollider2D()
		{
			super("PolygonCollider2D");
		}	
		
		public function AddVertex(vertex : Vector3D) : void
		{
			if(_vertices.indexOf(vertex) == -1)
				_vertices.push(vertex);
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