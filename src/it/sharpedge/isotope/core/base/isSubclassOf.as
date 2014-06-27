package it.sharpedge.isotope.core.base
{
	public function isSubclassOf(a:Class, b:Class): Boolean
	{
		if (int(!a) | int(!b)) return false;
		return (a == b || a.prototype instanceof b);
	}
}