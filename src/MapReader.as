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
			body.type = BodyType.STATIC;
			
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
		private static const DRAPE_PLANT_ANCHOR:uint = 0x5EB8EC;
		private static const BIG_ROCK:uint = 0x571730;
		private static const JELLYFISH:uint = 0x4DFDFC;
		private static const AIR_POCKET:uint = 0xFD8F4D;
		private static const AIR_ZONE_END:uint = 0x1844C4;
		private static const AIR_ZONE_START:uint = 0xE54DFD;
		private static const TRAP_DOOR:uint = 0xA6FD4D;;
		private static const SMALL_ROCK:uint = 0x028BDA;
		private static const TINY_PLANT:uint = 0xE8FD4D;
		private static const ONE_WAY_PLATFORM:uint = 0x17620C;
		private static const SHRINE:uint = 0x994364;
		public static const TOP_RIGHT_ROUND_TERRAIN:uint = 0xAFC418;
		private static const MESSAGE_ORB:uint = 0x8E70BA;
		private static const SUPER_JELLY:uint = 0x4DFDBA;
		private static const BLOCKER_JELLY:uint = 0x70DAB2;
		private static const JELLY_MIN_X:uint = 0xF1F7C1;
		private static const DEAD_BODY:uint = 0x1E1757;
		
		
		private static var airStartPoint:FlxPoint = new FlxPoint();
		
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
					_state.addPlant(X, Y, Plant.RISE_PLANT );
					break;
					
				case FALL_PLANT_ANCHOR:
					_state.addPlant(X, Y, Plant.FALL_PLANT);
					break;
					
				case TINY_PLANT:
					_state.addPlant(X, Y, Plant.TINY_PLANT);
					break;
					
				case DRAPE_PLANT_ANCHOR:
					_state.addPlant(X, Y, Plant.DRAPE_PLANT);
					break;
					
				case BIG_ROCK:
					_state.addBigRock(X, Y);
					break;
					
				case SMALL_ROCK:
					_state.addSmallRock(X, Y);
					break;
					
				case JELLYFISH:
					_state.addJellyfish(X, Y);
					break;
					
				case AIR_POCKET:
					_state.addAirPocket(X, Y);
					break;
					
				case AIR_ZONE_START:
					airStartPoint = new FlxPoint(X, Y);
					break;
					
				case AIR_ZONE_END:
					_state.addAirZone(airStartPoint, new FlxPoint(X, Y));
					break;
					
				case TRAP_DOOR:
					_state.addTrapDoor(X, Y);
					break;
					
				case ONE_WAY_PLATFORM:
					_state.addOneWayPlatform(X, Y);
					break;
					
				case SHRINE:
					_state.addShrine(X, Y);
					break;
					
				case TOP_RIGHT_ROUND_TERRAIN:
					_state.addRoundCorner(X, Y, TOP_RIGHT_ROUND_TERRAIN);
					break;
					
				case MESSAGE_ORB:
					_state.addMessageOrb(X, Y);
					break;
					
				case SUPER_JELLY:
					_state.addSuperJelly(X, Y);
					break;
					
				case BLOCKER_JELLY:
					_state.addBlockerJellyPoint(X, Y);
					break;
				case JELLY_MIN_X:
					_state.jellyMinX = X;
					break;
					
				case DEAD_BODY:
					_state.addDeadBody(X, Y);
					break;
			}
			
		}
		
	}
	
}