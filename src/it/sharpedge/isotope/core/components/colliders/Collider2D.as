package it.sharpedge.isotope.core.components.colliders
{
	import it.sharpedge.isotope.core.Behaviour;
	import it.sharpedge.isotope.core.Component;
	import it.sharpedge.isotope.core.base.isotopeInternal;
	
	import org.osflash.signals.Signal;
	
	public class Collider2D extends Behaviour
	{	
		
		protected var _changed : Signal;

		isotopeInternal function get changed():Signal
		{
			return _changed;
		}

		
		private var _bounciness : Number = 0.0;
		private var _friction : Number = 0.2;
		private var _density : Number = 10.0;
		
		public function get density():Number
		{
			return _density;
		}
		
		public function set density(value:Number):void
		{
			if(_density == value) return;
			
			_density = value;
			_changed.dispatch(this);
		}
		
		public function get friction():Number
		{
			return _friction;
		}
		
		public function set friction(value:Number):void
		{
			if(_friction == value) return;
			
			_friction = value;
			_changed.dispatch(this);
		}
		
		public function get bounciness():Number
		{
			return _bounciness;
		}
		
		public function set bounciness(value:Number):void
		{
			if(_bounciness == value) return;
			
			_bounciness = value;
			_changed.dispatch(this);
		}
		
		public function Collider2D(name:String)
		{
			super(name);	
			_changed = new Signal(Collider2D);
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