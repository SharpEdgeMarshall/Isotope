package it.sharpedge.isotope.core.components
{
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	
	import away3d.core.math.MathConsts;
	
	import it.sharpedge.isotope.core.Component;
	import it.sharpedge.isotope.core.base.isotopeInternal;
	import it.sharpedge.isotope.core.math.Matrix3DUtils;
	import it.sharpedge.isotope.core.utils.Space;
	
	use namespace isotopeInternal;
	
	public class Transform extends Component
	{	
		
		//Hierarchy Properties
		private var _parent : Transform;
		
		isotopeInternal var _children : Vector.<Transform> = new Vector.<Transform>();
		

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
			
			notifySceneTransformChange();
			
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
		
		
		//Transform Properties		
		
		//Local
		private var _rotationX:Number = 0;
		private var _rotationY:Number = 0;
		private var _rotationZ:Number = 0;
		private var _scaleX:Number = 1;
		private var _scaleY:Number = 1;
		private var _scaleZ:Number = 1;
		private var _x:Number = 0;
		private var _y:Number = 0;
		private var _z:Number = 0;
		
		private var _pivotPoint:Vector3D = new Vector3D();
		private var _pivotZero:Boolean = true;
		
		private var _pos:Vector3D = new Vector3D();
		private var _rot:Vector3D = new Vector3D();
		private var _sca:Vector3D = new Vector3D();
		private var _transformComponents:Vector.<Vector3D>;		
		
		private var _positionDirty : Boolean = false;
		private var _rotationDirty : Boolean = false;
		private var _scaleDirty : Boolean = false;
		
		private var _transform:Matrix3D = new Matrix3D();
		private var _transformDirty : Boolean = false;
		
		//World
		private var _worldPos:Vector3D = new Vector3D();
		private var _worldRot:Vector3D = new Vector3D();
		private var _worldSca:Vector3D = new Vector3D();
	
		private var _worldPositionDirty : Boolean = false;
		private var _worldRotationDirty : Boolean = false;
		private var _worldScaleDirty : Boolean = false;		
		
		//Hierarchy Transform Properties
		private var _sceneTransform:Matrix3D = new Matrix3D();
		private var _sceneTransformDirty:Boolean = true;
		
		private var _inverseSceneTransform:Matrix3D = new Matrix3D();
		private var _inverseSceneTransformDirty:Boolean = true;		
		
		
		//POSITION
		
		/**
		 * Defines the position of the 3d object, relative to the local coordinates of the parent <code>ObjectContainer3D</code>.
		 */
		public function get localPosition():Vector3D
		{
			transformMatrix.copyColumnTo(3, _pos);
			
			return _pos.clone();
		}
		
		public function set localPosition(value:Vector3D):void
		{
			_x = value.x;
			_y = value.y;
			_z = value.z;
			
			invalidatePosition();
		}
		
		/**
		 * Defines the x coordinate of the 3d object relative to the local coordinates of the parent <code>ObjectContainer3D</code>.
		 */
		public function get localPositionX():Number
		{
			return _x;
		}
		
		public function set localPositionX(val:Number):void
		{
			if (_x == val)
				return;
			
			_x = val;
			
			invalidatePosition();
		}
		
		/**
		 * Defines the y coordinate of the 3d object relative to the local coordinates of the parent <code>ObjectContainer3D</code>.
		 */
		public function get localPositionY():Number
		{
			return _y;
		}
		
		public function set localPositionY(val:Number):void
		{
			if (_y == val)
				return;
			
			_y = val;
			
			invalidatePosition();
		}
		
		/**
		 * Defines the z coordinate of the 3d object relative to the local coordinates of the parent <code>ObjectContainer3D</code>.
		 */
		public function get localPositionZ():Number
		{
			return _z;
		}
		
		public function set localPositionZ(val:Number):void
		{
			if (_z == val)
				return;
			
			_z = val;
			
			invalidatePosition();
		}
		
		/**
		 * Defines the position of the 3d object, relative to the world origin.
		 */
		public function get position():Vector3D
		{
			if (_worldPositionDirty) {
				localToWorldMatrix.copyColumnTo(3, _worldPos);
				_worldPositionDirty = false;
			}
			
			return _worldPos;
		}
		
		public function set position(value:Vector3D):void
		{
			if(!_parent)
				this.localPosition = value;
		}
		
		//ROTATION
		
		public function get localRotation():Vector3D
		{
			return new Vector3D(_rotationX*MathConsts.RADIANS_TO_DEGREES, _rotationY*MathConsts.RADIANS_TO_DEGREES, _rotationZ*MathConsts.RADIANS_TO_DEGREES);
		}
		
		public function set localRotation(value:Vector3D):void
		{
			_rotationX = value.x*MathConsts.DEGREES_TO_RADIANS;
			_rotationY = value.y*MathConsts.DEGREES_TO_RADIANS;
			_rotationZ = value.z*MathConsts.DEGREES_TO_RADIANS;
			
			invalidateRotation();
		}
		
		/**
		 * Defines the euler angle of rotation of the 3d object around the x-axis, relative to the local coordinates of the parent <code>ObjectContainer3D</code>.
		 */
		public function get localRotationX():Number
		{
			return _rotationX*MathConsts.RADIANS_TO_DEGREES;
		}
		
		public function set localRotationX(val:Number):void
		{
			if (localRotationX == val)
				return;
			
			_rotationX = val*MathConsts.DEGREES_TO_RADIANS;
			
			invalidateRotation();
		}
		
		/**
		 * Defines the euler angle of rotation of the 3d object around the y-axis, relative to the local coordinates of the parent <code>ObjectContainer3D</code>.
		 */
		public function get localRotationY():Number
		{
			return _rotationY*MathConsts.RADIANS_TO_DEGREES;
		}
		
		public function set localRotationY(val:Number):void
		{
			if (localRotationY == val)
				return;
			
			_rotationY = val*MathConsts.DEGREES_TO_RADIANS;
			
			invalidateRotation();
		}
		
		/**
		 * Defines the euler angle of rotation of the 3d object around the z-axis, relative to the local coordinates of the parent <code>ObjectContainer3D</code>.
		 */
		public function get localRotationZ():Number
		{
			return _rotationZ*MathConsts.RADIANS_TO_DEGREES;
		}
		
		public function set localRotationZ(val:Number):void
		{
			if (localRotationZ == val)
				return;
			
			_rotationZ = val*MathConsts.DEGREES_TO_RADIANS;
			
			invalidateRotation();
		}
		
		public function get rotation():Vector3D
		{
			if(_worldRotationDirty)
			{
				_worldRot.copyFrom(localToWorldMatrix.decompose()[1]);
				_worldRotationDirty = false;
			}
			
			return _worldRot;
		}
		
		public function set rotation(value:Vector3D):void
		{
			if(!parent)
				this.localRotation = value;
			
		}
		
		//SCALE		
		
		/**
		 * Defines the scale of the 3d object along the x-axis, relative to local coordinates.
		 */
		public function get localScaleX():Number
		{
			return _scaleX;
		}
		
		public function set localScaleX(val:Number):void
		{
			if (_scaleX == val)
				return;
			
			_scaleX = val;
			
			invalidateScale();
		}
		
		/**
		 * Defines the scale of the 3d object along the y-axis, relative to local coordinates.
		 */
		public function get localScaleY():Number
		{
			return _scaleY;
		}
		
		public function set localScaleY(val:Number):void
		{
			if (_scaleY == val)
				return;
			
			_scaleY = val;
			
			invalidateScale();
		}
		
		public function get scale():Vector3D
		{
			if(_worldScaleDirty)
			{
				_worldSca.copyFrom(localToWorldMatrix.decompose()[2]);
				_worldScaleDirty = false;
			}
			
			return _worldSca;
		}
		
		public function set scale(value:Vector3D):void
		{
			
			//TODO set world scale
			
		}
		
		/**
		 * Defines the scale of the 3d object along the z-axis, relative to local coordinates.
		 */
		public function get localScaleZ():Number
		{
			return _scaleZ;
		}
		
		public function set localScaleZ(val:Number):void
		{
			if (_scaleZ == val)
				return;
			
			_scaleZ = val;
			
			invalidateScale();
		}
		
		
		
		/**
		 * The transformation of the 3d object, relative to the local coordinates of the parent <code>ObjectContainer3D</code>.
		 */
		public function get transformMatrix():Matrix3D
		{
			if (_transformDirty)
				updateTransform();
			
			return _transform;
		}
		
		public function set transformMatrix(val:Matrix3D):void
		{
			var raw:Vector.<Number> = Matrix3DUtils.RAW_DATA_CONTAINER;
			val.copyRawDataTo(raw);
			if (!raw[uint(0)]) {
				raw[uint(0)] = Number.MIN_VALUE;
				val.copyRawDataFrom(raw);
			}
			
			var elements:Vector.<Vector3D> = Matrix3DUtils.decompose(val);
			var vec:Vector3D;
			
			vec = elements[0];
			
			if (_x != vec.x || _y != vec.y || _z != vec.z) {
				_x = vec.x;
				_y = vec.y;
				_z = vec.z;
				
				invalidatePosition();
			}
			
			vec = elements[1];
			
			if (_rotationX != vec.x || _rotationY != vec.y || _rotationZ != vec.z) {
				_rotationX = vec.x;
				_rotationY = vec.y;
				_rotationZ = vec.z;
				
				invalidateRotation();
			}
			
			vec = elements[2];
			
			if (_scaleX != vec.x || _scaleY != vec.y || _scaleZ != vec.z) {
				_scaleX = vec.x;
				_scaleY = vec.y;
				_scaleZ = vec.z;
				
				invalidateScale();
			}
		}
		
		public function get localToWorldMatrix() : Matrix3D
		{
			if (_sceneTransformDirty)
				updateSceneTransform();
			
			return _sceneTransform;
		}
		
		public function get worldToLocalMatrix() : Matrix3D
		{
			if (_inverseSceneTransformDirty) {
				_inverseSceneTransform.copyFrom(localToWorldMatrix);
				_inverseSceneTransform.invert();
				_inverseSceneTransformDirty = false;
			}
			
			return _inverseSceneTransform;
		}
		
		/**
		 * Defines the local point around which the object rotates.
		 */
		public function get pivotPoint():Vector3D
		{
			return _pivotPoint;
		}
		
		public function set pivotPoint(pivot:Vector3D):void
		{
			if(!_pivotPoint) _pivotPoint = new Vector3D();
			_pivotPoint.x = pivot.x;
			_pivotPoint.y = pivot.y;
			_pivotPoint.z = pivot.z;
			
			invalidatePivot();
		}
		
		
		/**
		 * Defines the position of the 3d object, relative to the local coordinates of the parent <code>ObjectContainer3D</code>.
		 * @param v the destination Vector3D
		 * @return
		 */
		public function getLocalPosition(v:Vector3D = null):Vector3D {
			if(!v) v = new Vector3D();
			transformMatrix.copyColumnTo(3, v);
			return v;
		}
		
		
		
		/**
		 *
		 */
		public function get forwardVector():Vector3D
		{
			return Matrix3DUtils.getForward(transformMatrix);
		}
		
		/**
		 *
		 */
		public function get rightVector():Vector3D
		{
			return Matrix3DUtils.getRight(transformMatrix);
		}
		
		/**
		 *
		 */
		public function get upVector():Vector3D
		{
			return Matrix3DUtils.getUp(transformMatrix);
		}
		
		/**
		 *
		 */
		public function get backVector():Vector3D
		{
			var director:Vector3D = Matrix3DUtils.getForward(transformMatrix);
			director.negate();
			
			return director;
		}
		
		/**
		 *
		 */
		public function get leftVector():Vector3D
		{
			var director:Vector3D = Matrix3DUtils.getRight(transformMatrix);
			director.negate();
			
			return director;
		}
		
		/**
		 *
		 */
		public function get downVector():Vector3D
		{
			var director:Vector3D = Matrix3DUtils.getUp(transformMatrix);
			director.negate();
			
			return director;
		}
		
		public function Transform()
		{
			super(getComponentAccess(), "Transform");
			
			// Cached vector of transformation components used when
			// recomposing the transform matrix in updateTransform()
			_transformComponents = new Vector.<Vector3D>(3, true);
			_transformComponents[0] = _pos;
			_transformComponents[1] = _rot;
			_transformComponents[2] = _sca;
			
			_transform.identity();
			
		}
		
		
		//Hierarchy Methods
		
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
		
		
		
		//Transform Methods
		
		/**
		 * Moves the 3d object along a vector by a defined length
		 *
		 * @param    axis        The vector defining the axis of movement
		 * @param    distance    The length of the movement
		 * @param	 space		 Translate in Self or World Space (if left null will be SELF)
		 */
		public function Translate(translation:Vector3D, space:Space = null):void
		{
			if(!space || space == Space.SELF)
			{					
				_x += translation.x;
				_y += translation.y;
				_z += translation.z;
			}
			else
			{
				//TODO world translate
				//Wrong: this is translate before rotate
				/*transformMatrix.prependTranslation(translation.x, translation.y, translation.z);
				
				_transform.copyColumnTo(3, _pos);
				
				_x = _pos.x;
				_y = _pos.y;
				_z = _pos.z;*/
			}
			
			invalidatePosition();
		}
		
		/**
		 * Rotates the 3d object around it's local x-axis
		 *
		 * @param    angle        The amount of rotation in degrees
		 */
		public function Pitch(angle:Number):void
		{
			Rotate(Vector3D.X_AXIS, angle);
		}
		
		/**
		 * Rotates the 3d object around it's local y-axis
		 *
		 * @param    angle        The amount of rotation in degrees
		 */
		public function Yaw(angle:Number):void
		{
			Rotate(Vector3D.Y_AXIS, angle);
		}
		
		/**
		 * Rotates the 3d object around it's local z-axis
		 *
		 * @param    angle        The amount of rotation in degrees
		 */
		public function Roll(angle:Number):void
		{
			Rotate(Vector3D.Z_AXIS, angle);
		}
		
		/**
		 * Rotates the 3d object around an axis by a defined angle
		 *
		 * @param    axis        The vector defining the axis of rotation
		 * @param    angle        The amount of rotation in degrees
		 */
		public function Rotate(axis:Vector3D, angle:Number):void
		{
			var m:Matrix3D = new Matrix3D();
			m.prependRotation(angle, axis);
			
			var vec:Vector3D = m.decompose()[1];
			
			_rotationX += vec.x;
			_rotationY += vec.y;
			_rotationZ += vec.z;
			
			invalidateRotation();
		}
		
		
		public function TransformDirection(direction:Vector3D) : Vector3D
		{
			//TODO transform direction
			return null;
		}
		
		public function TransformPoint(point:Vector3D) : Vector3D
		{
			//TODO transform position
			return null;
		}		
		
		private function invalidatePivot():void
		{
			_pivotZero = (_pivotPoint.x == 0) && (_pivotPoint.y == 0) && (_pivotPoint.z == 0);
			
			invalidateTransform();
		}
		
		private function invalidatePosition() : void
		{
			if (_positionDirty)
				return;
			
			_positionDirty = true;
			
			invalidateTransform();
		}
		
		private function invalidateRotation() : void
		{
			if (_rotationDirty)
				return;
			
			_rotationDirty = true;
			
			invalidateTransform();
		}
		
		private function invalidateScale() : void
		{
			if (_scaleDirty)
				return;
			
			_scaleDirty = true;
			
			invalidateTransform();
		}
		
		/**
		 * Invalidates the transformation matrix, causing it to be updated the next time it's requested.
		 */
		private function invalidateTransform() : void
		{
			_transformDirty = true;
			
			//Invalidate sceneTransform
			notifySceneTransformChange();
		}
		
		/**
		 * Invalidates the scene transformation matrix, causing it to be updated the next time it's requested.
		 */
		protected function invalidateSceneTransform():void
		{
			_sceneTransformDirty = true;
			_inverseSceneTransformDirty = true;
			
			_worldPositionDirty = true;
			_worldRotationDirty = true;
			_worldScaleDirty = true;
		}
		
		private function updateTransform():void
		{
			_pos.x = _x;
			_pos.y = _y;
			_pos.z = _z;
			
			_rot.x = _rotationX;
			_rot.y = _rotationY;
			_rot.z = _rotationZ;
			
			if (!_pivotZero) {
				_sca.x = 1;
				_sca.y = 1;
				_sca.z = 1;
				
				_transform.recompose(_transformComponents);
				_transform.appendTranslation(_pivotPoint.x, _pivotPoint.y, _pivotPoint.z);
				_transform.prependTranslation(-_pivotPoint.x, -_pivotPoint.y, -_pivotPoint.z);
				_transform.prependScale(_scaleX, _scaleY, _scaleZ);
				
				_sca.x = _scaleX;
				_sca.y = _scaleY;
				_sca.z = _scaleZ;
			}else{
				_sca.x = _scaleX;
				_sca.y = _scaleY;
				_sca.z = _scaleZ;
				
				_transform.recompose(_transformComponents);
			}
			
			_transformDirty = false;
			_positionDirty = false;
			_rotationDirty = false;
			_scaleDirty = false;
		}
		
		private function updateSceneTransform():void
		{
			if (_parent) {
				_sceneTransform.copyFrom(_parent.localToWorldMatrix);
				_sceneTransform.prepend(transformMatrix);
			} else
				_sceneTransform.copyFrom(transformMatrix);
			
			_sceneTransformDirty = false;
		}
		
		
		private function notifySceneTransformChange():void
		{
			if (_sceneTransformDirty)
				return;
			
			invalidateSceneTransform();
			
			var i:uint;
			var len:uint = _children.length;
			
			//act recursively on child objects
			while (i < len)
				_children[i++].notifySceneTransformChange();
			
		}
		
		
		//Component Overrides
		override isotopeInternal function clone():Component
		{
			var trsfComp : Transform = new Transform();
			//TODO copy data
			return trsfComp;
		}
		
		override isotopeInternal function dispose() : void
		{
			//TODO dispose			
			parent = null;

			transformMatrix = new Matrix3D();
			pivotPoint = new Vector3D();
			
			super.dispose();
		}
	}
}