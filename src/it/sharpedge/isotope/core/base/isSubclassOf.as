package it.sharpedge.isotope.core.base
{
	public function isSubclassOf(a:Class, b:Class): Boolean
	{
		return ( b.prototype.isPrototypeOf( a.prototype ) );
	}
}