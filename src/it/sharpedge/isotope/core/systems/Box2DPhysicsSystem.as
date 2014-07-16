package it.sharpedge.isotope.core.systems
{
	import flash.geom.Vector3D;
	
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2BodyDef;
	import Box2D.Dynamics.b2World;
	
	import it.sharpedge.isotope.core.System;
	import it.sharpedge.isotope.core.base.isotopeInternal;
	import it.sharpedge.isotope.core.lists.NodeList;
	import it.sharpedge.isotope.core.nodes.Box2DNode;
	
	use namespace isotopeInternal;
	
	public class Box2DPhysicsSystem extends System
	{
	
		private static const DELTA_TIME : Number = 1/60;
		private static const ITERATIONS : Number = 10;
		
		private var world:b2World;
		
		[Inject(nodeType="it.sharpedge.isotope.core.nodes.Box2DNode"]
		public var nodes : NodeList;
		
		private var accumulator : Number = 0;
		
		private var tNode : Box2DNode;
		private var tPos : b2Vec2;
		private var tVecPos : Vector3D;
		private var tVecRot : Vector3D;
		
		[PostConstruct]
		public function init() : void
		{			
			world = new b2World(new b2Vec2(0,-9.8), true);
			
			for( var node : Box2DNode = nodes.head; node; node = node.next )
			{
				onRigidBodyAdded( node );
			}
			nodes.nodeAdded.add( onRigidBodyAdded );
			nodes.nodeRemoved.add( onRigidBodyRemoved );
		}
		
		private function onRigidBodyAdded(node : Box2DNode) : void
		{	
			var bDef : b2BodyDef = new b2BodyDef();
			tVecPos  = node.transform.position;
			bDef.position = new b2Vec2(tVecPos.x, tVecPos.y);
			
			node.collider.body = world.CreateBody(bDef);
		}
		
		
		private function onRigidBodyRemoved(node : Box2DNode) : void
		{
			world.DestroyBody(node.collider.body);
		}	
		
		override public function Update(time : Number) : void
		{
			accumulator += time;
			
			while ( accumulator >= DELTA_TIME )
			{
				world.Step(DELTA_TIME, ITERATIONS, ITERATIONS);
				accumulator -= DELTA_TIME;
			}
			
			world.ClearForces();
			
			for ( tNode = nodes.head; tNode; tNode = tNode.next )
			{	
				//Set Position
				tPos = tNode.collider.body.GetPosition();
				
				tVecPos = tNode.transform.position;
				tVecPos.x = tPos.x;
				tVecPos.y = tPos.y;
				
				tNode.transform.position = tVecPos;
				
				//Set Rotation
				tVecRot = tNode.transform.rotation;				
				tVecRot.z = tNode.collider.body.GetAngle();
				
				tNode.transform.rotation = tVecRot;
			}
			
		}
	}
}