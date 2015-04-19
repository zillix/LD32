package 
{
	import com.zillix.zlxnape.BodyContext;
	import com.zillix.zlxnape.ZlxNapeSprite;
	import nape.phys.BodyType;
	import flash.utils.getTimer;
	import com.zillix.zlxnape.InteractionGroups;
	import com.zillix.zlxnape.CallbackTypes;
	import com.zillix.utils.ZMathUtils;
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
		public static const BUBBLES_REQUIRED:int = 7;
		public var busy:Boolean = false;
		
		
		
		public function MessageOrb(X:Number, Y:Number, Context:BodyContext, Index:int)
		{
			super(X, Y);
			_index = Index;
			loadRotatedGraphic(OrbSprite, 32);
			createCircleBody(width / 2, Context, BodyType.KINEMATIC);
			makeFluid(100, 0);
			body.type = BodyType.KINEMATIC;
			fluidMask = InteractionGroups.BUBBLE;
			collisionMask = InteractionGroups.BUBBLE;
			addCbType(CallbackTypes.MESSAGE);
			
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
				case 0:
					PlayText.addText(text, "your breath gives you power here, child", -1, onMessageComplete);
					break;
					
				case 1:
					PlayText.addText(text, "poor, beautiful creatures");
					PlayText.addText(text, "deadly to touch, but crumble at a breeze", -1);
					
					break;
					
				case 2:
					PlayText.addText(text, "there are so few of them left", -1);
					PlayText.addText(text, "they were hunted long ago, by people like you", -1, onMessageComplete);
					
					break;
					
				case 3:
					PlayText.addText(text, "are you searching for him, or for what he sought?");
					PlayText.addText(text, "they're both long gone, by now", -1, onMessageComplete);
					
					break;
					
				case 4:
					PlayText.addText(text, "he followed down here when he spotted me");
					PlayText.addText(text, "he didn't realize just how deep this goes", -1, onMessageComplete);
					
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
					PlayText.addText(text, "release them, and be [F]ree", -1, onMessageComplete);
					break;
					
				case 7:
					if (PlayState.instance.jellyKilled)
					{
						PlayText.addText(text, "beyond lies the den");
						PlayText.addText(text, "you have shown yourself to be a predator");
						PlayText.addText(text, "you are not welcome");
					}
					else
					{
						PlayText.addText(text, "this is not the best use of breath");
					}
					
				default:
					trace("Unhandled message!");
			}
			
		
			
			return text;
		}
		
	}
	
}