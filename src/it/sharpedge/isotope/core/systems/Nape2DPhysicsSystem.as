package it.sharpedge.isotope.core.systems
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Vector3D;
	
	import away3d.core.math.MathConsts;
	
	import it.sharpedge.isotope.core.System;
	import it.sharpedge.isotope.core.base.isotopeInternal;
	import it.sharpedge.isotope.core.components.Transform;
	import it.sharpedge.isotope.core.components.physics2d.nape.RigidBody2D;
	import it.sharpedge.isotope.core.components.physics2d.nape.colliders.Collider2D;
	import it.sharpedge.isotope.core.lists.NodeList;
	import it.sharpedge.isotope.core.nodes.NapeColNode;
	import it.sharpedge.isotope.core.nodes.NapeRBNode;
	
	import nape.geom.Vec2;
	import nape.shape.Shape;
	import nape.shape.ShapeList;
	import nape.space.Space;
	import nape.util.BitmapDebug;
	
	use namespace isotopeInternal;
	//TODO dispose
	public class Nape2DPhysicsSystem extends System
	{
	
		private static const DELTA_TIME : Number = 1/30;
		private static const ITERATIONS : Number = 5;
		
		private var world:Space;
		
		[Inject(nodeType="it.sharpedge.isotope.core.nodes.NapeColNode"]
		public var colNodes : NodeList;
		
		[Inject(nodeType="it.sharpedge.isotope.core.nodes.NapeRBNode"]
		public var rbNodes : NodeList;
		
		[Inject(name="MainView")]
		public var view : Sprite;
		
		private var accumulator : Number = 0;
		
		private var tcolNode : NapeColNode;
		private var trbNode : NapeRBNode;
		private var tPos : Vec2;
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
		private var dbgDraw:BitmapDebug;
		
		[PostConstruct]
		public function init() : void
		{			
			world = new Space(new Vec2(0,600));

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
		
		private function onRigidBodyAdded(node : NapeRBNode) : void
		{				
			//Find all Colliders children of the gameobject containing the RigidBody and Apply if match
			searchAndApplyCollidersInChildren(node.gameObject.transform, node.rigidBody);
		}
		
		private function searchAndApplyCollidersInChildren(transform : Transform, rigidBody : RigidBody2D):void
		{
			var colliders : Vector.<Collider2D>;
			var tRB : RigidBody2D;			
			
			rigidBody.body.space = world;
			
			colliders = transform.gameObject.GetComponents(Collider2D) as Vector.<Collider2D>;
			
			for each(var collider : Collider2D in colliders)
			{
				applyCollider2RigidBody(collider.shape, rigidBody);
			}
			
			for each(var child : Transform in transform.children)
			{
				//If there is a RigidBody abort because it has precedence on its own children Colliders
				tRB = child.gameObject.GetComponent(RigidBody2D) as RigidBody2D;
				
				if(!tRB)					
					searchAndApplyCollidersInChildren(child, rigidBody);
			}
			
		}
		
		
		private function onRigidBodyRemoved(node : NapeRBNode) : void
		{
			var shapes : ShapeList = node.rigidBody.body.shapes;
				
			
			//reassign colliders to parent rigidbody if there is one
			//Start from the parent to avoid false positive
			var parentRB : RigidBody2D = node.gameObject.transform.parent.gameObject.GetComponentInParent(RigidBody2D) as RigidBody2D;
			
			while(shapes.length)
			{				
				if(parentRB)
					applyCollider2RigidBody(shapes.pop(), parentRB);
				else
					removeCollider2RigidBody(shapes.pop());
			}
			
			node.rigidBody.body.space = null;
		}
		
		private function onColliderAdded(node : NapeColNode) : void
		{				
			//Find first RigiBody parent of the gameobject containing the Collider and create Fixture

			var rigidBody : RigidBody2D = node.gameObject.GetComponentInParent(RigidBody2D) as RigidBody2D;
			if(rigidBody)
			{
				applyCollider2RigidBody(node.collider.shape, rigidBody);
			}					
		}	
		
		private function onColliderRemoved(node : NapeColNode) : void
		{
			removeCollider2RigidBody(node.collider.shape);
		}
		
		private function applyCollider2RigidBody(shape:Shape, rigidBody:RigidBody2D):void
		{			
			shape.body = rigidBody.body;
		}
		
		private function removeCollider2RigidBody(shape:Shape):void
		{
			shape.body = null;
		}
		
		
		override public function Update(time : int) : void
		{
			accumulator += time * 0.001;
			
			while ( accumulator >= DELTA_TIME)
			{
				world.step(DELTA_TIME, ITERATIONS, ITERATIONS);
				accumulator -= DELTA_TIME;
			}

			
			for ( trbNode = rbNodes.head; trbNode; trbNode = trbNode.next )
			{	
				if(trbNode.rigidBody.body.isSleeping || trbNode.rigidBody.static)
					continue;
				
				//Set Position
				tPos = trbNode.rigidBody.body.position;
				
				tVecPos = trbNode.transform.position;
				tVecPos.x = tPos.x;
				tVecPos.y = tPos.y;
				
				trbNode.transform.position = tVecPos;
				
				//Set Rotation
				tVecRot = trbNode.transform.rotation;				
				tVecRot.z = trbNode.rigidBody.body.rotation * MathConsts.RADIANS_TO_DEGREES;
				
				trbNode.transform.rotation = tVecRot;
			}
			
			if(_debugEnabled)
				dbgDraw.clear();
				dbgDraw.draw(world);
				dbgDraw.flush();
			
		}
		
		private function enableDebug():void
		{			
			if(!dbgDraw)
			{				
				// set debug draw
				dbgDraw = new BitmapDebug(view.width, view.height, 0x000000, true);
			}
			
			view.addChild(dbgDraw.display);
			
			view.stage.addEventListener(Event.RESIZE, onResizeView);
			onResizeView();
		}
		
		private function disableDebug():void
		{			
			view.removeChild(dbgDraw.display);
		}
		
		private function onResizeView(e:Event=null):void
		{
			dbgDraw.display.x = view.stage.stageWidth/2;
			dbgDraw.display.y = view.stage.stageHeight/2;
			dbgDraw.display.width = view.stage.stageWidth;
			dbgDraw.display.width = view.stage.stageHeight;
		}
			
	}
}