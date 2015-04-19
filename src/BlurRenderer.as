package 
{
	import com.zillix.zlxnape.ZlxNapeSprite;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.filters.BlurFilter;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import org.flixel.*;
	import org.flixel.FlxGroup;
	import org.flixel.FlxObject;
	import org.flixel.FlxPoint;
	import org.flixel.FlxSprite;
	import flash.utils.getTimer;
	import com.zillix.utils.ZMathUtils;
	
	/**
	 * This fluid rendering implementation borrowed somewhat from here:
	 * http://monsterbraininc.com/2013/10/liquid-simulation-in-as3-nape/
	 * @author zillix
	 */
	public class BlurRenderer  extends FlxSprite
	{
		private var transMatrix:Matrix;
		
		private var drawCanvasData:BitmapData;
		private var drawCanvasDataCopy:BitmapData;
		
		private var sourceSprite:Sprite;
		
		protected var blurFilter:BlurFilter = new BlurFilter(8, 8, 6);
		private var group:Array;
		
		private var _nextDrawTime:int = 0;
		private static const DRAW_FREQ:Number = .02;
		
		private var thresholdColor:uint;
		
		private static var zeroPoint:Point = new Point(0, 0);
		private var minPoint:Point = new Point();
		private var maxPoint:Point = new Point();
		private var lastMinPoint:Point = new Point();
		private var lastMaxPoint:Point = new Point();
		private var updateRect:Rectangle = new Rectangle();
		private var destPoint:Point = new Point(0, 0);
		
		
		public function BlurRenderer(ScreenWidth:Number, ScreenHeight:Number, Group:Array, SourceSprite:Sprite, color:uint = 0xffffff)
		{
			super(0, 0);
			
			sourceSprite = SourceSprite;
			thresholdColor = color;
			
			scrollFactor = new FlxPoint(0, 0);
			
			drawCanvasData = new BitmapData(ScreenWidth, ScreenHeight, false, 0x00FFFFFF);
			drawCanvasDataCopy = new BitmapData(ScreenWidth, ScreenHeight, true, 0x00FFFFFF);
			
			transMatrix = new Matrix();
			
			group = Group;
		}
		
		override public function draw() : void
		{
			var time:int = getTimer();
			
			if (group.length == 0)
			{
				return;
			}
			
			var camera:FlxCamera = FlxG.camera;
			if (time > _nextDrawTime)
			{
				_nextDrawTime = time + 1000 * DRAW_FREQ;
			
				drawCanvasData.fillRect(drawCanvasData.rect, 0x00000000);
				
				// Reset the update rectangle
				minPoint.x = drawCanvasData.width;
				minPoint.y = drawCanvasData.height;
				maxPoint.x = 0;
				maxPoint.y = 0;
				
				//var time:int = getTimer();
				
				for (var i:int = 0; i < group.length; i++)
				{
					var member:FlxSprite = group[i] as FlxSprite;
					if (!member || !member.active)
					{
						continue;
					}
					var xPos:int = member.x - camera.scroll.x;
						var yPos:int = member.y - camera.scroll.y;
						
					var buffer:int = 20;
					var scale:Number = member.scale.x;
					if (scale > 0
						&& xPos >= -buffer && xPos < drawCanvasData.width + buffer
						&& yPos >= -buffer && yPos < drawCanvasData.height + buffer)
					{
						
						minPoint.x = Math.min(minPoint.x, xPos - buffer); 
						minPoint.y = Math.min(minPoint.y, yPos - buffer);
						maxPoint.x = Math.max(maxPoint.x, xPos + buffer); 
						maxPoint.y = Math.max(maxPoint.y, yPos + buffer);
					
					
						
						transMatrix.scale(scale, scale);
						transMatrix.rotate(ZMathUtils.toRadians(member.angle));
						
						transMatrix.tx = xPos;
						transMatrix.ty = yPos;
						drawCanvasData.draw(sourceSprite, transMatrix);
						transMatrix.rotate(-ZMathUtils.toRadians(member.angle));
						transMatrix.scale(1 / scale, 1 / scale);
					}
					
				}
				
				//trace("Collect: " + (getTimer() - time));
				
				if (maxPoint.x - minPoint.x <= 0)
				{
					return;
				}
				
				//time = getTimer();
				
				destPoint.x = Math.min(minPoint.x, lastMinPoint.x);
				destPoint.y = Math.min(minPoint.y, lastMinPoint.y);
				updateRect.x = destPoint.x;
				updateRect.y = destPoint.y;
				updateRect.width = Math.max(maxPoint.x, lastMaxPoint.x) - updateRect.x;
				updateRect.height =  Math.max(maxPoint.y, lastMaxPoint.y) - updateRect.y;
				
				drawCanvasData.applyFilter(drawCanvasData, updateRect, destPoint, blurFilter);
				//trace("Blur : " + (getTimer() - time));
				//time = getTimer();
				drawCanvasDataCopy.fillRect(updateRect, 0x00000000);
				drawCanvasDataCopy.threshold(drawCanvasData,updateRect, destPoint, ">", 0XFF2d2d2d, 0xFF000000 | thresholdColor, 0xFFFFFFFF, false);
				
				lastMaxPoint.x = maxPoint.x;
				lastMaxPoint.y = maxPoint.y;
				lastMinPoint.x = minPoint.x;
				lastMinPoint.y = minPoint.y;
				
				//trace("Threshold: " + (getTimer() - time));
				/*
				drawCanvasData.applyFilter(drawCanvasData, drawCanvasData.rect, zeroPoint, blurFilter);
				//drawCanvasDataCopy.copyPixels(drawCanvasData, drawCanvasData.rect, new Point(0, 0));
				drawCanvasDataCopy.fillRect(drawCanvasData.rect, 0x00000000);
				//drawCanvasDataCopy.threshold(drawCanvasData, drawCanvasData.rect, zeroPoint, ">", 0XFF2b2b2b, 0x55000000 | thresholdColor, 0xFFFFFFFF, false);
				//drawCanvasDataCopy.threshold(drawCanvasData, drawCanvasData.rect, zeroPoint, ">", 0XFF2c2c2c, 0xBB000000 | thresholdColor, 0xFFFFFFFF, false);
				drawCanvasDataCopy.threshold(drawCanvasData, drawCanvasData.rect, zeroPoint, ">", 0XFF2d2d2d, 0xFF000000 | thresholdColor, 0xFFFFFFFF, false);
				*/
			}
			
			//time = getTimer();
			camera.buffer.draw(drawCanvasDataCopy,_matrix,null,blend,null,antialiasing);
			//trace("Render: " + (getTimer() - time));
			
			
		}
	}
	
}