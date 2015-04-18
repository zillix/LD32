package 
{
	import nape.geom.Vec2;
	import org.flixel.*;
	
	/**
	 * ...
	 * @author zillix
	 */
	public class PlayerFollower extends FlxSprite 
	{
		
		private var PLAYER_FOLLOWER_SPEED:Number = 2000;
		private var PLAYER_FOLLOWER_MIN_DIST:Number = 50;
		private var _target:Player;
		
		public var overridePlayerFollowerTarget:FlxSprite;
		
		public function PlayerFollower(X:Number, Y:Number, target:Player)
		{
			super(X, Y);
			_target = target;
		}
		
		public function getPlayerFollowerTarget():Vec2
		{
			if (overridePlayerFollowerTarget != null)
			{
				return Vec2.get(overridePlayerFollowerTarget.x, overridePlayerFollowerTarget.y);
			}
			else
			{
				return _target.body.position;
			}
		}
		
		override public function update() : void
		{
			super.update();
			
			var playerVec:Vec2 = getPlayerFollowerTarget();
			var followerVec:Vec2 = Vec2.get(x, y);
			var followerVel:Vec2 = playerVec.sub(followerVec);
			var followerDist:Number = followerVel.length;
			var angleRadians:Number = followerVec.angle;
			if (followerDist > PLAYER_FOLLOWER_MIN_DIST)
			{
				followerVel.length = PLAYER_FOLLOWER_SPEED * FlxG.elapsed;
				if (followerDist - followerVel.length < PLAYER_FOLLOWER_MIN_DIST)
				{
					followerVel.length = followerDist - PLAYER_FOLLOWER_MIN_DIST;
				}
				x += followerVel.x;
				y += followerVel.y;
			}
		}
	}
	
}