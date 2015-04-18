package com.zillix.zlxnape
{
	import nape.constraint.DistanceJoint;
	import nape.phys.Body;
	import nape.space.Space;
	import org.flixel.*;
	
	/**
	 * ...
	 * @author zillix
	 */
	public class SpriteChain 
	{
		private var _chain:Vector.<ZlxNapeSprite>;
		private var _joints:Vector.<DistanceJoint>;
		private var _space:Space;
		private var _minDist:int = 5;
		private var _maxDist:int = 500;
		
		
		public function SpriteChain(s:Space) : void
		{
			_chain = new Vector.<ZlxNapeSprite>;
			_joints = new Vector.<DistanceJoint>;
			_space = s;
		}
		
		public function addSprite(sprite:ZlxNapeSprite) : void
		{
			
			_chain.push(sprite);
			if (_chain.length > 1)
			{
				var lastSprite:ZlxNapeSprite = _chain[_chain.length - 2];
				join(lastSprite, sprite);
			}
		}
		
		private function join(sprite1:ZlxNapeSprite, sprite2:ZlxNapeSprite) : void
		{
			var joint:DistanceJoint = new DistanceJoint(sprite1.body, sprite2.body, 
				sprite1.getEdgeVector(ZlxNapeSprite.DIRECTION_BACKWARDS),
				sprite2.getEdgeVector(ZlxNapeSprite.DIRECTION_FORWARD), 
				0,
				Math.min(_maxDist,
					FlxU.getDistance(new FlxPoint(sprite1.x, sprite1.y), new FlxPoint(sprite2.x, sprite2.y))));
			joint.space = _space;
			_joints.push(joint);
				
		}
		
		public function contract(amt:Number) : void
		{
			for each (var joint:DistanceJoint in _joints)
			{
				joint.jointMax = Math.max(_minDist, joint.jointMax - amt);
			}
		}
		
	}
	
}