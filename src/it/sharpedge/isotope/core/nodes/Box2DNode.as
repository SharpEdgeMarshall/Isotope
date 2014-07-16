package it.sharpedge.isotope.core.nodes
{
	import it.sharpedge.isotope.core.Node;
	import it.sharpedge.isotope.core.components.Box2DCollider;
	import it.sharpedge.isotope.core.components.Transform;
	
	public class Box2DNode extends Node
	{
		public var transform : Transform;
		public var collider : Box2DCollider;
	}
}