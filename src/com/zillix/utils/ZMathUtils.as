package com.zillix.utils
{
	import nape.geom.Vec2;
	
	/**
	 * ...
	 * @author zillix
	 */
	public class ZMathUtils
	{
		public static function toRadians(ang:Number):Number
		{
			return Math.PI * ang / 180.0;
		}
		
		public static function toDegrees(radians:Number): Number
		{
			return 180.0 / Math.PI * radians;
		}
		
		public static function getDistance(X:Number, Y:Number, A:Number, B:Number):Number
		{
			return Math.sqrt(Math.pow(X - A, 2) + Math.pow(Y - B, 2));
		}
		
		public static function rgbToHex(r:int, g:int, b:int, a:int = 255) : uint 
		{
			return a << 24 | r << 16 | g << 8 | b;
		}
		
		public static function getVector(degrees:Number, length:Number) : Vec2
		{
			var vec:Vec2 = Vec2.fromPolar(length, toRadians(degrees));
			return vec;
		}
		
		public static function randomBetween(low:Number, high:Number) : Number
		{
			return Math.random() * (high - low) + low;
		}
	}
	
}