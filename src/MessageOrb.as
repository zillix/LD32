package 
{
	import com.zillix.zlxnape.BodyContext;
	import com.zillix.zlxnape.ZlxNapeSprite;
	import nape.phys.BodyType;
	import flash.utils.getTimer;
	import com.zillix.zlxnape.InteractionGroups;
	import com.zillix.zlxnape.CallbackTypes;
	import com.zillix.utils.ZMathUtils;
	import nape.geom.Vec2;
	/**
	 * ...
	 * @author zillix
	 */
	public class MessageOrb extends ZlxNapeSprite 
	{
		[Embed(source = "data/messageOrb.png")]	public var OrbSprite:Class;
		
		private var _index:int;
		
		public static const ORB_COOLDOWN:int = 5;
		
		private var _bubbleCount:int = 0;
		public static const BUBBLES_REQUIRED:int = 5;
		public var busy:Boolean = false;
		
		private var _glow:Glow;
		
		
		public function MessageOrb(X:Number, Y:Number, Context:BodyContext, Index:int)
		{
			super(X, Y);
			_index = Index;
			loadRotatedGraphic(OrbSprite, 32);
			createCircleBody(width / 2, Context, BodyType.KINEMATIC);
			_origOffset = Vec2.get(width / 2 , height / 2);
			//offset.x = width / 2;
			//offset.y = height / 2;
			makeFluid(100, 0);
			body.type = BodyType.KINEMATIC;
			fluidMask = InteractionGroups.BUBBLE;
			collisionMask = InteractionGroups.BUBBLE;
			addCbType(CallbackTypes.MESSAGE);
			
			PlayState.instance.attachGlow(this, 100);
			
		}
		
		override public function update() : void
		{
			super.update();
			
			alpha = .3 + _bubbleCount / BUBBLES_REQUIRED * .7;
			body.angularVel = ZMathUtils.toRadians(_bubbleCount / BUBBLES_REQUIRED * 720);
		}
		
		public function onTouchBubble(bubble:Bubble) : void
		{
			if (busy || bubble.isShrinking())
			{
				return;
			}
			
			bubble.onTouchAir();
			_bubbleCount++;
			if (_bubbleCount >= BUBBLES_REQUIRED)
			{
				displayMessage();
				_bubbleCount = 0;
			}
		}
		
		private function onMessageComplete() : void
		{
			busy = false;
			PlayState.instance.setActiveOrb(null);
		}
		
		public function displayMessage() : void
		{
			busy = true;
			var message:Vector.<PlayText> = getMessage(_index);
			PlayState.instance.queueText(message);
			PlayState.instance.setActiveOrb(this);
		}
		
		private function getMessage(index:int) : Vector.<PlayText>
		{
			var text:Vector.<PlayText> = new Vector.<PlayText>();
			switch (index)
			{
				
				/*case -1:
					PlayText.addText(text, "your breath gives you power here, child", -1, onMessageComplete);
					break;
				*/
				case 0:
					PlayText.addText(text, "your breath has power here, child", -1, onMessageComplete);
					break;
					
				case 1:
					PlayText.addText(text, "the core of a jelly is valuable", -1);
					PlayText.addText(text, "is that what you were sent here for?", -1);
					PlayText.addText(text, "if you bring one back, will they loosen your leash?", -1, onMessageComplete);
					
					break;
					
				case 2:
					PlayText.addText(text, "poor, beautiful creatures");
					PlayText.addText(text, "there are so few of them left", -1, null);
					PlayText.addText(text, "the one who came before you was not here to hunt", -1, onMessageComplete);
					
					
					break;
					
				case 3:
					PlayText.addText(text, "are you searching for him?");
					PlayText.addText(text, "what do you expect to find?", -1, onMessageComplete);
					
					break;
					
				case 4:
					PlayText.addText(text, "he came down here to find me");
					PlayText.addText(text, "he didn't realize how deep this goes", -1, onMessageComplete);
					
					break;
					
				case 5:
					PlayText.addText(text, "a place like this is dangerous for your kind");
					PlayText.addText(text, "though you come better prepared than he", -1, onMessageComplete);
					break;
					
				case 6:
					PlayText.addText(text, "is this what you seek?");
					PlayText.addText(text, "take it, and begone", -1, onMessageComplete);
					break;
					
				case 7:
					PlayText.addText(text, "your ties to the world hold you back");
					PlayText.addText(text, "[R]elease them, and be free", -1, 
					function() : void
					{
						PlayState.instance.rKey.visible = true;
						onMessageComplete();
					});
					break;
					
				case 8:
					PlayText.addText(text, "they guard his resting place");
					PlayText.addText(text, "they will never let a predator pass", -1, onMessageComplete);
					break;
					
					
				default:
					trace("Unhandled message!");
			}
			
		
			
			return text;
		}
		
	}
	
}