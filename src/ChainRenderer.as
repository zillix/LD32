package 
{
	import com.zillix.zlxnape.ZlxNapeSprite;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.filters.BlurFilter;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import org.flixel.*;
	import org.flixel.FlxGroup;
	import org.flixel.FlxObject;
	import org.flixel.FlxPoint;
	import org.flixel.FlxSprite;
	import flash.utils.getTimer;
	
	public class ChainRenderer  extends BlurRenderer
	{
		public function ChainRenderer(ScreenWidth:Number, ScreenHeight:Number, Group:Array, SegmentWidth:Number, SegmentHeight:Number, SegmentColor:uint)
		{
			var segmentSprite:Sprite = new Sprite();
			segmentSprite.graphics.beginFill(0xFF0000);
			segmentSprite.graphics.drawRect(0, 0, SegmentWidth, SegmentHeight);
			segmentSprite.graphics.endFill();
			super(ScreenWidth, ScreenHeight, Group, segmentSprite, SegmentColor); 
			
			blurFilter =  new BlurFilter(8, 8, 6);
		}
	}
	
}