package it.sharpedge.isotope.core.utils
{
	import it.sharpedge.isotope.core.base.Enum;
	
	public final class ColliderType extends Enum
	{
		{initEnum(ColliderType);} // static ctor
		
		public static const STATIC:ColliderType = new ColliderType();
		public static const KINEMATIC:ColliderType = new ColliderType();		
		public static const DYNAMIC:ColliderType = new ColliderType();
	}
}