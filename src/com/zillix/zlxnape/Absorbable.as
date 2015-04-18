package com.zillix.zlxnape
{
	import nape.callbacks.CbType;
	import nape.shape.Polygon;
	import nape.shape.Shape;
 
	import nape.geom.Mat23;
	import nape.geom.Vec2;
	import nape.phys.Body;
	import nape.space.Space;
	import nape.phys.BodyType;
	import nape.phys.Material;
	/**
	 * ...
	 * @author zillix
	 */
	public class Absorbable extends ZlxNapeSprite 
	{
		private static const FADE_RATE:Number = 2;
		
		private var _powerLevelValue:int = 1;
		private var _beingAssimilated:Boolean = false;
		private var _beingAbsorbed:Boolean = false;
		protected var _canBeAbsorbed:Boolean = true;
		protected var _wasEjected:Boolean = false;
		
		public function Absorbable(X:Number, Y:Number)
		{
			super(X, Y);
		}
		
		override public function addDefaultCbTypes() : void
		{
			addCbType(CallbackTypes.GROUND);
			addCbType(CallbackTypes.ABSORB);
		}
		
		public function startAbsorb() : void
		{
			if (!_canBeAbsorbed)
			{
				return;
			}
			_beingAbsorbed = true;
		}
		
		public function get isBeingAbsorbed() : Boolean
		{
			return _beingAbsorbed;
		}
		
		public function get isBeingAssimilated() : Boolean
		{
			return _beingAssimilated;
		}
		
		public function get canBeAssimilated() : Boolean
		{
			return !_beingAssimilated;
		}
		
		public function set isBeingAssimilated(bool:Boolean) : void
		{
			_beingAssimilated = bool;
		}
		
		public function get canBeAbsorbed() : Boolean
		{
			return _canBeAbsorbed;
		}
		
		public function get wasEjected() : Boolean
		{
			return _wasEjected;
		}
		
		public function get powerLevelValue():int 
		{
			return _powerLevelValue;
		}
		
		public function set powerLevelValue(value:int):void 
		{
			_powerLevelValue = value;
		}
		
		public function eject(space:Space) : void
		{
			_wasEjected = true;
			_beingAbsorbed = false;
			_canBeAbsorbed = false;
			scale.x = scale.y = _defaultScale;
			body.space = space;
			body.rotation = Math.random() * Math.PI * 2;
			alpha = .8;
			alive = true;
			exists = true;
			removeCbType(CallbackTypes.ABSORB);
			removeCbType(CallbackTypes.GROUND);
			addCbType(CallbackTypes.EJECTED);
			collisionMask = -1;
			collisionGroup = InteractionGroups.NO_COLLIDE;
			PlayState.instance.addObject(this, PlayState.instance.boxes);
		}
		
		public function hitGroundAfterEjected() : void
		{
			if (!_wasEjected)
			{
				return;
			}
			
			collisionGroup = collisionGroup & ~InteractionGroups.NO_COLLIDE;
			
			_wasEjected = false;
			_canBeAbsorbed = true;
			alpha = 1;
			addCbType(CallbackTypes.ABSORB);
			addCbType(CallbackTypes.GROUND);
			removeCbType(CallbackTypes.EJECTED);
			collisionGroup = InteractionGroups.BOX;
		}
		
		override public function update() : void
		{
			super.update();
			if (_beingAbsorbed)
			{
				scale.x *= .9;
				scale.y *= .9;
				alpha -= FADE_RATE * FlxG.elapsed;
				var dist:Number;
				var maxAttract:Number = 7;
				var maxAttractDist:Number = 100;
				var attraction:Number;
				var playerVec:Vec2 = PlayState.instance.player.body.position;
				var distVec:Vec2 = playerVec.sub(body.position, true);
				dist = distVec.length;
				if (dist < maxAttractDist)
				{
					attraction = (maxAttractDist - dist) / maxAttractDist * maxAttract;
					body.applyImpulse(distVec.muleq(attraction * FlxG.elapsed));
				}
				
				if (scale.x < .05)
				{
					kill();
				}
			}
		}
	}
	
}