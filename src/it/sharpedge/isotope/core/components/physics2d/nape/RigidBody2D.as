package it.sharpedge.isotope.core.components.physics2d.nape
{
	import flash.geom.Vector3D;
	
	import it.sharpedge.isotope.core.Component;
	import it.sharpedge.isotope.core.base.isotopeInternal;
	import it.sharpedge.isotope.core.utils.enums.ForceMode2D;
	
	import nape.geom.Vec2;
	import nape.phys.Body;
	import nape.phys.BodyType;
	
	use namespace isotopeInternal;
	
	
	//TODO need to update body pos if transform change
	public class RigidBody2D extends Component
	{
		private var _type : BodyType = BodyType.DYNAMIC;
		private var _bullet : Boolean = false;
		private var _angularVelocity : Number = 0.0;
		private var _fixedAngle : Boolean = false;
		private var _fixedPos : Boolean = false;
		private var _velocity : Vector3D = new Vector3D();
		
		isotopeInternal var body : Body;
		
		public function get fixedPos():Boolean
		{
			return _fixedPos;
		}

		public function set fixedPos(value:Boolean):void
		{
			_fixedPos = value;
			body.allowMovement = !value;
		}

		public function get velocity():Vector3D
		{
			return _velocity;
		}

		public function set velocity(value:Vector3D):void
		{
			_velocity = value;
			

			body.velocity = Vec2.weak(value.x, value.y);
		}

		public function get fixedAngle():Boolean
		{
			return _fixedAngle;
		}

		public function set fixedAngle(value:Boolean):void
		{
			_fixedAngle = value;
			
			body.allowRotation = !value;
		}

		public function get angularVelocity():Number
		{
			return _angularVelocity;
		}

		public function set angularVelocity(value:Number):void
		{
			_angularVelocity = value;
			
			body.angularVel = value;
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
			
			body.type = value;	
		}
		
		public function get bullet() : Boolean
		{
			return _bullet;
		}
		
		public function set bullet(value:Boolean) : void
		{
			_bullet = value;
					
			body.isBullet = value;
		}
		
		public function get isAwake() : Boolean
		{			
			return !body.isSleeping();
		}
		
		public function RigidBody2D()
		{
			super(getComponentAccess(), "RigidBody2D");
			body = new Body(BodyType.DYNAMIC, Vec2.weak(transform.position.x, transform.position.y));
		}
		
		public function AddImpulse(force:Vector3D):void
		{			
			body.applyImpulse(Vec2.get(force.x, force.y));				
		}
		
		public function AddImpulseAtPosition(force:Vector3D, position:Vector3D):void
		{			
			body.applyImpulse(Vec2.get(force.x, force.y), Vec2.get(position.x, position.y));			
		}
		
		public function AddRelativeForce(force:Vector3D, mode:ForceMode2D):void
		{
			//TODO define method
		}
		
		public function AddTorque(torque:Number):void
		{			
			body.applyAngularImpulse(torque);
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