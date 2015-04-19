package 
{
	import com.zillix.zlxnape.*;
	import com.zillix.zlxnape.ColorSprite;
	import com.zillix.zlxnape.demos.ZlxNapeDemo;
	import flash.geom.Point;
	import nape.callbacks.CbType;
	import nape.constraint.DistanceJoint;
	import nape.geom.Vec2;
	import nape.phys.Material;
	import nape.phys.BodyType;
	import org.flixel.FlxGroup;
	import com.zillix.zlxnape.ZlxNapeSprite;
	import org.flixel.FlxObject;
	import org.flixel.FlxPoint;
	import org.flixel.FlxSprite;
	
	/**
	 * ...
	 * @author zillix
	 */
	public class BodyChain
	{
		private var _segments:Vector.<ZlxNapeSprite>;
		private var _segmentIndex:int = 0;
		private var _joints:Vector.<DistanceJoint>;
		private var _layer:FlxGroup;
		
		private var _segmentCount:int = 0;
		private var _segmentWidth:int = 0;
		private var _segmentHeight:int = 0;
		
		private var _segmentColor:uint = 0;
		
		private var _minDist:int = 5;
		private var _maxDist:int = 20;
		
		private var _anchor:ZlxNapeSprite;
		private var _bodyContext:BodyContext;
		
		private var _offsetVector:Vec2;
		
		public var target:ZlxNapeSprite;
		public var followAcceleration:Number = 10;
		public var maxFollowSpeed:Number = 15;
		public var fluidMask:Number = 0;
		public var segmentMaterial:Material = Material.wood();
		public var elasticJoints:Boolean = false;
		public var segmentCollisionMask:uint = DEFAULT_COLLOSION_MASK;
		
		
		private var _dead:Boolean = false;
		
		public var segmentSpriteClass:Class;
		public var segmentSpriteScale:FlxPoint = new FlxPoint(2, 2);
		
		public var segmentSpriteRotations:int = 32;
		public var segmentDrag:FlxPoint = new FlxPoint(15, 15);
		
		
		private static var DEFAULT_COLLOSION_MASK:uint = ~(InteractionGroups.SEGMENT | InteractionGroups .NO_COLLIDE);
		
		
		private static const SUB_COLOR:uint = 0xffffff00;
		public function BodyChain(anchor:ZlxNapeSprite, 
			offsetVector:Vec2,
			Layer:FlxGroup,
			bodyContext:BodyContext,
			SegmentCount:int = 5, 
			SegmentWidth:int = 8, 
			SegmentHeight:int = 16,
			SegmentColor:uint = 0xffdddddd,
			MinSegmentDist:int = 5,
			MaxSegmentDist:int = 20
			)
		{
			_anchor = anchor;
			_layer = Layer;
			_segmentCount = SegmentCount;
			_segmentWidth = SegmentWidth;
			_segmentHeight = SegmentHeight;
			_segmentColor = SegmentColor;
			_bodyContext = bodyContext;
			_minDist = MinSegmentDist;
			_maxDist = MaxSegmentDist;
			_offsetVector = offsetVector;
		}
		
		public function init() : void
		{
			initSegments();
		}
		
		public function get segments() : Vector.<ZlxNapeSprite>
		{
			return _segments;
		}
		
		private function initSegments() : void
		{
			_joints = new Vector.<DistanceJoint>();
			_segments = new Vector.<ZlxNapeSprite>();
			
			var base:ZlxNapeSprite = _anchor;
			var i:int;
			for (i = 0; i < _segmentCount; i++)
			{
				base = addSegment(base);
				if (target != null)
				{
					base.followTarget(target, followAcceleration, maxFollowSpeed);
				}
			}
			
			for (i = 0; i < _joints.length; i++)
			{
				_joints[i].stiff = !elasticJoints;
			}
			
		}
		
		private function addSegment(obj:ZlxNapeSprite) : ZlxNapeSprite
		{
			var segment:ColorSprite = new ColorSprite(
			_offsetVector.x + _anchor.x,
			_offsetVector.y + _anchor.y,
			_segmentColor);
			
			segment.drag = segmentDrag;
			
			segment.createBody(_segmentWidth, _segmentHeight, _bodyContext);
			segment.setMaterial(segmentMaterial);
			segment.collisionGroup = InteractionGroups.SEGMENT;
			segment.collisionMask = segmentCollisionMask;
			segment.fluidMask = fluidMask;
			segment.sleeps = true;
			
			if (segmentSpriteClass)
			{
				segment.loadRotatedGraphic(segmentSpriteClass, segmentSpriteRotations, -1, false, true);
				segment.scale = segmentSpriteScale;
			}
			
			_segments.push(segment);
			
			_layer.add(segment);
			
			var distanceJoint:DistanceJoint = new DistanceJoint(obj.body, segment.body,
				obj == _anchor ? 
					_offsetVector :
						obj.getEdgeVector(ZlxNapeSprite.DIRECTION_LEFT),
				segment.getEdgeVector(ZlxNapeSprite.DIRECTION_RIGHT),
				_minDist,
				_maxDist);
				
			distanceJoint.maxForce = 100000;
			
			
			distanceJoint.space = _bodyContext.space;
			_joints.push(distanceJoint);
			
			return segment;
		}
		
		public function withdrawSegment() : void
		{
			if (_segmentIndex < _segmentCount - 1)
			{
				var joint1:DistanceJoint = _joints[_segmentIndex];
				joint1.active = false;
				var segment:ZlxNapeSprite = _segments[_segmentIndex];
				segment.disable();
				var joint2:DistanceJoint = _joints[_segmentIndex + 1];
				joint2.body1 = _anchor.body;
				_segmentIndex++;
			}
		}
		
		public function extendSegment() : void
		{
			if (_segmentIndex == 0)
			{
				return;
			}
			
			var segment:ZlxNapeSprite = _segments[_segmentIndex - 1];
			segment.enable(_bodyContext.space);
			var joint1:DistanceJoint = _joints[_segmentIndex - 1];
			joint1.active = true;
			var joint2:DistanceJoint = _joints[_segmentIndex];
			joint2.body1 = segment.body;
			_segmentIndex--;
		}
		
		public function kill() : void
		{
			if (_dead)
			{
				return;
			}
			_dead = true;
			
			var i:int;
			for (i = 0; i < _segments.length; i++)
			{
				if (_segments[i])
				{
					_segments[i].kill();
				}
			}
			
			for (i = 0; i < _joints.length; i++)
			{
				if (_joints[i])
				{
					_joints[i].active = false;
					_joints[i].space = null;
				}
			}
		}
		
		public function set alpha(val:Number) : void
		{
			for each (var segment:FlxSprite in segments)
			{
				segment.alpha = val;
			}
		}
		
		public function set visible(bool:Boolean) : void
		{
			for each (var segment:FlxSprite in segments)
			{
				segment.visible = bool;
			}
		}
		
		public function getArray() : Array
		{
			var array:Array = [];
			for each (var segment:FlxSprite in segments)
			{
				array.push(segment);
			}
			return array;
		}
		
		public function addCbType(type:CbType) : void
		{
			for each (var segment:ZlxNapeSprite in segments)
			{
				segment.addCbType(type);
			}
		}
		public function get currentSegmentCount() : int
		{
			return segments.length - _segmentIndex;
		}
	}
	
}