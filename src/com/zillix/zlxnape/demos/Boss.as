package com.zillix.zlxnape.demos
{
	import com.zillix.zlxnape.BodyContext;
	import com.zillix.zlxnape.BodyRegistry;
	import com.zillix.zlxnape.ZlxNapeSprite;
	import com.zillix.zlxnape.CallbackTypes;
	import com.zillix.zlxnape.InteractionGroups;
	import com.zillix.zlxnape.ColorSprite;
	import flash.display.PixelSnapping;
	import nape.constraint.PivotJoint;
	import nape.geom.Vec2;
	import nape.space.Space;
	import nape.phys.BodyType;
	
	import org.flixel.*;
	
	/**
	 * ...
	 * @author zillix
	 */
	public class Boss extends ColorSprite 
	{
		private static const SEGMENT_WIDTH:int = 8;
		private static const SEGMENT_HEIGHT:int = 16;
		private static const MAX_SEGMENTS:int = 20;
		private static const BOSS_COLOR:int = 0xffff22ff;
		
		private var _segments:Vector.<ZlxNapeSprite>;
		private var _segmentIndex:int = 0;
		private var _target:FlxObject;
		private var _joints:Vector.<PivotJoint>;
		private var _tentacleLayer:FlxGroup;
		
		public function Boss(X:Number, Y:Number, target:FlxObject, tentacleLayer:FlxGroup)
		{
			super(X, Y, BOSS_COLOR);
			_target = target;
			_tentacleLayer = tentacleLayer;
		}
		
		override public function createBody(Width:Number, Height:Number, bodyContext:BodyContext, bodyType:BodyType =  null, copyValues:Boolean = true) : void
		{
			super.createBody(Width, Height, bodyContext, bodyType, copyValues);
			
			collisionGroup = InteractionGroups.BOSS;
			collisionMask = ~InteractionGroups.SEGMENT;
			
			addCbType(CallbackTypes.GROUND);
			
			initSegments(_target);
		}
		
		private function initSegments(target:FlxObject) : void
		{
			_joints = new Vector.<PivotJoint>();
			_segments = new Vector.<ZlxNapeSprite>();
			
			var base:ZlxNapeSprite = this;
			for (var i:int = 0; i < MAX_SEGMENTS; i++)
			{
				base = addSegment(base);
				base.followTarget(target, .5, 20);
			}
			
			for (var j:int = 0; j < 10; j++)
			{
				withdrawSegment();
			}
			
			
		}
		
		private function addSegment(obj:ZlxNapeSprite) : ZlxNapeSprite
		{
			const SEGMENT_COLOR:uint = 0xffdddddd;
			var segment:ColorSprite = new ColorSprite(obj.x + obj.width / 2 - SEGMENT_WIDTH / 2, obj.y + obj.height, SEGMENT_COLOR);
			segment.createBody(SEGMENT_WIDTH, SEGMENT_HEIGHT, new BodyContext(_body.space, _bodyRegistry));
			segment.collisionGroup = InteractionGroups.SEGMENT;
			segment.collisionMask = ~InteractionGroups.SEGMENT;
			_segments.push(segment);
			
			_tentacleLayer.add(segment);
			
			var pivotPoint:Vec2 = Vec2.get(obj.x + obj.width/2, obj.y + obj.height);
			var pivotJoint:PivotJoint = new PivotJoint(obj.body, segment.body, 
				obj.body.worldPointToLocal(pivotPoint, true),
				segment.body.worldPointToLocal(pivotPoint, true));
			
			pivotJoint.space = _body.space;
			_joints.push(pivotJoint);
			
			return segment;
		}
		
		public function withdrawSegment() : void
		{
			if (_segmentIndex < MAX_SEGMENTS - 1)
			{
				var joint1:PivotJoint = _joints[_segmentIndex];
				joint1.active = false;
				var segment:ZlxNapeSprite = _segments[_segmentIndex];
				segment.disable();
				var joint2:PivotJoint = _joints[_segmentIndex + 1];
				joint2.body1 = this.body;
				_segmentIndex++;
			}
		}
		
		public function extendSegment() : void
		{
			var segment:ZlxNapeSprite = _segments[_segmentIndex - 1];
			segment.enable(_body.space);
			var joint1:PivotJoint = _joints[_segmentIndex - 1];
			joint1.active = true;
			var joint2:PivotJoint = _joints[_segmentIndex];
			joint2.body1 = segment.body;
			_segmentIndex--;
		}
		
		public override function update() : void
		{
			super.update();
			_body.setVelocityFromTarget(new Vec2(FlxG.mouse.x, FlxG.mouse.y), _body.rotation, 5);
		}
	}
	
}