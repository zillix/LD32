package 
{
	import com.zillix.zlxnape.BodyContext;
	import com.zillix.zlxnape.ColorSprite;
	import com.zillix.zlxnape.ZlxNapeSprite;
	import com.zillix.zlxnape.*;
	import nape.phys.Material;
	import nape.geom.Vec2;
	import org.flixel.*;
	
	/**
	 * ...
	 * @author zillix
	 */
	public class Player extends ColorSprite
	{
		public var ACCELERATION:int = 800;
		public var MAX_SPEED:int = 250;
		private const normalFriction:Material = new Material( -.5, 1, 0.38, 0.875, 0.005);
		
		private var _bubbleEmitter:BubbleEmitter;
		
		public var maxAir:Number = 100;
		public var currentAir:Number = 100;
		public static const NORMAL_AIR_DRAIN:Number = 2;
		public static const MOVING_AIR_DRAIN:Number = 4;
		public static const BUBBLING_AIR_DRAIN:Number = 15;
		
		public static const AIR_REGAIN:Number = 15;
		
		private var _severed:Boolean = false;
		
		public function Player(X:Number, Y:Number, Context:BodyContext)
		{
			super(X, Y, 0xffff0000);
			createBody(20, 20, Context);
			this.body.setShapeMaterials(normalFriction);
			maxVelocity.x = MAX_SPEED;
			_bubbleEmitter = new BubbleEmitter(this, PlayState.instance);
			setMaterial(new Material(1, 1, 2, Water.DENSITY + .2, 0.001));
			addCbType(CallbackTypes.PLAYER);
			
			PlayState.instance.attachGlow(this, 200);
		}
		
		override public function update() : void
		{
			super.update();
			
			var keyPressed:Boolean = false;
			if (FlxG.keys.pressed("RIGHT"))
			{
				_body.applyImpulse(Vec2.get(ACCELERATION * FlxG.elapsed));
				keyPressed = true;
				facing = RIGHT;
			}
			else if (FlxG.keys.pressed("LEFT"))
			{
				_body.applyImpulse(Vec2.get(-ACCELERATION * FlxG.elapsed));
				facing = LEFT;
				keyPressed = true;
			}
			
			if (FlxG.keys.pressed("UP"))
			{
				_body.applyImpulse(Vec2.get(0, -ACCELERATION * FlxG.elapsed));
				keyPressed = true;
			}
			else if (FlxG.keys.pressed("DOWN"))
			{
				_body.applyImpulse(Vec2.get(0, ACCELERATION * FlxG.elapsed));
				facing = LEFT;
				keyPressed = true;
			}
			
			if (FlxG.keys.justPressed("SPACE"))
			{
				_bubbleEmitter.startEmit();
			}
			if (FlxG.keys.justReleased("SPACE"))
			{
				_bubbleEmitter.stopEmit();
			}
			
			if (FlxG.keys.justPressed("F"))
			{
				sever();
				PlayState.instance.severTube();
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
				airDrain -= AIR_REGAIN;
			}
			
			currentAir = Math.min(maxAir, Math.max(0, currentAir - airDrain * FlxG.elapsed));
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
		
	}
	
}