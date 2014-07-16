package it.sharpedge.isotope.core.components
{
	import Box2D.Collision.Shapes.b2Shape;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2FixtureDef;
	
	import it.sharpedge.isotope.core.Component;
	import it.sharpedge.isotope.core.base.isotopeInternal;
	import it.sharpedge.isotope.core.utils.ColliderType;
	
	use namespace isotopeInternal;
	
	public class Box2DCollider extends Component
	{		
		private var collType : ColliderType = ColliderType.DYNAMIC;
		
		isotopeInternal var body : b2Body;
		
		public function get kinematic() : Boolean
		{
			return collType == ColliderType.KINEMATIC;
		}
		
		public function get static() : Boolean
		{
			return collType == ColliderType.STATIC;
		}
		
		public function get type() : ColliderType
		{
			return collType;
		}
		
		public function set type(value:ColliderType):void
		{
			if(value == collType) return;			
			
			collType = value;
			body.SetType(value.Index);	
		}
		
		public function get bullet() : Boolean
		{
			return body.IsBullet();
		}
		
		public function set bullet(value:Boolean) : void
		{
			body.SetBullet(value);
		}
		
		
		public function Box2DCollider()
		{
			super(getComponentAccess(), "Box2DRigidBody");
		}
		
		
		public function AddShape(shape:b2Shape, density:Number=0, friction:Number=0.2, bounciness:Number=0):void
		{
			var fixDef : b2FixtureDef = new b2FixtureDef();
			fixDef.density = density;
			fixDef.friction = friction;
			fixDef.restitution = bounciness;
			
			body.CreateFixture(fixDef);
			
		}
	}
}