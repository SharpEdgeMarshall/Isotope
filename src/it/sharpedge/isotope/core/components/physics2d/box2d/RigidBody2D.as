package it.sharpedge.isotope.core.components.physics2d.box2d
{
	import flash.geom.Vector3D;
	
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2BodyDef;
	
	import it.sharpedge.isotope.core.Component;
	import it.sharpedge.isotope.core.base.isotopeInternal;
	import it.sharpedge.isotope.core.utils.enums.BodyType;
	import it.sharpedge.isotope.core.utils.enums.ForceMode2D;
	
	use namespace isotopeInternal;
	
	
	//TODO need to update body pos if transform change
	public class RigidBody2D extends Component
	{		
		private var _type : BodyType = BodyType.DYNAMIC;
		private var _bullet : Boolean = false;
		private var _angularDrag : Number = 0.0;
		private var _angularVelocity : Number = 0.0;
		private var _drag : Number = 0.0;
		private var _fixedAngle : Boolean = false;
		private var _velocity : Vector3D = new Vector3D();
		
		isotopeInternal var body : b2Body;
		
		public function get velocity():Vector3D
		{
			return _velocity;
		}

		public function set velocity(value:Vector3D):void
		{
			_velocity = value;
			
			if(body)
				body.SetLinearVelocity(new b2Vec2(_velocity.x, _velocity.y));
		}

		public function get fixedAngle():Boolean
		{
			return _fixedAngle;
		}

		public function set fixedAngle(value:Boolean):void
		{
			_fixedAngle = value;
			
			if(body)
				body.SetFixedRotation(_fixedAngle);
		}

		public function get drag():Number
		{
			return _drag;
		}

		public function set drag(value:Number):void
		{
			_drag = value;
			
			if(body)
				body.SetLinearDamping(_drag);
		}

		public function get angularVelocity():Number
		{
			return _angularVelocity;
		}

		public function set angularVelocity(value:Number):void
		{
			_angularVelocity = value;
			
			if(body)
				body.SetAngularVelocity(_angularVelocity);
		}

		public function get angularDrag():Number
		{
			return _angularDrag;
		}
		
		public function set angularDrag(value:Number):void
		{
			_angularDrag = value;
			
			if(body)
				body.SetAngularDamping(_angularDrag);
		}
		
		public function get kinematic() : Boolean
		{
			return _type == BodyType.KINEMATIC;
		}
		
		public function get static() : Boolean
		{
			return _type == BodyType.STATIC;
		}
		
		public function get type() : BodyType
		{
			return _type;
		}
		
		public function set type(value:BodyType):void
		{
			if(value == _type) return;			
			
			_type = value;
			
			if(body)
				body.SetType(value.Index);	
		}
		
		public function get bullet() : Boolean
		{
			return _bullet;
		}
		
		public function set bullet(value:Boolean) : void
		{
			_bullet = value;
			
			if(body)			
				body.SetBullet(value);
		}
		
		public function get isAwake() : Boolean
		{
			if(!body) return false;
			
			return body.IsAwake();
		}
		
		public function RigidBody2D()
		{
			super(getComponentAccess(), "Box2DRigidBody");
		}
		
		public function AddForce(force:Vector3D, mode:ForceMode2D):void
		{
			if(!body) return;
			
			if(mode == ForceMode2D.FORCE)
				body.ApplyForce(new b2Vec2(force.x, force.y), body.GetWorldCenter());
			else if (mode == ForceMode2D.IMPULSE)
				body.ApplyImpulse(new b2Vec2(force.x, force.y), body.GetWorldCenter());
				
		}
		
		public function AddForceAtPosition(force:Vector3D, position:Vector3D, mode:ForceMode2D):void
		{
			if(!body) return;
			
			if(mode == ForceMode2D.FORCE)
				body.ApplyForce(new b2Vec2(force.x, force.y), new b2Vec2(position.x, position.y));
			else if (mode == ForceMode2D.IMPULSE)
				body.ApplyImpulse(new b2Vec2(force.x, force.y), new b2Vec2(position.x, position.y));
			
		}
		
		public function AddRelativeForce(force:Vector3D, mode:ForceMode2D):void
		{
			//TODO define method
		}
		
		public function AddTorque(torque:Number):void
		{
			if(!body) return;
			
			body.ApplyTorque(torque);
		}
		
		public function Sleep():void
		{
			if(!body) return;
			
			body.SetAwake(false);
		}
		
		public function WakeUp():void
		{
			if(!body) return;
			
			body.SetAwake(true);
		}
		
		isotopeInternal function GetBodyDef() : b2BodyDef
		{
			var bodyDef : b2BodyDef = new b2BodyDef();
			
			bodyDef.type = _type.Index;
			var vec : Vector3D = transform.position;
			bodyDef.position = new b2Vec2(vec.x, vec.y);
			bodyDef.angularDamping = _angularDrag;
			bodyDef.angularVelocity = _angularVelocity;
			bodyDef.bullet = _bullet;
			bodyDef.fixedRotation = _fixedAngle;
			bodyDef.linearDamping = _drag;
			bodyDef.linearVelocity = new b2Vec2(_velocity.x, _velocity.y);
			
			return bodyDef;
		}
		
		override isotopeInternal function dispose():void
		{
			
		}
		
		override isotopeInternal function clone():Component
		{
			return null;
		}
	}
}