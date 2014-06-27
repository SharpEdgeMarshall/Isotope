package it.sharpedge.isotope.core.providers
{
	import flash.utils.Dictionary;
	import flash.utils.getDefinitionByName;
	
	import it.sharpedge.isotope.core.Engine;
	import it.sharpedge.isotope.core.base.isotopeInternal;
	
	import org.swiftsuspenders.Injector;
	import org.swiftsuspenders.dependencyproviders.DependencyProvider;

	use namespace isotopeInternal;
	
	/**
	 * A custom dependency provider for SwiftSuspenders to allow injection
	 * of NodeList objects based on the node class they contain.
	 * 
	 * <p>This enables injections rules like</p>
	 * 
	 * <p>[Inject(nodeType="com.myDomain.project.nodes.MyNode")]
	 * public var nodes : NodeList;</p>
	 */
	public class NodeListProvider implements DependencyProvider
	{

		private static const DEFAULT_MATCHER : Class = ComponentMatchingFamily;
		
		public function NodeListProvider()
		{
		}

		public function apply( targetType : Class, activeInjector : Injector, injectParameters : Dictionary ) : Object
		{
			if ( injectParameters["nodeType"])
			{
				var nodeClass : Class = getDefinitionByName( injectParameters["nodeType"] ) as Class;
				
				if ( nodeClass )
				{
					return Engine.getInstance().getNodeList( nodeClass );
				}
			}
			return null;
		}

		public function destroy() : void
		{

		}
	}
}
