package com.zillix.zlxnape
{
	import nape.phys.BodyType;
	import nape.space.Space;
	import org.flixel.FlxPoint;
	/**
	 * Very simple visual effect.
	 * Creates a colored ZlxNapeSprite
	 * @author zillix
	 */
	public class ColorSprite extends ZlxNapeSprite 
	{
		private var myColor:uint = 0xff000000;
		function ColorSprite(X:Number, Y:Number, Color:uint) : void
		{
			super(X, Y);
			myColor = Color;
		}
		
		override public function createBody(Width:Number, Height:Number, bodyContext:BodyContext, bodyType:BodyType =  null, copyValues:Boolean = true, Scale:FlxPoint = null) : void
		{
			super.createBody(Width, Height, bodyContext, bodyType, copyValues);
			makeGraphic(Width, Height, myColor);
		}
	}
}