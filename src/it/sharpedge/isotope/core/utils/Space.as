package it.sharpedge.isotope.core.utils
{
	import it.sharpedge.isotope.core.base.Enum;

	public final class Space extends Enum
	{
		{initEnum(Space);} // static ctor
		
		public static const SELF:Space = new Space();
		public static const WORLD:Space = new Space();
	}
}