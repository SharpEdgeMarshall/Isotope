package it.sharpedge.isotope.core.systems
{
	import flash.geom.Vector3D;
	
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2BodyDef;
	import Box2D.Dynamics.b2World;
	
	import it.sharpedge.isotope.core.Component;
	import it.sharpedge.isotope.core.System;
	import it.sharpedge.isotope.core.base.isotopeInternal;
	import it.sharpedge.isotope.core.components.Box2DRigidBody;
	import it.sharpedge.isotope.core.components.Transform;
	import it.sharpedge.isotope.core.components.colliders.Collider2D;
	import it.sharpedge.isotope.core.lists.NodeList;
	import it.sharpedge.isotope.core.nodes.Box2DNode;
	import it.sharpedge.isotope.core.nodes.Collider2DNode;
	
	use namespace isotopeInternal;
	
	public class Box2DPhysicsSystem extends System
	{
	
		private static const DELTA_TIME : Number = 1/60;
		private static const ITERATIONS : Number = 10;
		
		private var world:b2World;
		
		[Inject(nodeType="it.sharpedge.isotope.core.nodes.Collider2DNode"]
		public var colNodes : NodeList;
		
		[Inject(nodeType="it.sharpedge.isotope.core.nodes.Box2DNode"]
		public var rbNodes : NodeList;
		
		private var accumulator : Number = 0;
		
		private var tcolNode : Collider2DNode;
		private var trbNode : Box2DNode;
		private var tPos : b2Vec2;
		private var tVecPos : Vector3D;
		private var tVecRot : Vector3D;
		
		[PostConstruct]
		public function init() : void
		{			
			world = new b2World(new b2Vec2(0,-9.8), true);
			
			for( tcolNode = colNodes.head; tcolNode; tcolNode = tcolNode.next )
			{
				onColliderAdded( tcolNode );
			}			
			colNodes.nodeAdded.add( onColliderAdded );
			colNodes.nodeRemoved.add( onColliderRemoved );
			
			for( trbNode = rbNodes.head; trbNode; trbNode = trbNode.next )
			{
				onRigidBodyAdded( trbNode );
			}
			rbNodes.nodeAdded.add( onRigidBodyAdded );
			rbNodes.nodeRemoved.add( onRigidBodyRemoved );
		}
		
		private function onRigidBodyAdded(node : Box2DNode) : void
		{	
			//TODO handle kinetic w/ transform change
			
			//Create Box2D Body
			var bDef : b2BodyDef = new b2BodyDef();
			tVecPos  = node.transform.position;
			bDef.position = new b2Vec2(tVecPos.x, tVecPos.y);
			
			node.rigidBody.body = world.CreateBody(bDef);
			
			//Find all Colliders children of the gameobject containing the RigidBody
			var colVec : Vector.<Component> = node.gameObject.GetComponentsInChildren(Collider2D);
			
			for each(var colComp : Collider2D in colVec)
			{
				addCollider2RigidBody(node.rigidBody, colComp);
			}
		}
		
		
		private function onRigidBodyRemoved(node : Box2DNode) : void
		{
			//Find all Colliders children of the gameobject containing the RigidBody
			var colVec : Vector.<Component> = node.gameObject.GetComponentsInChildren(Collider2D);
			
			for each(var colComp : Collider2D in colVec)
			{
				removeCollider2RigidBody(node.rigidBody, colComp);
			}
			
			//Destroy Box2D Body
			world.DestroyBody(node.rigidBody.body);
		}
		
		private function onColliderAdded(node : Collider2DNode) : void
		{	
			node.collider.changed.add(onColliderChanged);
			
			var trsf : Transform = node.gameObject.transform;
			var trbComp : Box2DRigidBody;			
			
			//Find all RigiBodies parent of the gameobject containing the Collider
			while(trsf != null)
			{
				trbComp = trsf.GetComponent(Box2DRigidBody) as Box2DRigidBody;
				if(trbComp)
					addCollider2RigidBody(trbComp, node.collider);
			}			
		}
		
		private function onColliderChanged(colComp : Collider2D):void
		{
			// TODO find a way to remove and re add fixture to handle change in collider
			
		}		
		
		private function onColliderRemoved(node : Collider2DNode) : void
		{
			var trsf : Transform = node.gameObject.transform;
			var trbComp : Box2DRigidBody;			
			
			//Find all RigiBodies parent of the gameobject containing the Collider
			while(trsf != null)
			{
				trbComp = trsf.GetComponent(Box2DRigidBody) as Box2DRigidBody;
				if(trbComp)
					removeCollider2RigidBody(trbComp, node.collider);
			}	
		}
		
		private function addCollider2RigidBody(rigidBody : Box2DRigidBody, collider : Collider2D) : void
		{
			//rigidBody.body.c
			//TODO add fixture
		}
		
		private function removeCollider2RigidBody(rigidBody : Box2DRigidBody, collider : Collider2D) : void
		{
			//TODO remove fixture
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
			
			for ( trbNode = rbNodes.head; trbNode; trbNode = trbNode.next )
			{	
				//Set Position
				tPos = trbNode.rigidBody.body.GetPosition();
				
				tVecPos = trbNode.transform.position;
				tVecPos.x = tPos.x;
				tVecPos.y = tPos.y;
				
				trbNode.transform.position = tVecPos;
				
				//Set Rotation
				tVecRot = trbNode.transform.rotation;				
				tVecRot.z = trbNode.rigidBody.body.GetAngle();
				
				trbNode.transform.rotation = tVecRot;
			}
			
		}
	}
}