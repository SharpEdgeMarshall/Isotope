package it.sharpedge.isotope.core.components
{
	import away3d.cameras.Camera3D;
	import away3d.cameras.lenses.OrthographicLens;
	import away3d.cameras.lenses.PerspectiveLens;
	
	import it.sharpedge.isotope.core.Behaviour;
	import it.sharpedge.isotope.core.base.isotopeInternal;
	import it.sharpedge.isotope.core.utils.CameraType;
	
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
		
		
		public function get type() : CameraType
		{
			if(camera.lens is PerspectiveLens)
				return CameraType.PERSPECTIVE;
			else
				return CameraType.ORTHOGRAPHIC;
		}
		
		public function set type(value:CameraType):void
		{
			if(value == CameraType.PERSPECTIVE)
				camera.lens = new PerspectiveLens();
			else if(value == CameraType.ORTHOGRAPHIC)
				camera.lens = new OrthographicLens();				
		}
		
		public function AwayCamera()
		{
			super("AwayCamera");
			
			camera = new Camera3D();
		}
		
		//TODO camera component

		
		

	}
}