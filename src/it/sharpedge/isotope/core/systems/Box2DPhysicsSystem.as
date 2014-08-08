package it.sharpedge.isotope.core.systems
{
	import flash.display.Sprite;
	import flash.geom.Vector3D;
	import flash.utils.Dictionary;
	
	import Box2D.Collision.Shapes.b2CircleShape;
	import Box2D.Collision.Shapes.b2PolygonShape;
	import Box2D.Collision.Shapes.b2Shape;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2BodyDef;
	import Box2D.Dynamics.b2DebugDraw;
	import Box2D.Dynamics.b2Fixture;
	import Box2D.Dynamics.b2FixtureDef;
	import Box2D.Dynamics.b2World;
	
	import it.sharpedge.isotope.core.Component;
	import it.sharpedge.isotope.core.System;
	import it.sharpedge.isotope.core.base.isotopeInternal;
	import it.sharpedge.isotope.core.components.Box2DRigidBody;
	import it.sharpedge.isotope.core.components.Transform;
	import it.sharpedge.isotope.core.components.colliders.BoxCollider2D;
	import it.sharpedge.isotope.core.components.colliders.CircleCollider2D;
	import it.sharpedge.isotope.core.components.colliders.Collider2D;
	import it.sharpedge.isotope.core.components.colliders.PolygonCollider2D;
	import it.sharpedge.isotope.core.lists.NodeList;
	import it.sharpedge.isotope.core.nodes.Box2DNode;
	import it.sharpedge.isotope.core.nodes.Collider2DNode;
	
	use namespace isotopeInternal;
	
	public class Box2DPhysicsSystem extends System
	{
	
		private static const DELTA_TIME : Number = 1/60 * 1000;
		private static const ITERATIONS : Number = 10;
		
		private var world:b2World;
		
		[Inject(nodeType="it.sharpedge.isotope.core.nodes.Collider2DNode"]
		public var colNodes : NodeList;
		
		[Inject(nodeType="it.sharpedge.isotope.core.nodes.Box2DNode"]
		public var rbNodes : NodeList;
		
		[Inject(name="MainView")]
		public var view : Sprite;
		
		private var coll2Fix : Dictionary = new Dictionary();
		
		private var accumulator : Number = 0;
		
		private var tcolNode : Collider2DNode;
		private var trbNode : Box2DNode;
		private var tPos : b2Vec2;
		private var tVecPos : Vector3D;
		private var tVecRot : Vector3D;
		
		
		//Debug
		private var _debugEnabled : Boolean = false;

		public function get debugEnabled():Boolean
		{
			return _debugEnabled;
		}

		public function set debugEnabled(value:Boolean):void
		{
			if(value == _debugEnabled) return;
			
			_debugEnabled = value;
			
			if(_debugEnabled)
				enableDebug();
			else
				disableDebug();
		}

		private var debugSprite : Sprite;
		private var dbgDraw:b2DebugDraw;
		
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
			bDef.type = b2Body.b2_dynamicBody;
			
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
				trsf = trsf.parent;
			}			
		}
		
		private function onColliderChanged(collider : Collider2D):void
		{
			
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
				
				trsf = trsf.parent;
			}	
		}
		
		private function addCollider2RigidBody(rigidBody : Box2DRigidBody, collider : Collider2D) : void
		{
			var fixDef : b2FixtureDef = new b2FixtureDef();
			fixDef.density = collider.density;
			fixDef.friction = collider.friction;
			fixDef.restitution = collider.bounciness;
			
			fixDef.shape = getShape(collider);
			
			coll2Fix[collider] = rigidBody.body.CreateFixture(fixDef);
			
		}
		
		private function removeCollider2RigidBody(rigidBody : Box2DRigidBody, collider : Collider2D) : void
		{
			rigidBody.body.DestroyFixture(coll2Fix[collider] as b2Fixture);
			
			coll2Fix[collider] = null;
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
				if(!trbNode.rigidBody.body.IsActive() || !trbNode.rigidBody.body.IsAwake() || trbNode.rigidBody.static)
					continue;
				
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
			
			if(_debugEnabled)
				world.DrawDebugData();
			
		}
		
		private function getShape(collider : Collider2D) : b2Shape
		{
			var shape : b2Shape;
			
			if(collider is CircleCollider2D)
			{
				shape = new b2CircleShape(CircleCollider2D(collider).radius);
			}
			else if(collider is BoxCollider2D)
			{
				shape = b2PolygonShape.AsBox(BoxCollider2D(collider).height, BoxCollider2D(collider).width);
			}
			else if(collider is PolygonCollider2D)
			{
				var stdVertices : Vector.<Vector3D> = PolygonCollider2D(collider).vertices;
				var vertices : Vector.<b2Vec2> = new Vector.<b2Vec2>();
				
				for each( var vertex : Vector3D in stdVertices)
				{
					vertices.push(new b2Vec2(vertex.x, vertex.y));
				}
				
				shape = b2PolygonShape.AsVector(vertices, vertices.length);
			}			
			
			return shape;
		}
		
		private function enableDebug():void
		{			
			if(!dbgDraw)
			{
				//debugSprite is some sprite that we want to draw our debug shapes into.
				debugSprite = new Sprite();
				
				
				// set debug draw
				dbgDraw = new b2DebugDraw();
				
				dbgDraw.SetSprite(debugSprite);
				dbgDraw.SetDrawScale(10.0);
				dbgDraw.SetFillAlpha(0.3);
				dbgDraw.SetLineThickness(1.0);
				dbgDraw.SetFlags(b2DebugDraw.e_shapeBit | b2DebugDraw.e_jointBit);
			}
			
			view.addChild(debugSprite);
			world.SetDebugDraw(dbgDraw);
		}
		
		private function disableDebug():void
		{
			world.SetDebugDraw(null);
			view.removeChild(debugSprite);
			
		}
			
	}
}