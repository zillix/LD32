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
	
	/**
	 * This fluid rendering implementation borrowed somewhat from here:
	 * http://monsterbraininc.com/2013/10/liquid-simulation-in-as3-nape/
	 * @author zillix
	 */
	public class FluidRenderer  extends FlxSprite
	{
		private var transMatrix:Matrix;
		
		private var drawCanvasData:BitmapData;
		private var drawCanvasDataCopy:BitmapData;
		
		private var drawCanvas:Bitmap;
		private var drawCanvas2:Bitmap;
		
		private var circleSprite:Sprite;
		
		private var blurFilter:BlurFilter = new BlurFilter(15, 15, 3);
		
		private var group:FlxGroup;
		
		private static const CIRCLE_RADIUS:Number = 10;
		
		
		public function FluidRenderer(ScreenWidth:Number, ScreenHeight:Number, Group:FlxGroup)
		{
			super(0, 0);
			
			scrollFactor = new FlxPoint(0, 0);
			
			drawCanvasData = new BitmapData(ScreenWidth, ScreenHeight, false, 0xFFFFFFFF);
			drawCanvasDataCopy = new BitmapData(ScreenWidth, ScreenHeight, true, 0xFFFFFFFF);
			
			drawCanvas = new Bitmap(drawCanvasData);
			drawCanvas2 = new Bitmap(drawCanvasDataCopy);
			
			transMatrix = new Matrix();
			//transMatrix.tx = 100;
			//transMatrix.ty = 100;
			
			circleSprite = new Sprite();
			circleSprite.graphics.beginFill(0xFF0000);
			circleSprite.graphics.drawCircle(0, 0, CIRCLE_RADIUS);
			circleSprite.graphics.endFill();
			
			drawCanvasData.draw(circleSprite, transMatrix);
			
			group = Group;
		}
		
		public function getBitmap() : Bitmap
		{
			return drawCanvas2;
		}
		
		override public function draw() : void
		{
			var camera:FlxCamera = FlxG.camera;
			
			drawCanvasData.fillRect(drawCanvasData.rect,0x00110000);
			for (var i:int = 0; i < group.members.length; i++)
			{
				var member:Bubble = group.members[i] as Bubble;
				if (!member)
				{
					continue;
				}
				
				var xPos:int = member.x - camera.scroll.x;
				var yPos:int = member.y - camera.scroll.y;
				var scale:Number = member.radius / CIRCLE_RADIUS;
				var fudgeFactor:int = 55;
				if (scale > 0
					&& xPos >= -fudgeFactor && xPos < drawCanvas.width + fudgeFactor
					&& yPos >= -fudgeFactor && yPos < drawCanvas.height + fudgeFactor)
				{
					transMatrix.scale(scale, scale);
					transMatrix.tx = xPos;
					transMatrix.ty = yPos;
					drawCanvasData.draw(circleSprite, transMatrix);
					transMatrix.scale(1 / scale, 1 / scale);
				}
				
			}
			
			var point:Point = new Point();
			drawCanvasData.applyFilter(drawCanvasData, drawCanvasData.rect, new Point(0, 0), blurFilter);
			drawCanvasDataCopy.fillRect(drawCanvasData.rect,0x66FF0000);
			drawCanvasDataCopy.threshold(drawCanvasData, drawCanvasData.rect, point, ">", 0XFF2b2b2b, 0x55FFFFFF, 0xFFFFFFFF, false);
			drawCanvasDataCopy.threshold(drawCanvasData, drawCanvasData.rect, point, ">", 0XFF2c2c2c, 0xBBFFFFFF, 0xFFFFFFFF, false);
			drawCanvasDataCopy.threshold(drawCanvasData, drawCanvasData.rect, point, ">", 0XFF2d2d2d, 0xFFFFFFFF, 0xFFFFFFFF, false);
			
			camera.buffer.draw(drawCanvasDataCopy,_matrix,null,blend,null,antialiasing);
		}
	}
	
}