package it.sharpedge.isotope.core.systems
{
	import it.sharpedge.isotope.core.System;
	import it.sharpedge.isotope.core.base.isotopeInternal;
	import it.sharpedge.isotope.core.components.ScriptBehaviour;
	import it.sharpedge.isotope.core.lists.NodeList;
	import it.sharpedge.isotope.core.nodes.ScriptBehaviourNode;
	
	use namespace isotopeInternal;
	
	public class ScriptBehaviourSystem extends System
	{
		[Inject(nodeType="it.sharpedge.isotope.core.nodes.ScriptBehaviourNode"]
		public var nodes : NodeList;
		
		private var toInitVec : Vector.<ScriptBehaviour> = new Vector.<ScriptBehaviour>();
		
		private var toStartVec : Vector.<ScriptBehaviour> = new Vector.<ScriptBehaviour>();
		
		private var updateVec : Vector.<ScriptBehaviour> = new Vector.<ScriptBehaviour>();
		
		private var tScript : ScriptBehaviour;
		
		[PostConstruct]
		public function setUpListeners() : void
		{
			for( var node : ScriptBehaviourNode = nodes.head; node; node = node.next )
			{
				onScriptContAdded( node );
			}
			nodes.nodeAdded.add( onScriptContAdded );
			nodes.nodeRemoved.add( onScriptContRemoved );
		}
		
		//When a "new ScriptBehaviourNode = new ScriptContainer = new GameObject" is added
		private function onScriptContAdded(node : ScriptBehaviourNode) : void
		{
			for each(var script : ScriptBehaviour in node.scriptsContainer.scripts)
			{
				onScriptAdded(script);
			}
			
			node.scriptsContainer.scriptAdded.add(onScriptAdded);
			node.scriptsContainer.scriptRemoved.add(onScriptRemoved);
			
		}
		
		//When a "ScriptBehaviourNode = ScriptContainer = GameObject" is removed
		private function onScriptContRemoved(node : ScriptBehaviourNode) : void
		{
			node.scriptsContainer.scriptAdded.remove(onScriptAdded);
			node.scriptsContainer.scriptRemoved.remove(onScriptRemoved);
		}
		
		//New ScriptBehaviour
		private function onScriptAdded(script:ScriptBehaviour):void
		{
			script.stateChange.add(onScriptStateChanged);
			toInitVec.push(script);
		}
		
		//ScriptBehaviour Removed
		private function onScriptRemoved(script:ScriptBehaviour):void
		{
			script.stateChange.remove(onScriptStateChanged);
			
			//If the Script had started call onDestroy
			if(script.started)
				script.OnDestroy();
		}
		
		//ScriptBehaviour State Changed
		private function onScriptStateChanged(script:ScriptBehaviour, enabled:Boolean):void
		{
			//Script enabled
			if(enabled)
			{
				//Never Started Before
				if(!script.started)
				{
					toStartVec.push(script);
				}
				else
				{
					updateVec.push(script);
				}
				
				script.OnEnable();
					
			}
			else //Script Disabled
			{
				if(!script.started)
				{
					toStartVec.splice(toStartVec.indexOf(script), 1);
				}
				else
				{
					updateVec.splice(updateVec.indexOf(script), 1);
				}
				
				script.OnDisable();
			}
		}
			
		
		override public function Update(time : int) : void
		{
			awakeNewScripts();
			
			startNewScripts();
			
			updateScripts();			
			
			lateUpdateScripts();
		}
		
		
		private function awakeNewScripts():void
		{
			while(toInitVec.length != 0)
			{				
				tScript = toInitVec.pop();
				
				//If enabled put on the list of ScrtipBehaviours to Start()
				if(tScript.enabled)
					toStartVec.push(tScript);
				
				tScript.Awake();
				
				//Check if Awake() changed the state of the ScriptBehaviour
				if(tScript.enabled)
					tScript.OnEnable();
			}
		}
		
		private function startNewScripts():void
		{
			while(toStartVec.length != 0)
			{
				tScript = toStartVec.pop();

				tScript.started = true;
				updateVec.push(tScript);
				
				tScript.Start();				
			}
		}
		
		private function updateScripts():void
		{
			for each(tScript in updateVec)
			{
				tScript.Update();
			}
		}
		
		private function lateUpdateScripts():void
		{
			for each(tScript in updateVec)
			{
				tScript.LateUpdate();
			}
		}
		
		 
	}
}