package com.zillix.zlxnape 
{
	import nape.phys.Material;
	import nape.space.Space;
	import flash.display.BitmapData;
	import nape.geom.Vec2List;
	import nape.phys.BodyType;
	import nape.phys.Body;
	import nape.shape.Shape;
	import nape.shape.ShapeIterator;
	import nape.geom.Vec2;
	import org.flixel.*;
	/**
	 * ...
	 * @author zillix
	 */
	public class ImageReaderSprite extends ZlxNapeSprite 
	{
		protected var _polygonReader:PolygonReader;
		protected var _bodyMap:BodyMap;
		public var explodeDimensions:Number;
		public var pixelOmitFrequency:int = 1; // raise this number to make it drop less
		
		public function ImageReaderSprite(X:Number, Y:Number)
		{
			super(X, Y);
			explodeDimensions = PlayState.PIXEL_WIDTH;
		}
		
		public function readImage(ImageClass:Class, space:Space, pixelScale:int, mode:int = -1, onlyColor:uint = 0) : void
		{
			if (mode < 0)
			{
				mode = PolygonReader.COLOR_SINGLE_BODY;
			}
			_polygonReader = new PolygonReader(pixelScale);
			_bodyMap = _polygonReader.readPolygon(ImageClass ,-1, mode, false, onlyColor);
			
			// NOTE: this is pretty wasteful of resources
			var bitmapData:BitmapData = (new ImageClass).bitmapData;
			var imageWidth:int = bitmapData.width;
			var imageHeight:int = bitmapData.height;
			offset = new FlxPoint(imageWidth / 2, imageHeight / 2);
			
			var body:Body = _bodyMap.getBodyByIndex();
			body.type = BodyType.KINEMATIC;
			body.translateShapes(Vec2.weak(-imageWidth *pixelScale / 2, -imageHeight * pixelScale / 2));
			loadBody(body, space,0, 0);
		}
		
		public function loadScaledGraphic(ImageClass:Class, pixelScale:Number, animated:Boolean = false, reverse:Boolean = false, spriteWidth:Number = 0, spriteHeight:Number = 0) : void
		{
			super.loadGraphic(ImageClass, animated, reverse, spriteWidth, spriteHeight);
			var imageWidth:int = this.width;
			var imageHeight:int = this.height;
			this.scale.x = pixelScale;
			this.scale.y = pixelScale;
			_defaultScale = pixelScale;
			offset = new FlxPoint(imageWidth / 2, imageHeight / 2);
		}
		
		public function explode() : void
		{
			if (shouldKillOnExplosion)
			{
				kill();
			}
			var shape:Shape;
			var iterator:ShapeIterator = body.shapes.iterator();
			var bodyCOM:Vec2 = body.position;
			var worldVerts:Vec2List;
			var comVector:Vec2 = Vec2.get();
			var tangentVector:Vec2 = Vec2.get();
			var velocityVector:Vec2 = Vec2.get();
			var box:Absorbable;
			var explodeSpeed:Number = 100;
			var index:int = 0;
			while (iterator.hasNext())
			{
				shape = iterator.next();
				//var shapeColor:uint = 
				worldVerts = shape.castPolygon.worldVerts;
				comVector.set(shape.worldCOM.sub(bodyCOM, true));
				if (comVector.length > 0)
				{
					velocityVector.set(comVector.copy(true).normalise().mul(explodeSpeed, true));
				}
				if (body.angularVel != 0)
				{
					tangentVector = comVector.perp();
					if (body.angularVel < 0)
					{
						// Point it the other way
						tangentVector.length = -1;
					}
					velocityVector.addeq(tangentVector.normalise().mul(body.angularVel * comVector.length))
				}
				var color:uint = _bodyMap.shapeColors[index];
				box = PlayState.instance.spawnBox(worldVerts.at(0).x, worldVerts.at(0).y, explodeDimensions, angle, color);
				box.body.velocity.set(velocityVector);
				box.collisionGroup = InteractionGroups.ENEMY_ATTACK;
			
				if (PlayState.instance.DEBUG)
				{
					box.body.setShapeMaterials(Material.sand());
					box.body.rotation = Math.random() * 1 - .5;
				}
				
				
				if (index % pixelOmitFrequency != 0)
				{
					box.startAbsorb();
				}
				index++;
			}
		
			comVector.dispose();
			tangentVector.dispose();
			velocityVector.dispose();
		}
		
		protected function get shouldKillOnExplosion() : Boolean { return true; }
	}

}