package it.sharpedge.isotope.core.components
{
	import flash.display.Sprite;
	import flash.geom.Vector3D;
	
	import away3d.cameras.Camera3D;
	import away3d.cameras.lenses.OrthographicLens;
	import away3d.cameras.lenses.PerspectiveLens;
	
	import it.sharpedge.isotope.core.Behaviour;
	import it.sharpedge.isotope.core.base.isotopeInternal;
	import it.sharpedge.isotope.core.utils.enums.CameraType;
	
	use namespace isotopeInternal;
	
	public class AwayCamera extends Behaviour
	{
		[Inject(name="MainView")]
		public var view : Sprite;
		
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
		private var _nearClip : Number = 1;
		private var _farClip : Number = 10000;
		
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
			
			setupCameraLens();
		}
		
		private function setupCameraLens():void
		{
			camera.lens.near = _nearClip;
			camera.lens.far = _farClip;
		}
		
		public function set nearClip(value:Number):void
		{
			_nearClip = value;
			
			camera.lens.near = value;
		}
		
		public function set farClip(value:Number):void
		{
			_farClip = value;
			
			camera.lens.far = value;
		}
		
		public function AwayCamera()
		{
			super("AwayCamera");
			
			camera = new Camera3D();
			setupCameraLens();
		}
		
		public function ScreenToWorldPoint(point:Vector3D):Vector3D
		{
			var width : Number = view.width/2;
			var height : Number = view.height/2;
			
			return camera.unproject((point.x - width)/width,(point.y - height)/height, point.z);
		}
		
		//TODO camera component

		
		

	}
}