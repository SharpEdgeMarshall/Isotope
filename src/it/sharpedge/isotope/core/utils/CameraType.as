package it.sharpedge.isotope.core.utils
{
	import it.sharpedge.isotope.core.base.Enum;
	
	public class CameraType extends Enum
	{
		{initEnum(CameraType);} // static ctor
		
		public static const PERSPECTIVE:CameraType = new CameraType();
		public static const ORTHOGRAPHIC:CameraType = new CameraType();		
	}
}