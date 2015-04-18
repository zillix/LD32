package com.zillix.zlxnape
{
	import nape.phys.BodyType;
	import nape.space.Space;
	/**
	 * Very simple visual effect.
	 * Creates a colored ZlxNapeSprite
	 * @author zillix
	 */
	public class ColorSprite extends ZlxNapeSprite 
	{
		function ColorSprite(X:Number, Y:Number, Color:uint) : void
		{
			super(X, Y);
			color = Color;
		}
		
		override public function createBody(Width:Number, Height:Number, bodyContext:BodyContext, bodyType:BodyType =  null, copyValues:Boolean = true) : void
		{
			super.createBody(Width, Height, bodyContext, bodyType, copyValues);
			makeGraphic(Width, Height, 0xff0000ff);
		}
	}
}