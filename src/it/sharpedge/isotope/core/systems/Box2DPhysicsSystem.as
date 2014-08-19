package it.sharpedge.isotope.core.systems
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Vector3D;
	
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2DebugDraw;
	import Box2D.Dynamics.b2Fixture;
	import Box2D.Dynamics.b2World;
	
	import away3d.core.math.MathConsts;
	
	import it.sharpedge.isotope.core.System;
	import it.sharpedge.isotope.core.base.isotopeInternal;
	import it.sharpedge.isotope.core.components.Transform;
	import it.sharpedge.isotope.core.components.physics2d.box2d.RigidBody2D;
	import it.sharpedge.isotope.core.components.physics2d.box2d.colliders.Collider2D;
	import it.sharpedge.isotope.core.lists.NodeList;
	import it.sharpedge.isotope.core.nodes.Box2DNode;
	import it.sharpedge.isotope.core.nodes.Collider2DNode;
	
	use namespace isotopeInternal;
	//TODO dispose
	public class Box2DPhysicsSystem extends System
	{
	
		private static const DELTA_TIME : Number = 1/30;
		private static const ITERATIONS : Number = 5;
		
		private var world:b2World;
		
		[Inject(nodeType="it.sharpedge.isotope.core.nodes.Collider2DNode"]
		public var colNodes : NodeList;
		
		[Inject(nodeType="it.sharpedge.isotope.core.nodes.Box2DNode"]
		public var rbNodes : NodeList;
		
		[Inject(name="MainView")]
		public var view : Sprite;
		
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
			var rigidBody : RigidBody2D = node.rigidBody;
					
			rigidBody.body = world.CreateBody(rigidBody.GetBodyDef());			
			
			//Find all Colliders children of the gameobject containing the RigidBody and Apply if match
			searchAndApplyCollidersInChildren(node.gameObject.transform, rigidBody);
		}
		
		private function searchAndApplyCollidersInChildren(transform : Transform, rigidBody : RigidBody2D):void
		{
			var colliders : Vector.<Collider2D>;
			var tRB : RigidBody2D;			
			
			colliders = transform.gameObject.GetComponents(Collider2D) as Vector.<Collider2D>;
			
			for each(var collider : Collider2D in colliders)
			{
				applyCollider2RigidBody(collider, rigidBody);
			}
			
			for each(var child : Transform in transform.children)
			{
				//If there is a RigidBody abort because it has precedence on its own children Colliders
				tRB = child.gameObject.GetComponent(RigidBody2D) as RigidBody2D;
				
				if(!tRB)					
					searchAndApplyCollidersInChildren(child, rigidBody);
			}
			
		}
		
		
		private function onRigidBodyRemoved(node : Box2DNode) : void
		{
			var body : b2Body = node.rigidBody.body;
			
			var fixture : b2Fixture = body.GetFixtureList();
			var tFixture : b2Fixture;		
			
			//reassign colliders to parent rigidbody if there is one
			//Start from the parent to avoid false positive
			var parentRB : RigidBody2D = node.gameObject.transform.parent.gameObject.GetComponentInParent(RigidBody2D) as RigidBody2D;
			
			while(fixture)
			{
				tFixture = fixture;
				fixture = fixture.GetNext();
				
				if(parentRB)
					applyCollider2RigidBody(tFixture.GetUserData() as Collider2D, parentRB);
				else
					removeCollider2RigidBody(tFixture.GetUserData() as Collider2D);
			}
			
			//Destroy Box2D Body
			world.DestroyBody(body);
		}
		
		private function onColliderAdded(node : Collider2DNode) : void
		{				
			var rigidBody : RigidBody2D;			
			
			//Find first RigiBody parent of the gameobject containing the Collider and create Fixture

			rigidBody = node.gameObject.GetComponentInParent(RigidBody2D) as RigidBody2D;
			if(rigidBody)
			{
				applyCollider2RigidBody(node.collider, rigidBody);
			}					
		}	
		
		private function onColliderRemoved(node : Collider2DNode) : void
		{
			removeCollider2RigidBody(node.collider);
		}
		
		private function applyCollider2RigidBody(collider:Collider2D, rigidBody:RigidBody2D):void
		{
			//If it's assigned to another body destroy first			
			removeCollider2RigidBody(collider);
			
			collider.fixture = rigidBody.body.CreateFixture(collider.GetFixtureDef());
		}
		
		private function removeCollider2RigidBody(collider:Collider2D):void
		{
			var fixt : b2Fixture = collider.fixture;
			//If the Collider belongs to a RigidBody delete the Fixture
			if(fixt)
			{
				fixt.SetUserData(null);
				fixt.GetBody().DestroyFixture(fixt);
				collider.fixture = null;
			}
		}
		
		
		override public function Update(time : int) : void
		{
			accumulator += time * 0.001;
			
			while ( accumulator >= DELTA_TIME)
			{
				world.Step(DELTA_TIME, ITERATIONS, ITERATIONS);
				accumulator -= DELTA_TIME;
			}
			
			world.ClearForces();
			
			for ( trbNode = rbNodes.head; trbNode; trbNode = trbNode.next )
			{	
				if(!trbNode.rigidBody.body.IsActive() || trbNode.rigidBody.static)
					continue;
				
				//Set Position
				tPos = trbNode.rigidBody.body.GetPosition();
				
				tVecPos = trbNode.transform.position;
				tVecPos.x = tPos.x;
				tVecPos.y = tPos.y;
				
				trbNode.transform.position = tVecPos;
				
				//Set Rotation
				tVecRot = trbNode.transform.rotation;				
				tVecRot.z = trbNode.rigidBody.body.GetAngle() * MathConsts.RADIANS_TO_DEGREES;
				
				trbNode.transform.rotation = tVecRot;
			}
			
			if(_debugEnabled)
				world.DrawDebugData();
			
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
			
			view.stage.addEventListener(Event.RESIZE, onResizeView);
			onResizeView();
		}
		
		private function disableDebug():void
		{
			world.SetDebugDraw(null);
			view.removeChild(debugSprite);
			view.stage.removeEventListener(Event.RESIZE, onResizeView);
		}
		
		private function onResizeView(e:Event=null):void
		{
			debugSprite.x = view.stage.stageWidth/2;
			debugSprite.y = view.stage.stageHeight/2;
		}
			
	}
}