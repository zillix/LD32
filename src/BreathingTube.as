package 
{
	import com.zillix.zlxnape.BodyContext;
	import com.zillix.zlxnape.ColorSprite;
	import com.zillix.zlxnape.*;
	import flash.display.DisplayObject;
	import nape.constraint.PivotJoint;
	import nape.constraint.DistanceJoint;
	import nape.geom.Vec2;
	import nape.phys.Material;
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
		private static const MAX_SEGMENTS:int = 40;
		private static const SEGMENT_COLOR:uint = 0xffdddddd;
			
		
		private var _tubeLayer:FlxGroup;
		
		private var _playerJoint:DistanceJoint;
		private var _player:Player;
		
		private var _bubbleEmitter:BubbleEmitter;
		
		private var _chain:BodyChain;
		
		
		
		private static const SUB_COLOR:uint = 0xffffff00;
		public function BreathingTube(X:Number, Y:Number, TubeLayer:FlxGroup, player:Player, Context:BodyContext)
		{
			super(X, Y, SUB_COLOR);
			createBody(50, 50, Context, BodyType.STATIC);
			
			_tubeLayer = TubeLayer;
			_player = player;
			
			_chain = new BodyChain(this,
				getEdgeVector(DIRECTION_FORWARD), 
				_tubeLayer,
				Context,
				MAX_SEGMENTS,
				SEGMENT_WIDTH,
				SEGMENT_HEIGHT,
				SEGMENT_COLOR,
				1,
				4);
				
				
			_chain.segmentMaterial = new Material(0, 1, 2, .01);
			_chain.segmentCollisionMask = InteractionGroups.TERRAIN;
			
			collisionGroup = InteractionGroups.TERRAIN;
			collisionMask = ~(InteractionGroups.NO_COLLIDE | InteractionGroups.SEGMENT);
		}
		
		public function init() : void
		{
			_chain.init();
			//initSegments(_player);
			
			var lastSegment:ZlxNapeSprite = _chain.segments[_chain.segments.length - 1];
			 _playerJoint = new DistanceJoint(lastSegment.body, _player.body, 
				Vec2.weak(), Vec2.weak(), 5, 20);
			
			_playerJoint.space = _body.space;
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
			_bubbleEmitter = new BubbleEmitter(_chain.segments[_chain.segments.length - 1], PlayState.instance, 1);
			_bubbleEmitter.startEmit();
		}
	}
	
}