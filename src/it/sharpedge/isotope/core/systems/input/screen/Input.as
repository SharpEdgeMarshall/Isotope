package it.sharpedge.isotope.core.systems.input.screen
{
	import flash.display.Sprite;
	import flash.events.TouchEvent;
	import flash.utils.Dictionary;
	import flash.utils.getTimer;
	
	import it.sharpedge.isotope.core.base.isotopeInternal;
	import it.sharpedge.isotope.core.utils.enums.TouchPhase;

	use namespace isotopeInternal;
	
	public class Input
	{
		private static var _view : Sprite;
		private static var _cachedTime : int;
		
		private static var _touchEnabled : Boolean = false;
		private static var _mouseEnabled : Boolean = true;
		private static var _accelerometerEnabled : Boolean = false;
		
		
		private static var _touchCount : int = 0;
		private static var _touches : Dictionary = new Dictionary();
		private static var _endedTouches : Vector.<int> = new Vector.<int>();
		private static var _beginnedTouches : Vector.<int> = new Vector.<int>();
		private static var _movedTouches : Vector.<int> = new Vector.<int>();
		
		
		//DEBUG
		public static function get view():Sprite
		{
			return _view;
		}
		
		public static function get accelerometerEnabled():Boolean
		{
			return _accelerometerEnabled;
		}

		public static function set accelerometerEnabled(value:Boolean):void
		{
			if(value == _accelerometerEnabled) return;
			
			_accelerometerEnabled = value;
			//TODO
		}

		public static function get mouseEnabled():Boolean
		{
			return _mouseEnabled;
		}

		public static function set mouseEnabled(value:Boolean):void
		{
			if(value == _mouseEnabled) return;
			
			_mouseEnabled = value;
			//TODO
		}

		public static function get touchEnabled():Boolean
		{
			return _touchEnabled;
		}

		public static function set touchEnabled(value:Boolean):void
		{
			if(value == _touchEnabled) return;
			
			_touchEnabled = value;
			
			if(value)
				addTouchListeners();
			else
				removeTouchListeners();
		}

		public static function get touchCount() : int
		{
			return _touchCount;
		}
		
		public static function get touches() :  Vector.<Touch>
		{
			var vec : Vector.<Touch> = new Vector.<Touch>();
			for each(var touch : Touch in _touches)
			{
				vec.push(touch);
			}
			
			return vec;
		}
		
		public static function GetTouch(id:int):Touch
		{
			return _touches[id];
		}
		
		
		isotopeInternal static function SetUp(view : Sprite) : void
		{
			if(_view)
				dispose();
			
			_view = view;
			addListeners();			
		}
		
		private static function addListeners():void
		{
			if(_touchEnabled)
				addTouchListeners();
		}
		
		private static function addTouchListeners():void
		{
			_view.addEventListener(TouchEvent.TOUCH_BEGIN, onTouchBegin);
			_view.addEventListener(TouchEvent.TOUCH_END, onTouchEnd);
			_view.addEventListener(TouchEvent.TOUCH_MOVE, onTouchMove);
		}
		
		protected static function onTouchMove(event:TouchEvent):void
		{
			var touch : Touch = _touches[event.touchPointID];
			touch._phase = TouchPhase.MOVED;
			
			updateTouch(touch, event);
		}
		
		protected static function onTouchEnd(event:TouchEvent):void
		{
			var touch : Touch = _touches[event.touchPointID];
			touch._phase = TouchPhase.ENDED;
			
			updateTouch(touch, event);
			
			_touchCount--;
		}
		
		protected static function onTouchBegin(event:TouchEvent):void
		{
			var touch : Touch = new Touch();
			touch._fingerId = event.touchPointID;
			touch._phase = TouchPhase.BEGAN;
			touch._oldTime = getTimer();
			
			updateTouch(touch, event);
			
			_touches[event.touchPointID] = touch;
			_touchCount++;
		}
		
		private static function updateTouch(touch:Touch, event:TouchEvent):void
		{		
			_cachedTime = getTimer();
			
			touch._deltaPosition.copyFrom(touch._position);
			touch._position.setTo(event.stageX, event.stageY);
			
			//Update Delta
			touch._deltaPosition = touch._deltaPosition.subtract(touch.position);			
			touch._deltaTime = _cachedTime - touch._oldTime;
			touch._oldTime = _cachedTime;
		}
		
		private static function removeListeners():void
		{
			if(_touchEnabled)
				removeTouchListeners();
		}
		
		private static function removeTouchListeners():void
		{
			_view.removeEventListener(TouchEvent.TOUCH_BEGIN, onTouchBegin);
			_view.removeEventListener(TouchEvent.TOUCH_END, onTouchEnd);
			_view.removeEventListener(TouchEvent.TOUCH_MOVE, onTouchMove);
			
			//Send all Touches to ENDED Phase
			for each(var touch : Touch in _touches)
			{
				touch._phase = TouchPhase.ENDED;
				_endedTouches.push(touch.fingerId);
			}
		}
		
		isotopeInternal static function update(time:int):void
		{
			
			while(_beginnedTouches.length > 0)
			{
				_touches[_beginnedTouches.pop()]._phase = TouchPhase.STATIONARY;
			}
			
			while(_movedTouches.length > 0)
			{
				var touch : Touch = _touches[_movedTouches.pop()];
				
				if(time - touch._oldTime > 200)
					touch._phase = TouchPhase.STATIONARY;
			}
			
			while(_endedTouches.length > 0)
			{
				_touches[_endedTouches.pop()] = null;
			}
		}
		
		isotopeInternal static function dispose():void
		{
			removeListeners();			
			_view = null;
			
			_touches = new Dictionary();
			_endedTouches = new Vector.<int>();
			
		}
		
	}
}