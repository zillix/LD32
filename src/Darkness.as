package 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.geom.Point;
	import org.flixel.*;
	import com.zillix.utils.ZMathUtils;
	
	/**
	 * ...
	 * @author zillix
	 */
	public class Darkness extends FlxSprite
	{	
		[Embed(source = "data/darkmask.png")]	public var DarknessSprite:Class;
		
		public var backupFramePixels:BitmapData;
		public var backupPixels:BitmapData;
		
		public var offsetAngle:Number = 0;
		public var ROTATION_SPEED:Number = 90;
		public var OFFSET_MAGNITUDE:Number = .1;
		public var savedAlpha:Number = 1;
		
		public function Darkness(X:Number, Y:Number, Color:uint)
		{
			super(X, Y);
			//loadGraphic(DarknessSprite);
			makeGraphic(FlxG.width, FlxG.height, Color);// 0xff000000);// 0xff172C47);//0xff000000);
			scrollFactor = new FlxPoint(0, 0);
			
			backupPixels = this.pixels.clone();
			//offset.x = width / 2;
			blend = "multiply";
		}
		
		override public function update() : void
		{
			super.update();
			
			if (!PlayState.instance.startedGame)
			{
				savedAlpha = 1;
			}
			else
			{
				if (savedAlpha > PlayState.instance.depthDarkness)
				{
					savedAlpha = Math.max(PlayState.instance.depthDarkness, savedAlpha - FlxG.elapsed);
				}
				else if (savedAlpha <= PlayState.instance.depthDarkness)
				{
					savedAlpha = Math.min(PlayState.instance.depthDarkness, savedAlpha + FlxG.elapsed);
				}
			}
			
			offsetAngle += FlxG.elapsed * ROTATION_SPEED;
			alpha = savedAlpha + Math.sin(ZMathUtils.toRadians(offsetAngle)) * OFFSET_MAGNITUDE;
			//trace("alpha: " + alpha + " saved: " + savedAlpha + " angle: " + offsetAngle);
		}
		
		public function reDarken() : void
		{
			pixels.copyPixels(backupPixels, backupPixels.rect, new Point(0, 0));
			dirty = true;
		}
		
	}
	
}