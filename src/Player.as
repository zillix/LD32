package 
{
	import com.zillix.zlxnape.BodyContext;
	import com.zillix.zlxnape.ColorSprite;
	import com.zillix.zlxnape.ZlxNapeSprite;
	import com.zillix.zlxnape.*;
	import nape.phys.Material;
	import nape.geom.Vec2;
	import org.flixel.*;
	import flash.utils.getTimer;
	import com.zillix.utils.ZMathUtils;
	
	/**
	 * ...
	 * @author zillix
	 */
	public class Player extends ZlxNapeSprite
	{
		[Embed(source = "data/player.png")]	public var PlayerSprite:Class;
		[Embed(source = "data/bubble.mp3")]	public var BubbleSound:Class;
		[Embed(source = "data/sever.mp3")]	public var SeverSound:Class;
		
		public var EXHAUSTED_ACCELERATION:int = 3500;
		
		public var ACCELERATION:int = 5500; // 5500;
		public var MAX_SPEED:int = 20;
		private const normalFriction:Material = new Material( -.5, 1, 0.38, 0.875, 0.005);
		
		private var _bubbleEmitter:BubbleEmitter;
		
		public var maxAir:Number = 60;
		public var currentAir:Number = 60;
		public static const NORMAL_AIR_DRAIN:Number = 1;
		public static const MOVING_AIR_DRAIN:Number = 3;
		public static const BUBBLING_AIR_DRAIN:Number = 5;
		
		public static const DAMAGE_AIR:Number = 30;
		
		public static const AIR_TUBE_REGAIN:Number = 1000;
		public static const AIR_ZONE_REGAIN:Number = 60;
		
		private var _lastDamageTime:int = 0;
		
		private var _severed:Boolean = false;
		public function get severed() : Boolean { return _severed; }
		
		public static const DAMAGE_COOLDOWN:Number = 1;
		
		public static const DAMAGE_IMPULSE:Number = 2000;
		
		private var _exhausted:Boolean = false;
		private var _touchingAir:Boolean = false;
		
		public var bouyant:Boolean = false;
		
		public var ROTATE_SPEED:Number = 360;
		
		public var nextBubbleSoundTime:int = 0;
		public var BUBBLE_SOUND_DELAY:Number = .15;
		
		public function Player(X:Number, Y:Number, Context:BodyContext)
		{
			super(X, Y);
			createBody(16, 16, Context);
			this.body.setShapeMaterials(normalFriction);
			maxVelocity.x = MAX_SPEED;
			maxVelocity.y = MAX_SPEED;
			scale.x = scale.y = 2;
			_bubbleEmitter = new BubbleEmitter(this, PlayState.instance);
			setMaterial(new Material(1, 1, 2, Water.DENSITY - .2, 0.001));
			addCbType(CallbackTypes.PLAYER);
			
			PlayState.instance.attachGlow(this, 300);
			
			loadGraphic(PlayerSprite, true, true, 16, 16);
			//loadRotatedGraphic(PlayerSprite, 128, -1, false, true);
			addAnimation("float", [0, 1, 2, 3, 4, 3, 2, 1], 3);
			addAnimation("swim", [0, 1, 2, 3, 4, 3, 2, 1], 8);
			play("float");
			
			_canRotate = false;
			
		}
		
		public function get canMove() : Boolean
		{
			return PlayState.instance.startedGame &&
			  !PlayState.instance.endingGame;
		}
		
		override public function update() : void
		{
			super.update();
			
			
			var keyPressed:Boolean = false;
			if (canMove)
			{
				if (FlxG.keys.pressed("RIGHT"))
				{
					_body.applyImpulse(Vec2.get(ACCELERATION * FlxG.elapsed));
					keyPressed = true;
					facing = RIGHT;
				}
				else if (FlxG.keys.pressed("LEFT"))
				{
					_body.applyImpulse(Vec2.get(-ACCELERATION * FlxG.elapsed));
					keyPressed = true;
					facing = LEFT;
				}
			}
			if (!_exhausted)
			{
				if (canMove)
				{
					if (FlxG.keys.pressed("UP"))
					{
						_body.applyImpulse(Vec2.get(0, -ACCELERATION * FlxG.elapsed));
						keyPressed = true;
					}
					else if (FlxG.keys.pressed("DOWN"))
					{
						_body.applyImpulse(Vec2.get(0, ACCELERATION * FlxG.elapsed));
						keyPressed = true;
					}
				}
				
				if (FlxG.keys.justPressed("SPACE"))
				{
					_bubbleEmitter.startEmit();
				}
				
				
				if (FlxG.keys.pressed("SPACE"))
				{
					if (getTimer() > nextBubbleSoundTime)
					{
						FlxG.play(BubbleSound, PlayState.SFX_VOLUME * .15);
						nextBubbleSoundTime = getTimer() + BUBBLE_SOUND_DELAY * 1000;
					}
				}
			} 
			
			if (keyPressed)
			{
				play("swim");
			}
			else
			{
				play("float");
			}
			
			
			
			
			var desiredAngle:Number = angle;// = ZMathUtils.toDegrees(body.velocity.angle);
			/*if (facing == LEFT)
			{
				desiredAngle = -180 -  desiredAngle;
			}*/
			
			if (FlxG.keys.RIGHT || FlxG.keys.LEFT)
			{
				desiredAngle = 0;
			}
			
			if (FlxG.keys.UP)
			{
				if (FlxG.keys.RIGHT || FlxG.keys.LEFT)
				{
					desiredAngle = -45;
				}
				else
				{
					desiredAngle = -90;
				}
			}
			
			if (FlxG.keys.DOWN)
			{
				if (FlxG.keys.RIGHT || FlxG.keys.LEFT)
				{
					desiredAngle = 45;
				}
				else
				{
					desiredAngle = 90;
				}
			}
			
			if (facing == LEFT)
			{
				desiredAngle = - desiredAngle;
			}
			
			
			
			
			
			if (angle < desiredAngle)
			{
				angle = Math.min(desiredAngle, angle + FlxG.elapsed * ROTATE_SPEED);
			}
			else
			{
				angle = Math.max(desiredAngle, angle - FlxG.elapsed * ROTATE_SPEED);
			}
			
			if (bouyant)
			{
				_body.applyImpulse(Vec2.get(0, -EXHAUSTED_ACCELERATION * FlxG.elapsed));
			}
			
			
			if (FlxG.keys.justReleased("SPACE"))
			{
				_bubbleEmitter.stopEmit();
			}
			
			if (FlxG.keys.justPressed("R"))
			{
				sever();
				PlayState.instance.severTube();
				PlayState.instance.rKey.visible = false;
				FlxG.play(SeverSound, PlayState.SFX_VOLUME);
			}
			
			_bubbleEmitter.update();
			
			
			var airDrain:Number = 0;
			airDrain += NORMAL_AIR_DRAIN;
			if (keyPressed)
			{
				airDrain += MOVING_AIR_DRAIN;
			}
			if (FlxG.keys.SPACE)
			{
				airDrain += BUBBLING_AIR_DRAIN;
			}
			
			if (!_severed)
			{
				airDrain -= AIR_TUBE_REGAIN;
			}
			if (_touchingAir)
			{
				airDrain -= AIR_ZONE_REGAIN;
			}
			
			modifyAir( -airDrain * FlxG.elapsed);
			
			/*if (_exhausted && currentAir == maxAir)
			{
				_exhausted = false;
				
				PlayState.instance.hud.setPlayerExhausted(false);
			}*/
		}
		
		private function modifyAir(amt:Number) : void
		{
			var aboveZero:Boolean = currentAir > 0;
			currentAir = Math.min(maxAir, Math.max(0, currentAir + amt));
			if (currentAir <= 0)
			{
				becomeExhausted(true);
			}
			
		}
		
		public function sever() : void
		{
			_severed = true;
		}
		
		override public function addDefaultCbTypes() : void
		{
			super.addDefaultCbTypes();
			addCbType(CallbackTypes.PLAYER);
			collisionGroup = InteractionGroups.PLAYER;
			collisionMask = ~InteractionGroups.NO_COLLIDE;
			collisionMask = ~(InteractionGroups.NO_COLLIDE); // | InteractionGroups.PLAYER_ATTACK);
		}
		
		public function damage() : void
		{
			if (_lastDamageTime < getTimer() + DAMAGE_COOLDOWN)
			{
				_lastDamageTime = getTimer();
				
				//modifyAir( -DAMAGE_AIR);
				body.applyImpulse(body.velocity.normalise().mul( -DAMAGE_IMPULSE));
				flicker();
				FlxG.flash(0x88ff0000, .5);
			}
			
			
		}
		
		public function becomeExhausted(death:Boolean = false ) : void
		{
			if (_exhausted)
			{
				return;
			}
			_exhausted = true;
			currentAir = 0;
			PlayState.instance.hud.setPlayerExhausted(true);
			if (death)
			{
				PlayState.instance.endGame(PlayState.END_DEATH);
			}
		}
		
		public function becomeBuoyant(): void
		{
			bouyant = true;
			_exhausted = true;
		}
		
		public function onTouchAir(bool:Boolean) : void
		{
			_touchingAir = bool;
		}
		
		public function onTreasurePickedUp() : void
		{
			becomeBuoyant();
		}
		
	}
	
}