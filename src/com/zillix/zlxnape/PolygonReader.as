package com.zillix.zlxnape
{
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import nape.phys.Body;
	import nape.shape.Polygon;
	import nape.shape.Shape;
	
	/**
	 * ...
	 * @author zillix
	 */
	public class PolygonReader 
	{
		// Each pixel is a [scale x scale] square body.
		public static const SIMPLE_SQUARE:uint = 1;
		// Similar to SIMPLE_SQUARE, but horizontally-adjacent squares get combined into one rectangle
		public static const SIMPLE_RECTANGLE_HORIZONTAL:uint = 2;
		// Same as SIMPLE_SQUARE, but ignores colors
		public static const SIMPLE_SINGLE_BODY:uint = 3;
		// Same as SIMPLE_SINGLE_BODY, but caches the pixel color for each shape
		public static const COLOR_SINGLE_BODY:uint = 4;
		// simple rectangle horizontal + single body
		public static const RECTANGLE_HORIZONTAL_SINGLE_BODY:uint = 5;
	
		
		private var _defaultScale:Number;
		function PolygonReader(defaultScale:Number )
		{
			_defaultScale = defaultScale;
		}
		
		public function readPolygon(ImageClass:Class, scale:Number = -1, mode:int = 0, center:Boolean = true, onlyColor:uint = 0x00000000) : BodyMap
		{
			if (scale <= 0)
			{
				scale = _defaultScale;
			}
			
			var processor:PixelProcessor = new PixelProcessor(scale, mode, center);
			
			var bitmapData:BitmapData = (new ImageClass).bitmapData;
			if (bitmapData != null)
			{
				var column:uint;
				var pixel:uint;
				var bitmapWidth:uint = bitmapData.width;
				var bitmapHeight:uint = bitmapData.height;
			
				var endIndex:int = bitmapHeight;
				var row:uint = 0;
				
				while(row < endIndex)
				{
					column = 0;
					while(column < bitmapWidth)
					{
						//Decide if this pixel/tile is solid (1) or not (0)
						pixel = bitmapData.getPixel32(column, row);
				
						// Skip this pixel if we're filtering just for one color, and it doesn't match that color
						if (onlyColor == 0 || pixel == onlyColor)
						{
							processor.processPixel(pixel, column, row, bitmapWidth, bitmapHeight);
						}
						column++;
					}
					if (row == endIndex)
					{
						break;
					}
					else
					{
						row++;
					}
				
				}
			}
			
			return processor.getBodyMap();
		}
		
	}
	
}