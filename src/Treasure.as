package 
{
	import com.zillix.zlxnape.BodyContext;
	import com.zillix.zlxnape.ZlxNapeSprite;
	import nape.phys.BodyType;
	import flash.utils.getTimer;
	import com.zillix.zlxnape.InteractionGroups;
	import com.zillix.zlxnape.CallbackTypes;
	import com.zillix.utils.ZMathUtils;
	import nape.phys.FluidProperties;
	import nape.geom.Vec2;
	/**
	 * ...
	 * @author zillix
	 */
	public class Treasure extends ZlxNapeSprite 
	{
		[Embed(source = "data/treasure.png")]	public var TreasureSprite:Class;
		
		private var _bubbleCount:int = 0;
		public static const BUBBLES_REQUIRED:int = 16;
		private var _opened:Boolean = false;
		
		
		public function Treasure(X:Number, Y:Number, Context:BodyContext)
		{
			super(X, Y);
			loadGraphic(TreasureSprite, true);
			addAnimation("closed", [0]);
			addAnimation("opening", [1]);
			addAnimation("opening2", [2]);
			addAnimation("opened", [3]);
			createBody(width, height, Context, BodyType.STATIC);
			/*var fluidProperties:FluidProperties = new FluidProperties(Water.DENSITY + 4, 2);
			body.setShapeFluidProperties(fluidProperties);
			body.type = BodyType.STATIC;
			fluidMask = InteractionGroups.BUBBLE;
			collisionMask = 0;// InteractionGroups.BUBBLE;
			addCbType(CallbackTypes.TREASURE);
			fluidEnabled = true;*/
			
			
			makeFluid( Water.DENSITY, 2);
			
			addCbType(CallbackTypes.TREASURE);
			
			collisionGroup = InteractionGroups.TERRAIN;
			
			
		}
		
		override public function update() : void
		{
			super.update();
			
			if (_bubbleCount == 0)
			{
				play("closed");
			}
			else if (_bubbleCount / BUBBLES_REQUIRED < .5)
			{
				play("opening");
			}
			else if (_bubbleCount < BUBBLES_REQUIRED)
			{
				play("opening2");
			}
			else
			{
				play("open");
			}
		}
		
		public function onTouchBubble(bubble:Bubble) : void
		{
			if (_opened || bubble.isShrinking())
			{
				return;
			}
			
			bubble.onTouchAir();
			_bubbleCount++;
			if (_bubbleCount >= BUBBLES_REQUIRED)
			{
				openTreasure();
			}
		}
		
		private function openTreasure() : void
		{
			_opened = true;
			
			
			var pickup:TreasurePickup = new TreasurePickup(x, y - height, _bodyContext, PlayState.instance.getTube());
			
			pickup.body.applyImpulse(Vec2.get(300, -300));
			pickup.body.applyAngularImpulse(200);;
			
			PlayState.instance.rockLayer.add(pickup);
		}
		
	}
	
}