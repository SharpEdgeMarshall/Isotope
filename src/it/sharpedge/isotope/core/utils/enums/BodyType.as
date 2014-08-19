package it.sharpedge.isotope.core.utils.enums
{
	import it.sharpedge.isotope.core.base.Enum;
	
	public final class BodyType extends Enum
	{
		{initEnum(BodyType);} // static ctor
		
		public static const STATIC:BodyType = new BodyType();
		public static const KINEMATIC:BodyType = new BodyType();		
		public static const DYNAMIC:BodyType = new BodyType();
	}
}