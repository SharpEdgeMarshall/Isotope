package it.sharpedge.isotope.core.components.physics2d.box2d.colliders
{
	import Box2D.Collision.Shapes.b2Shape;
	import Box2D.Dynamics.b2Fixture;
	import Box2D.Dynamics.b2FixtureDef;
	
	import it.sharpedge.isotope.core.Behaviour;
	import it.sharpedge.isotope.core.Component;
	import it.sharpedge.isotope.core.base.isotopeInternal;
	
	use namespace isotopeInternal;
	
	//TODO need to update pos if transform change
	public class Collider2D extends Behaviour
	{	
		
		private var _fixture : b2Fixture;

		isotopeInternal function get fixture():b2Fixture
		{
			return _fixture;
		}

		isotopeInternal function set fixture(value:b2Fixture):void
		{
			_fixture = value;
		}
		
		isotopeInternal function get shape() : b2Shape
		{
			return null;
		}
		
		private var _bounciness : Number = 0.0;
		private var _friction : Number = 0.2;
		private var _density : Number = 1.0;
		
		public function get density():Number
		{
			return _density;
		}
		
		public function set density(value:Number):void
		{
			if(_density == value) return;
			
			_density = value;
			
			if(_fixture)
			{
				_fixture.SetDensity(_density);
				_fixture.GetBody().ResetMassData();
			}
		}
		
		public function get friction():Number
		{
			return _friction;
		}
		
		public function set friction(value:Number):void
		{
			if(_friction == value) return;
			
			_friction = value;
			
			if(_fixture)
				_fixture.SetFriction(_friction);
		}
		
		public function get bounciness():Number
		{
			return _bounciness;
		}
		
		public function set bounciness(value:Number):void
		{
			if(_bounciness == value) return;
			
			_bounciness = value;
			
			if(_fixture)
				_fixture.SetRestitution(_bounciness);
		}
		
		public function Collider2D(name:String)
		{
			super(name);
		}
		
		isotopeInternal function GetFixtureDef() : b2FixtureDef
		{
			var fixDef : b2FixtureDef = new b2FixtureDef();
			fixDef.friction = _friction;
			fixDef.density = _density;
			fixDef.restitution = _bounciness;
			fixDef.shape = shape;
			fixDef.userData = this;
			
			return fixDef;
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