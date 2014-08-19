package it.sharpedge.isotope.core.utils.enums
{
	import it.sharpedge.isotope.core.base.Enum;
	
	public final class TouchPhase extends Enum
	{
		{initEnum(TouchPhase);} // static ctor
		
		public static const BEGAN:TouchPhase = new TouchPhase();
		public static const MOVED:TouchPhase = new TouchPhase();		
		public static const STATIONARY:TouchPhase = new TouchPhase();
		public static const ENDED:TouchPhase = new TouchPhase();
		//public static const CANCELED:TouchPhase = new TouchPhase();
	}
}