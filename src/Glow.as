package 
{
	import org.flixel.*;
	import org.flixel.FlxSprite;
	
	/**
	 * ...
	 * @author zillix
	 */
	public class Glow extends FlxSprite
	{
		[Embed(source = "data/gradient96.png")]	public var GlowMask:Class;
		
		public var darkness:FlxSprite;
		public var target:FlxSprite;
		private var radius:Number;
		
		public static const WIDTH:Number = 100;
		
		public function Glow(X:Number, Y:Number, Dark:FlxSprite, Target:FlxSprite, Radius:Number)
		{
			super(X, Y, GlowMask);
			darkness = Dark;
			//offset.x = width / 2;
			//==offset.y = width / 2;
			target = Target;
			setRadius(Radius);
			
		}
		
		override public function update() : void
		{
			super.update();
			x = target.x + target.width/2;
			y = target.y + target.height / 2;
			
			if (!target.alive)
			{
				kill();
			}
			
		}
		
		
		public function setRadius(rad:Number) : void
		{
			radius = rad;
			scale.x = scale.y =  radius / WIDTH;
		}
		
		override public function draw():void 
		{
			/*var screenXY:FlxPoint = getScreenXY();
			var darknessScreenXY:FlxPoint = darkness.getScreenXY();
			var stampXY:FlxPoint = new FlxPoint(screenXY.x - (darknessScreenXY.x - darkness.width / 2) - this.width / 2,
						screenXY.y - (darknessScreenXY.y) - this.height / 2);
			darkness.stamp(this,
						stampXY.x, stampXY.y);*/
			PlayState.instance.blueColor.stamp(this, x - width / 2 - FlxG.camera.scroll.x, y - height / 2 - FlxG.camera.scroll.y);
					
 			darkness.stamp(this, x - width / 2 - FlxG.camera.scroll.x, y - height / 2 - FlxG.camera.scroll.y);
		}
	}
	
}