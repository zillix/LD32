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
		public var ACCELERATION:int = 600;
		private const normalFriction:Material = new Material( -.5, 1, 0.38, 0.875, 0.005);
		
		private var _bubbleEmitter:BubbleEmitter;
		
		public function Player(X:Number, Y:Number, Context:BodyContext)
		{
			super(X, Y, 0xffff0000);
			createBody(20, 20, Context);
			this.body.setShapeMaterials(normalFriction);
			maxVelocity.x = 100;
			_bubbleEmitter = new BubbleEmitter(this, PlayState.instance);
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
				PlayState.instance.severTube();
			}
			
			_bubbleEmitter.update();
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