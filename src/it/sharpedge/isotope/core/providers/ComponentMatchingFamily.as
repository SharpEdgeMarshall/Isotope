package it.sharpedge.isotope.core.providers
{
	import flash.utils.Dictionary;
	import flash.utils.describeType;
	import flash.utils.getDefinitionByName;
	
	import it.sharpedge.isotope.core.Engine;
	import it.sharpedge.isotope.core.GameObject;
	import it.sharpedge.isotope.core.Node;
	import it.sharpedge.isotope.core.base.isotopeInternal;
	import it.sharpedge.isotope.core.lists.NodeList;
	import it.sharpedge.isotope.core.pool.NodePool;

	use namespace isotopeInternal;
	/**
	 * The default class for managing a NodeList. This class creates the NodeList and adds and removes
	 * nodes to/from the list as the entities and the components in the engine change.
	 * 
	 * It uses the basic entity matching pattern of an entity system - entities are added to the list if
	 * they contain components matching all the public properties of the node class.
	 */
	public class ComponentMatchingFamily implements IFamily
	{
		private var nodes : NodeList;
		private var entities : Dictionary;
		private var nodeClass : Class;
		private var components : Dictionary;
		private var nodePool : NodePool;
		private var _engine : Engine;
		
		/**
		 * The constructor. Creates a ComponentMatchingFamily to provide a NodeList for the
		 * given node class.
		 * 
		 * @param nodeClass The type of node to create and manage a NodeList for.
		 * @param engine The engine that this family is managing teh NodeList for.
		 */
		public function ComponentMatchingFamily( nodeClass : Class)
		{
			this.nodeClass = nodeClass;
			_engine = Engine.getInstance();
			init();
		}
		
		/**
		 * Initialises the class. Creates the nodelist and other tools. Analyses the node to determine
		 * what component types the node requires.
		 */
		private function init() : void
		{
			nodes = new NodeList();
			entities = new Dictionary();
			components = new Dictionary();
			nodePool = new NodePool( nodeClass, components );
			
			nodePool.disposeNode( nodePool.getNode() ); // create a dummy instance to ensure describeType works.
			
			var variables : XMLList = describeType( nodeClass ).factory.variable;
			for each ( var atom:XML in variables )
			{
				if ( atom.@name != "entity" && atom.@name != "previous" && atom.@name != "next" )
				{
					var componentClass : Class = getDefinitionByName( atom.@type ) as Class;
					components[componentClass] = atom.@name.toString();
				}
			}
		}
		
		/**
		 * The nodelist managed by this family. This is a reference that remains valid always
		 * since it is retained and reused by Systems that use the list. i.e. we never recreate the list,
		 * we always modify it in place.
		 */
		public function get nodeList() : NodeList
		{
			return nodes;
		}
		
		/**
		 * Called by the engine when an entity has been added to it. We check if the entity should be in
		 * this family's NodeList and add it if appropriate.
		 */
		public function newGameObject( gameObject: GameObject ) : void
		{
			addIfMatch( gameObject );
		}
		
		/**
		 * Called by the engine when a component has been added to an entity. We check if the entity is not in
		 * this family's NodeList and should be, and add it if appropriate.
		 */
		public function removeGameObject( gameObject: GameObject ) : void
		{
			addIfMatch( gameObject );
		}
		
		/**
		 * Called by the engine when a component has been removed from an entity. We check if the removed component
		 * is required by this family's NodeList and if so, we check if the entity is in this this NodeList and
		 * remove it if so.
		 */
		public function componentAddedToGameObject( gameObject: GameObject, componentClass : Class ) : void
		{
			if( components[componentClass] )
			{
				removeIfMatch( gameObject );
			}
		}
		
		/**
		 * Called by the engine when an entity has been rmoved from it. We check if the entity is in
		 * this family's NodeList and remove it if so.
		 */
		public function componentRemovedFromGameObject( gameObject: GameObject, componentClass : Class ) : void
		{
			removeIfMatch( gameObject );
		}
		
		/**
		 * If the entity is not in this family's NodeList, tests the components of the entity to see
		 * if it should be in this NodeList and adds it if so.
		 */
		private function addIfMatch( gameObject : GameObject ) : void
		{
			if( !entities[gameObject] )
			{
				var componentClass : *;
				for ( componentClass in components )
				{
					if ( !gameObject.GetComponent( componentClass ) )
					{
						return;
					}
				}
				var node : Node = nodePool.getNode();
				node.gameObject = gameObject;
				for ( componentClass in components )
				{
					node[components[componentClass]] = gameObject.GetComponent( componentClass );
				}
				entities[gameObject] = node;
				nodes.add( node );
			}
		}
		
		/**
		 * Removes the entity if it is in this family's NodeList.
		 */
		private function removeIfMatch( gameObject : GameObject ) : void
		{
			if( entities[gameObject] )
			{
				var node : Node = entities[gameObject];
				delete entities[gameObject];
				nodes.remove( node );
				if( _engine.updating )
				{
					nodePool.cache( node );
					_engine.updateComplete.add( releaseNodePoolCache );
				}
				else
				{
					nodePool.disposeNode( node );
				}
			}
		}
		
		/**
		 * Releases the nodes that were added to the node pool during this engine update, so they can
		 * be reused.
		 */
		private function releaseNodePoolCache() : void
		{
			_engine.updateComplete.remove( releaseNodePoolCache );
			nodePool.releaseCache();
		}
		
		/**
		 * Removes all nodes from the NodeList.
		 */
		public function dispose() : void
		{
			for( var node : Node = nodes.head; node; node = node.next )
			{
				delete entities[node.gameObject];
			}
			
			nodes.removeAll();
			nodePool.dispose();
			_engine = null;
		}
	}
}
