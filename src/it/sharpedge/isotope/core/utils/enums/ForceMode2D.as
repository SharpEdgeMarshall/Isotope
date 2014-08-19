package it.sharpedge.isotope.core.utils.enums
{
	import it.sharpedge.isotope.core.base.Enum;
	
	public final class ForceMode2D extends Enum
	{
		{initEnum(ForceMode2D);} // static ctor
		
		public static const FORCE:ForceMode2D = new ForceMode2D();
		public static const IMPULSE:ForceMode2D = new ForceMode2D();		
	}
}