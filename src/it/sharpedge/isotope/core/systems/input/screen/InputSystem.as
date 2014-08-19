package it.sharpedge.isotope.core.systems.input.screen
{
	import flash.display.Sprite;
	
	import it.sharpedge.isotope.core.System;
	import it.sharpedge.isotope.core.base.isotopeInternal;
	
	use namespace isotopeInternal;
	
	public class InputSystem extends System
	{
		
		[Inject(name="MainView")]
		public var view : Sprite;
		
		[PostConstruct]
		public function init() : void
		{	
			Input.SetUp(view);
		}
		
		override public function removeFromEngine():void
		{
			Input.dispose();
		}
		
		override public function Update(time:int):void
		{
			Input.update(time);
		}
	}
}