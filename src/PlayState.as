package
{
	import com.zillix.zlxnape.BodyContext;
	import com.zillix.zlxnape.BodyRegistry;
	import com.zillix.zlxnape.ColorSprite;
	import com.zillix.zlxnape.ConnectedPixelGroup;
	import com.zillix.zlxnape.demos.ColoredBodyDemo;
	import com.zillix.zlxnape.demos.ConnectedPixelGroupDemo;
	import com.zillix.zlxnape.demos.PolygonReaderDemo;
	import com.zillix.zlxnape.demos.SpriteChainDemo;
	import com.zillix.zlxnape.demos.TentacleDemo;
	import com.zillix.zlxnape.demos.ZlxNapeDemo;
	import com.zillix.zlxnape.ZlxNapeSprite;
	
	import com.zillix.utils.ZGroupUtils;
	
	import adobe.utils.CustomActions;
	
	import flash.display.ColorCorrection;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.ui.Mouse;
	import flash.utils.Dictionary;
	import flash.utils.ByteArray;
	
	import org.flixel.*;
	import org.flixel.system.FlxTile;
	
	import nape.callbacks.InteractionCallback;
	import nape.callbacks.InteractionListener;
	import nape.callbacks.CbEvent;
	import nape.callbacks.InteractionType;
	import nape.dynamics.CollisionArbiter;
	import nape.geom.*;
	import nape.phys.*;
	import nape.space.*;
	import nape.util.*;
	
	import flash.utils.getTimer;
	
	

	public class PlayState extends FlxState
	{
		[Embed(source = "data/map1.png")]	public var Map1:Class;
		
		public static var instance:PlayState;
		
		public var player:Player;
		public var playerFollower:PlayerFollower;
		public var water:Water;
		
		public var space:Space;
		public var bodyContext:BodyContext;
		public var bodyRegistry:BodyRegistry;
		
		public static var DEBUG:Boolean = true;
		public static var DEBUG_DRAW:Boolean = false;
		public static var debug:Debug;
		public static const PIXEL_WIDTH:int = 20;
		
		public var mapReader:MapReader;
		
		
		public var terrainLayer:FlxGroup = new FlxGroup();
		public var bubbleLayer:FlxGroup = new FlxGroup();
		private var tubeLayer:FlxGroup = new FlxGroup();
		private var plantLayer:FlxGroup = new FlxGroup();
		private var rockLayer:FlxGroup = new FlxGroup();
		private var hudLayer:FlxGroup = new FlxGroup();
		
		private var hud:Hud;
		
		public static const GRAVITY:Number = 200;
		public static const FRAME_RATE :Number = 1 / 30;
		
		public var fluidRenderer:FluidRenderer;
		
		public static const CLEAN_TIME:Number = 1;
		private var _nextCleanTime:Number = 0;
		
		// Things mapReader sets
		public var playerSpawn:FlxPoint = new FlxPoint();
		
		override public function create():void
		{
			instance = this;
			FlxG.bgColor = 0xffdddddd;
			
			add(terrainLayer);
			add(bubbleLayer);
			add(tubeLayer);
			add(plantLayer);
			add(rockLayer);
			
			add(hudLayer);
			
			hud = new Hud();
			hudLayer.add(hud);
			
			fluidRenderer = new FluidRenderer(FlxG.width, FlxG.height, bubbleLayer);
			add(fluidRenderer);
			fluidRenderer.alpha = .5;
			
			space = new Space(new Vec2(0, GRAVITY));
			bodyRegistry = new BodyRegistry();
			bodyContext = new BodyContext(space, bodyRegistry);
			
			player = new Player(0, 0, bodyContext);
			add(player);
			
			
			
			mapReader = new MapReader(this);
			mapReader.readMap(Map1, PIXEL_WIDTH);
			
			player.setPosition(playerSpawn.x, playerSpawn.y);
			
			for each (var obj:ZlxNapeSprite in tubeLayer.members)
			{
				if (obj is BreathingTube)
				{
					(obj as BreathingTube).init();
				}
			}
			
			water = new Water(100, 0, mapReader.worldHeight, mapReader.worldHeight, bodyContext);
			add(water);
			
			FlxG.camera.setBounds(0, 0, mapReader.worldWidth, mapReader.worldHeight);
			playerFollower = new PlayerFollower(player.x, player.y, player);
			add(playerFollower);
			FlxG.camera.follow(playerFollower);
			
			debug = new BitmapDebug(mapReader.worldWidth, mapReader.worldHeight, 0xdd000000, true );
			FlxG.stage.addChild(debug.display);
			
		}
		
		override public function update():void
		{
			space.step(FRAME_RATE, 5, 3);
			super.update();	
			
			if (DEBUG)
			{
				if (DEBUG_DRAW)
				{
					debug.clear();
					debug.display.x = -FlxG.camera.scroll.x;
					debug.display.y = -FlxG.camera.scroll.y;
					debug.draw(space);
					debug.flush();
				}
				
				if (FlxG.keys.justPressed("P"))
				{
					DEBUG_DRAW = !DEBUG_DRAW;
					if (!DEBUG_DRAW)
					{
						debug.clear();
						debug.flush();
					}
				}
			}
			
			var time:int = getTimer();
			if (time > _nextCleanTime)
			{
				_nextCleanTime = time + CLEAN_TIME * 1000;
				ZGroupUtils .cleanGroup(bubbleLayer);
			}
		}
		
		public function setupTube(X:Number, Y:Number) : void
		{
			var tube:BreathingTube = new BreathingTube(X, Y, tubeLayer, player, bodyContext);
			tubeLayer.add(tube);
		}
		
		public function severTube() : void
		{
			for each (var tube:ZlxNapeSprite in tubeLayer.members)
			{
				if (tube is BreathingTube)
				{
					(tube as BreathingTube).sever();
				}
			}
		}
		
		public function addPlant(X:Number, Y:Number, Fall:Boolean) : void
		{
			var plant:Plant = new Plant(X, Y, plantLayer, bodyContext, Math.random() * 3 + 2, Math.random() * 3 + 4, Fall);
			plantLayer.add(plant);
		}
		
		public function addBigRock(X:Number, Y:Number) : void
		{
			const ROCK_COLOR:uint = 0xff571730;
			var rock:ColorSprite = new ColorSprite(X, Y, ROCK_COLOR);
			rock.createBody(100, 40, bodyContext);
			rock.setMaterial(new Material(1, 1, 1, 3.3, .001));
			rockLayer.add(rock);
			
		}
	}
}