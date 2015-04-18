package 
{
	import com.zillix.zlxnape.BodyContext;
	import com.zillix.zlxnape.ColorSprite;
	import com.zillix.zlxnape.*;
	import flash.display.DisplayObject;
	import nape.constraint.PivotJoint;
	import nape.constraint.DistanceJoint;
	import nape.geom.Vec2;
	import org.flixel.FlxGroup;
	import nape.phys.BodyType;
	import org.flixel.FlxObject;
	/**
	 * ...
	 * @author zillix
	 */
	public class BreathingTube extends ColorSprite
	{
		private static const SEGMENT_WIDTH:int = 8;
		private static const SEGMENT_HEIGHT:int = 16;
		private static const MAX_SEGMENTS:int = 20;
		
		private var _segments:Vector.<ZlxNapeSprite>;
		private var _segmentIndex:int = 0;
		private var _joints:Vector.<DistanceJoint>;
		private var _tubeLayer:FlxGroup;
		
		private var _playerJoint:DistanceJoint;
		private var _player:Player;
		
		private var _bubbleEmitter:BubbleEmitter;
		
		private static const SUB_COLOR:uint = 0xffffff00;
		public function BreathingTube(X:Number, Y:Number, TubeLayer:FlxGroup, player:Player, Context:BodyContext)
		{
			super(X, Y, SUB_COLOR);
			createBody(50, 50, Context, BodyType.STATIC);
			
			_tubeLayer = TubeLayer;
			_player = player;
			
		
			collisionGroup = InteractionGroups.TERRAIN;
			collisionMask = ~(InteractionGroups.NO_COLLIDE | InteractionGroups.SEGMENT);
		}
		
		public function init() : void
		{
			initSegments(_player);
			
			var lastSegment:ZlxNapeSprite = _segments[_segments.length - 1];
			//var joint:DistanceJoint = new DistanceJoint(lastSegment
			 _playerJoint = new DistanceJoint(lastSegment.body, _player.body, 
				Vec2.weak(), Vec2.weak(), 5, 20);//lastSegment.body.worldPointToLocal(pivotPoint, true),
				//_player.body.);
			
			_playerJoint.space = _body.space;
		}
		
		private function initSegments(target:FlxObject) : void
		{
			_joints = new Vector.<DistanceJoint>();
			_segments = new Vector.<ZlxNapeSprite>();
			
			var base:ZlxNapeSprite = this;
			for (var i:int = 0; i < MAX_SEGMENTS; i++)
			{
				base = addSegment(base);
				
				//base.followTarget(target, .5, 20);
			}
			
			/*for (var j:int = 0; j < 10; j++)
			{
				withdrawSegment();
			}
			*/
			
		}
		
		private function addSegment(obj:ZlxNapeSprite) : ZlxNapeSprite
		{
			const SEGMENT_COLOR:uint = 0xffdddddd;
			var segment:ColorSprite = new ColorSprite(
			//obj.x + obj.width / 2 - SEGMENT_WIDTH / 2, 
			//obj.y + obj.height, 
			x,
			y,
			SEGMENT_COLOR);
			segment.createBody(SEGMENT_WIDTH, SEGMENT_HEIGHT, new BodyContext(_body.space, _bodyRegistry));
			segment.collisionGroup = InteractionGroups.SEGMENT;
			segment.collisionMask = ~(InteractionGroups.SEGMENT);
			segment.fluidMask = 0;
			_segments.push(segment);
			
			_tubeLayer.add(segment);
			
			//var pivotPoint:Vec2 = Vec2.get(obj.x + obj.width/2, obj.y + obj.height);
			/*var distanceJoint:DistanceJoint = new DistanceJoint(obj.body, segment.body, 
				obj.body.worldPointToLocal(pivotPoint, true),
				segment.body.worldPointToLocal(pivotPoint, true));
			*/
			var distanceJoint:DistanceJoint = new DistanceJoint(obj.body, segment.body,
				obj.getEdgeVector(DIRECTION_LEFT),
				segment.getEdgeVector(DIRECTION_RIGHT),
				//segment.body.worldPointToLocal(pivotPoint, true),
				5,
				20);
			
			
			distanceJoint.space = _body.space;
			_joints.push(distanceJoint);
			
			return segment;
		}
		
		public function withdrawSegment() : void
		{
			if (_segmentIndex < MAX_SEGMENTS - 1)
			{
				var joint1:DistanceJoint = _joints[_segmentIndex];
				joint1.active = false;
				var segment:ZlxNapeSprite = _segments[_segmentIndex];
				segment.disable();
				var joint2:DistanceJoint = _joints[_segmentIndex + 1];
				joint2.body1 = this.body;
				_segmentIndex++;
			}
		}
		
		public function extendSegment() : void
		{
			var segment:ZlxNapeSprite = _segments[_segmentIndex - 1];
			segment.enable(_body.space);
			var joint1:DistanceJoint = _joints[_segmentIndex - 1];
			joint1.active = true;
			var joint2:DistanceJoint = _joints[_segmentIndex];
			joint2.body1 = segment.body;
			_segmentIndex--;
		}
		
		public override function update() : void
		{
			super.update();
			
			if (_bubbleEmitter != null)
			{
				_bubbleEmitter.update();
			}
		}
		
		public function sever() : void
		{
			_playerJoint.active = false;
			_bubbleEmitter = new BubbleEmitter(_segments[_segments.length - 1], PlayState.instance, 1);
			_bubbleEmitter.startEmit();
		}
	}
	
}