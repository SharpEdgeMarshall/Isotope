package it.sharpedge.isotope.core.base
{
	
	import org.osflash.signals.Signal;

	public class Behaviour extends Component
	{
		private var _stateChange : Signal;
		
		private var _enabled : Boolean = true;		
		
		public function Behaviour(name:String)
		{
			super(getComponentAccess(), name);
			
			_stateChange = new Signal(Behaviour, Boolean);
		}								  
		
		isotopeInternal function get stateChange():Signal
		{
			return _stateChange;
		}

		public function get enabled():Boolean
		{
			return _enabled;
		}

		public function set enabled(value:Boolean):void
		{
			if(_enabled == value) return;
			
			_enabled = value;
			
			_stateChange.dispatch(this, _enabled);
		}
		
		override isotopeInternal function dispose():void
		{
			_stateChange.removeAll();
		}

	}
}