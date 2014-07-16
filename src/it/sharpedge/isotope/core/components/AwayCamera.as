package it.sharpedge.isotope.core.components
{
	import away3d.cameras.Camera3D;
	
	import it.sharpedge.isotope.core.Behaviour;
	import it.sharpedge.isotope.core.base.isotopeInternal;
	
	use namespace isotopeInternal;
	
	public class AwayCamera extends Behaviour
	{
		private static var _main : AwayCamera;		
		
		public static function get main():AwayCamera
		{
			return _main;
		}
		
		isotopeInternal static function set mainCamera(value:AwayCamera):void
		{
			_main = value;
		}
		
		isotopeInternal var camera : Camera3D;
		
		public function AwayCamera()
		{
			super("AwayCamera");
			
			camera = new Camera3D();
		}
		
		//TODO camera component

		
		

	}
}