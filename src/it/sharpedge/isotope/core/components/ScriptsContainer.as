package it.sharpedge.isotope.core.components
{
	import it.sharpedge.isotope.core.Component;
	import it.sharpedge.isotope.core.base.isotopeInternal;
	
	import org.osflash.signals.Signal;
	
	use namespace isotopeInternal;
	
	public class ScriptsContainer extends Component
	{
		private var _scriptAdded : Signal;
		private var _scriptRemoved : Signal;
		
		private var _scripts : Vector.<ScriptBehaviour>;
		
		isotopeInternal function get scriptRemoved():Signal
		{
			return _scriptRemoved;
		}

		isotopeInternal function get scriptAdded():Signal
		{
			return _scriptAdded;
		}

		public function get scripts() : Vector.<ScriptBehaviour>
		{
			return _scripts;
		}
		
		public function ScriptsContainer()
		{
			super(getComponentAccess(), "ScriptsContainer");
			
			_scriptAdded = new Signal(ScriptBehaviour);
			_scriptRemoved = new Signal(ScriptBehaviour);
			
			_scripts = new Vector.<ScriptBehaviour>();
		}
		
		public function addScript(script:ScriptBehaviour) : void
		{
			_scripts.push(script);
			
			_scriptAdded.dispatch(script);
		}
		
		public function removeScript(script:ScriptBehaviour) : void
		{
			var index : int = _scripts.indexOf(script);
			
			if(index != -1)
			{
				_scripts.splice(index, 1);
				
				_scriptRemoved.dispatch(script);
			}
		}
		
		public function getScript(scriptType:Class):ScriptBehaviour
		{
			for each(var script : ScriptBehaviour in _scripts)
			{
				if(script is scriptType)
					return script;
			}
			return null;
		}
		
		public function getScripts(scriptType:Class):Vector.<ScriptBehaviour>
		{
			var matchScript : Vector.<ScriptBehaviour> = new Vector.<ScriptBehaviour>();
			
			for each(var script : ScriptBehaviour in _scripts)
			{
				if(script is scriptType)
					matchScript.push(script);
			}
			
			return matchScript;
		}
		
		override isotopeInternal function clone():Component
		{
			var scriptsCont : ScriptsContainer = new ScriptsContainer();
			
			return scriptsCont;
		}
		
		override isotopeInternal function dispose() : void
		{
			_scripts = new Vector.<ScriptBehaviour>();
			
			_scriptAdded.removeAll();
			_scriptRemoved.removeAll();
			
			super.dispose();
		}
	}
}