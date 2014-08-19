package it.sharpedge.isotope.core.nodes
{
	import it.sharpedge.isotope.core.Node;
	import it.sharpedge.isotope.core.components.Transform;
	import it.sharpedge.isotope.core.components.physics2d.nape.RigidBody2D;
	
	public class NapeRBNode extends Node
	{
		public var transform : Transform;
		public var rigidBody : RigidBody2D;
	}
}