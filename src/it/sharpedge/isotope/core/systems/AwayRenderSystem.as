package it.sharpedge.isotope.core.systems
{
	import away3d.containers.View3D;
	
	import it.sharpedge.isotope.core.GameObject;
	import it.sharpedge.isotope.core.System;
	import it.sharpedge.isotope.core.base.isotopeInternal;
	import it.sharpedge.isotope.core.components.AwayCamera;
	import it.sharpedge.isotope.core.components.AwayDisplay;
	import it.sharpedge.isotope.core.lists.NodeList;
	import it.sharpedge.isotope.core.nodes.AwayCameraNode;
	import it.sharpedge.isotope.core.nodes.AwayRenderNode;
	
	use namespace isotopeInternal;
	
	public class AwayRenderSystem extends System
	{
		[Inject]
		public var view : View3D;
		
		[Inject(nodeType="it.sharpedge.isotope.core.nodes.AwayRenderNode"]
		public var meshNodes : NodeList;
		
		[Inject(nodeType="it.sharpedge.isotope.core.nodes.AwayCameraNode"]
		public var camNodes : NodeList;
		
		
		private var tMeshNode : AwayRenderNode;
		private var tCamNode : AwayCameraNode;
		
		[PostConstruct]
		public function setUpListeners() : void
		{
			createMainCamera();
	
			
			for( tMeshNode = meshNodes.head; tMeshNode; tMeshNode = tMeshNode.next )
			{
				onRenderableAdded( tMeshNode );
			}
			
			meshNodes.nodeAdded.add( onRenderableAdded );
			meshNodes.nodeRemoved.add( onRenderableRemoved );			
			
		}
				
		private function createMainCamera() : void
		{
			var camObj : GameObject = new GameObject("MainCamera");
			var camComp : AwayCamera = camObj.AddComponent(AwayCamera) as AwayCamera;
			camComp.camera = view.camera;
				
			AwayCamera.mainCamera =  camComp;
		}
		
		private function onRenderableAdded(node : AwayRenderNode) : void
		{	
			addToDisplay(node.awayDisplay);
			
			node.awayDisplay.containerAdded.add(addToDisplay);
			node.awayDisplay.containerRemoved.add(removeFromDisplay);					
		}
		
		
		private function onRenderableRemoved(node : AwayRenderNode) : void
		{
			removeFromDisplay(node.awayDisplay);
			
			node.awayDisplay.containerAdded.remove(addToDisplay);
			node.awayDisplay.containerRemoved.remove(removeFromDisplay);
		}	
		
		
		private function addToDisplay(display:AwayDisplay) : void
		{
			//If Container exist add to scene
			if(display.objContainer)	
				view.scene.addChild(display.objContainer);
		}
		
		private function removeFromDisplay(display:AwayDisplay) : void
		{
			//If Container exist remove from scene
			if(display.objContainer)	
				view.scene.removeChild(display.objContainer);
		}
			
		
		override public function Update(time : int) : void
		{
			
			for ( tCamNode = camNodes.head; tCamNode; tCamNode = tCamNode.next )
			{
				tCamNode.awayCamera.camera.transform = tCamNode.transform.localToWorldMatrix;
			}
			
			for ( tMeshNode = meshNodes.head; tMeshNode; tMeshNode = tMeshNode.next )
			{					
				tMeshNode.awayDisplay.objContainer.transform = tMeshNode.transform.localToWorldMatrix;
			}
			
			view.render();
		}
		 
	}
}