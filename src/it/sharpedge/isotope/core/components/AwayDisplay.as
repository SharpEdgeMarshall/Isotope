package it.sharpedge.isotope.core.components
{
	import away3d.containers.ObjectContainer3D;
	
	import it.sharpedge.isotope.core.Component;
	import it.sharpedge.isotope.core.base.isotopeInternal;
	
	import org.osflash.signals.Signal;
	
	public class AwayDisplay extends Component
	{
		private var _containerAdded : Signal;
		private var _containerRemoved : Signal;
		
		private var _objContainer : ObjectContainer3D;		
		
		public function AwayDisplay()
		{
			super(getComponentAccess(), "AwayDisplay");
			_containerAdded = new Signal(AwayDisplay);
			_containerRemoved = new Signal(AwayDisplay);
		}

		public function get containerRemoved():Signal
		{
			return _containerRemoved;
		}

		public function get containerAdded():Signal
		{
			return _containerAdded;
		}

		public function get objContainer():ObjectContainer3D
		{
			return _objContainer;
		}

		public function set objContainer(value:ObjectContainer3D):void
		{
			if(_objContainer == value) return;
			
			if(_objContainer != null)
				_containerRemoved.dispatch(this);
				
			_objContainer = value;
			
			if(_objContainer != null)
				_containerAdded.dispatch(this);
		}
		
		override isotopeInternal function dispose():void
		{
			_containerAdded.removeAll();
			_containerRemoved.removeAll();
			
			_objContainer = null;
		}
		
		override isotopeInternal function clone():Component
		{
			var dispComp : AwayDisplay = new AwayDisplay();
			dispComp.objContainer = this._objContainer.clone() as ObjectContainer3D;
			
			return dispComp;
		}

	}
}