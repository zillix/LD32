package 
{
	import com.zillix.zlxnape.*;
	import com.zillix.zlxnape.PolygonReader;
	import com.zillix.zlxnape.CallbackTypes;
	import com.zillix.zlxnape.ZlxNapeSprite;
	import flash.display.BitmapData;
	import nape.phys.*;
	import nape.geom.*;
	import org.flixel.FlxPoint;
	
	/**
	 * ...
	 * @author zillix
	 */
	public class MapReader 
	{
		private var _state:PlayState;
		public static const MAP_COLOR:uint = 0xffA6916A; 
		
		public var worldWidth:Number = 0;
		public var worldHeight:Number = 0;
		
		public function MapReader(state:PlayState) : void
		{
			_state = state;
		}
		
		public function readMap(MapClass:Class, scale:int) : void
		{
			readTerrain(MapClass, scale);
			readPixels(MapClass, scale);
		}
		
		private function readTerrain(TerrainClass:Class, scale:int) : void
		{
			var polygonReader:PolygonReader = new PolygonReader(scale);
			var bodyMap:BodyMap = polygonReader.readPolygon(TerrainClass, -1, PolygonReader.SIMPLE_RECTANGLE_HORIZONTAL, false, MAP_COLOR);
			var body:Body = bodyMap.getBodyByIndex(0);
			var imgWidth:int = (new TerrainClass).bitmapData.width;
			var imgHeight:int = (new TerrainClass).bitmapData.height;
			worldWidth = imgWidth * scale;
			worldHeight = imgHeight * scale;
			body.allowMovement = false;
			body.allowRotation = false;
			body.setShapeMaterials(Material.wood());
			body.translateShapes(Vec2.weak(-worldWidth, -worldHeight));
			var terrain:ZlxNapeSprite = new ZlxNapeSprite(worldWidth / 2, worldHeight / 2);
			terrain.scale = new FlxPoint(scale, scale);
			terrain.loadBody(body, _state.bodyContext, worldWidth, worldHeight);
			terrain.loadGraphic(TerrainClass);
			terrain.offset = new FlxPoint(imgWidth / 2, imgHeight / 2);
			terrain.addCbType(CallbackTypes.GROUND);
			terrain.collisionMask = ~InteractionGroups.NO_COLLIDE;
			terrain.collisionGroup = InteractionGroups.TERRAIN;
			
			_state.terrainLayer.add(terrain);
			
			
			/*var terrainBack:FlxSprite = new FlxSprite(0, 0, TerrainBack);
			terrainBackLayer.add(terrainBack);
			terrainBack.scale = new FlxPoint(terrainScale, terrainScale);
			terrainBack.offset =  new FlxPoint(-imgWidth * 9.5, -imgHeight * 9.5);
			*/
		}
		
		private function readPixels(MapClass:Class, scale:int) : void
		{
			var bitmapData:BitmapData = (new MapClass).bitmapData;
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
						pixel = bitmapData.getPixel(column, row);
				
						processMapPixel(pixel, column, row, scale, bitmapWidth, bitmapHeight);
						
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
		}
		
		private static const INITIAL_PLAYER_SPAWN:uint = 0x02DA37;
		private static const TUBE_ANCHOR:uint = 0x0C6241;
		private static const PLANT_ANCHOR:uint = 0x0C2262;
		private static const FALL_PLANT_ANCHOR:uint = 0xDA02A7;
		private static const BIG_ROCK:uint = 0x571730;
		/*private static const MECH_SPAWN:uint = 0xC4181A; // 196 24 26
		private static const MECH_HIDE:uint = 0x2C18C4; // 44 24 196
		private static const MECH_IDLE:uint = 0x9D2DAF; // 157 45 175
		private static const MECH_FLY:uint = 0x5EEC81; // 94 236 129
		private static const PIXEL_CACHE:uint = 0x620C0D; // 98 12 13
		private static const MECH_IDLE_HIGH:uint = 0xFDD14D;// 253 209 77
		private static const TEXT_BEACON:uint = 0xF0C1F7;
		private static const TUTORIAL_SPAWN:uint = 0x02DA37;
		private static const BODY_PIT:uint = 0x160C62;
		private static const BLOCKADE:uint = 0x8D4399;
		private static const TUTORIAL_CLOSE:uint = 0x5EECEB;
		private static const ARROW_KEYS:uint = 0xEC5E60;
		private static const SPACE_BAR:uint = 0x9FAF2D;
		private static const SHIFT:uint = 0xAF5E2D;
		private static const DOUBLE_JUMP:uint = 0x1F5717;
		private static const SECRET_BLOCK:uint = 0x4D2142;
		private static const SECRET_BLOCK2:uint = 0x18C4C3;
		private static const SECRET_BACK:uint = 0xDA0205;
		private static const SECRET_BACK2:uint = 0x37214D;
		private static const SECRET_BACK3:uint = 0x6FC418;
		private static const PEDESTAL:uint = 0x375717;
		[Embed(source = "data/pixelCache.png")]	public var PixelCacheSprite:Class;
		[Embed(source = "data/blockade.png")]	public var BlockadeSprite:Class;
		[Embed(source = "data/arrowKeys.png")]	public var ArrowKeysSprite:Class;
		[Embed(source = "data/spaceImage.png")]	public var SpaceBarSprite:Class;
		[Embed(source = "data/zKey.png")]	public var ZKeySprite:Class;
		[Embed(source = "data/cKey.png")]	public var CKeySprite:Class;
		[Embed(source = "data/xKey.png")]	public var XKeySprite:Class;
		[Embed(source = "data/shiftImage.png")]	public var ShiftSprite:Class;
		[Embed(source = "data/doubleJump.png")]	public var DoubleJumpSprite:Class;
		[Embed(source = "data/secretBlockade.png")]	public var SecretBlockadeSprite:Class;
		[Embed(source = "data/secretBlockade2.png")]	public var SecretBlockadeSprite2:Class;
		[Embed(source = "data/pedestal.png")]	public var PedestalSprite:Class;*/
		
		private function processMapPixel(color:uint, column:int, row:int, scale:int, bitmapWidth:int, bitmapHeight:int) : void
		{
			var X:Number = column * scale;
			var Y:Number = row * scale;
			switch (color)
			{
				case INITIAL_PLAYER_SPAWN:
					_state.playerSpawn = new FlxPoint(X, Y);
					break;
					
				case TUBE_ANCHOR:
					_state.setupTube(X, Y);
					break;
					
				case PLANT_ANCHOR:
					_state.addPlant(X, Y, false);
					break;
					
				case FALL_PLANT_ANCHOR:
					_state.addPlant(X, Y, true);
					break;
					
				case BIG_ROCK:
					_state.addBigRock(X, Y);
					break;
			}
			
		}
		
	}
	
}