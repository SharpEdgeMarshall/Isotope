package it.sharpedge.isotope.core.components
{
	import it.sharpedge.isotope.core.base.isotopeInternal;
	import it.sharpedge.isotope.core.Component;
	
	use namespace isotopeInternal;
	
	public class Transform extends Component
	{		
		private var _parent : Transform;
		
		isotopeInternal var _children : Vector.<Transform>;
		
		public function get children() : Vector.<Transform>
		{
			return _children;
		}
		
		public function get childCount() : int
		{
			return _children.length;
		}
		
		public function get parent() : Transform
		{
			return _parent;
		}
		
		public function set parent(transform : Transform) : void
		{
			if(_parent == transform) return;
			
			if(_parent)
			{
				_parent.removeChildren(transform);
			}
			
			_parent = transform;
			
			if(_parent)
			{
				_parent.addChildren(transform);
				//Update the activeHierarchy when changing parent
				//Not best implementation
				this.gameObject.SetActiveInHierarchy(_parent.gameObject._activeInHierarchy && _parent.gameObject.activeSelf);
			}
			else
			{
				//If root parent set activeInHierarchy TRUE
				this.gameObject.SetActiveInHierarchy(true);
			}
			
		}
		
		public function get root():Transform
		{
			var parentTrsf : Transform = this;
			
			while(parentTrsf.parent != null)
			{
				parentTrsf = parentTrsf.parent;
			}
			
			return parentTrsf;
		}
		
		public function Transform()
		{
			super(getComponentAccess(), "Transform");
			
			_children = new Vector.<Transform>();
		}
		
		public function DetachChildren() : void
		{
			for each(var child : Transform in _children)
			{
				child.parent = null;
			}
		}
		
		public function IsChildOf(transform:Transform) : Boolean
		{
			var parentTrsf : Transform = this;
			
			while(parentTrsf != null)
			{
				if(parentTrsf == transform)
					return true;
				
				parentTrsf = parentTrsf.parent;
			}
			
			return false;
		}
		
		public function Find(name:String) : Transform
		{
			var childMatch : Transform;
			for each(var child : Transform in _children)
			{
				if(child.gameObject.name == name)
					return child;
				
				childMatch = child.Find(name);
				
				if(childMatch)
					return childMatch;
			}
			
			return null;
		}
		
		public function GetChild(index:int):Transform
		{
			return _children[index];
		}
		
		isotopeInternal function addChildren(transform:Transform):void
		{
			_children.push(transform);
		}
		
		isotopeInternal function removeChildren(transform:Transform):void
		{
			_children.splice(_children.indexOf(transform), 1);
		}
		
		override isotopeInternal function clone():Component
		{
			var trsfComp : Transform = new Transform();

			return trsfComp;
		}
		
		override isotopeInternal function dispose() : void
		{
			parent = null;
			_children = null;
			super.dispose();
		}
	}
}