package 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.geom.Point;
	import org.flixel.*;
	
	/**
	 * ...
	 * @author zillix
	 */
	public class Darkness extends FlxSprite
	{	
		[Embed(source = "data/darkmask.png")]	public var DarknessSprite:Class;
		
		public var backupFramePixels:BitmapData;
		public var backupPixels:BitmapData;
		public function Darkness(X:Number, Y:Number)
		{
			super(X, Y);
			//loadGraphic(DarknessSprite);
			makeGraphic(FlxG.width, FlxG.height, 0xff000000);
			scrollFactor = new FlxPoint(0, 0);
			
			backupPixels = this.pixels.clone();
			//offset.x = width / 2;
			blend = "multiply";
		}
		
		override public function update() : void
		{
			super.update();
			alpha = PlayState.instance.depthDarkness;
		}
		
		public function reDarken() : void
		{
			pixels.copyPixels(backupPixels, backupPixels.rect, new Point(0, 0));
			dirty = true;
		}
		
	}
	
}