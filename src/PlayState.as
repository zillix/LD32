package
{
	import com.zillix.zlxnape.BodyContext;
	import com.zillix.zlxnape.BodyRegistry;
	import com.zillix.zlxnape.*;
	import com.zillix.zlxnape.ConnectedPixelGroup;
	import com.zillix.zlxnape.demos.ColoredBodyDemo;
	import com.zillix.zlxnape.demos.ConnectedPixelGroupDemo;
	import com.zillix.zlxnape.demos.PolygonReaderDemo;
	import com.zillix.zlxnape.demos.SpriteChainDemo;
	import com.zillix.zlxnape.demos.TentacleDemo;
	import com.zillix.zlxnape.demos.ZlxNapeDemo;
	import com.zillix.zlxnape.ZlxNapeSprite;
	import flash.text.engine.BreakOpportunity;
	import nape.callbacks.PreCallback;
	import nape.callbacks.PreFlag;
	import nape.callbacks.PreListener;
	
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
		[Embed(source = "data/map1small.png")]	public var Map1:Class;
		
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
		public var tubeLayer:FlxGroup = new FlxGroup();
		public var plantLayer:FlxGroup = new FlxGroup();
		private var rockLayer:FlxGroup = new FlxGroup();
		private var hudLayer:FlxGroup = new FlxGroup();
		public var enemyLayer:FlxGroup = new FlxGroup();
		private var enemyNodeLayer:FlxGroup = new FlxGroup();
		public var darkLayer:FlxGroup = new FlxGroup();
		public var glowLayer:FlxGroup = new FlxGroup();
		public var airZoneLayer:FlxGroup = new FlxGroup();
		
		public var segmentLayer:FlxGroup = new FlxGroup();
		
		private var darkness:Darkness;
		public var hud:Hud;
		
		public static const GRAVITY:Number = 200;
		public static const FRAME_RATE :Number = 1 / 30;
		
		public var bubbleRenderer:FluidRenderer;
		
		public static const CLEAN_TIME:Number = 1;
		private var _nextCleanTime:Number = 0;
		
		// Things mapReader sets
		public var playerSpawn:FlxPoint = new FlxPoint();
		
		public var depthDarkness:Number = 0;
		public static const MAX_DARKNESS_OFFSET:Number = 200;
		public var maxDarknessY:Number = 1;
		
		public var paused:Boolean = false;
		
		override public function create():void
		{
			instance = this;
			FlxG.bgColor = 0xffA3948B;
			
			
			bubbleRenderer = new FluidRenderer(FlxG.width, FlxG.height, bubbleLayer.members);
			add(bubbleRenderer);
			//fluidRenderer.alpha = .5;
			add(airZoneLayer);
			
			add(glowLayer);
			add(terrainLayer);
			add(bubbleLayer);
			add(tubeLayer);
			add(plantLayer);
			add(rockLayer);
			add(segmentLayer);
			add(enemyNodeLayer);
			add(enemyLayer);
			
			
			add(darkLayer);
			
			add(hudLayer);
			
			
			
			hud = new Hud();
			hudLayer.add(hud);
			
			
			space = new Space(new Vec2(0, GRAVITY));
			bodyRegistry = new BodyRegistry();
			bodyContext = new BodyContext(space, bodyRegistry);
			
			
			darkness = new Darkness(0, 0);
			darkLayer.add(darkness);
			
			player = new Player(0, 0, bodyContext);
			add(player);
			
			mapReader = new MapReader(this);
			mapReader.readMap(Map1, PIXEL_WIDTH);
			maxDarknessY = mapReader.worldHeight - MAX_DARKNESS_OFFSET;
			
			player.setPosition(playerSpawn.x, playerSpawn.y);
			
			for each (var obj:FlxSprite in tubeLayer.members)
			{
				if (obj is BreathingTube)
				{
					(obj as BreathingTube).init();
				}
			}
			
			water = new Water(0, 0, mapReader.worldHeight, mapReader.worldHeight, bodyContext);
			//add(water);
			water.visible = false;
			
			FlxG.camera.setBounds(0, 0, mapReader.worldWidth, mapReader.worldHeight);
			playerFollower = new PlayerFollower(player.x, player.y, player);
			add(playerFollower);
			FlxG.camera.follow(playerFollower);
			
			debug = new BitmapDebug(mapReader.worldWidth, mapReader.worldHeight, 0xdd000000, true );
			FlxG.stage.addChild(debug.display);
			
			setUpListeners();
			
			var text:Vector.<PlayText> = new Vector.<PlayText>();
			addText(text, "be very careful down here");
			addText(text, "we need to collect the orbs");
			addText(text, "we can extend the rope whenever you return an orb");
			queueText(text);
			
		}
		
		private function setUpListeners() : void
		{
			var touchPickup:InteractionListener = new InteractionListener(CbEvent.BEGIN, InteractionType.COLLISION, CallbackTypes.PLAYER, CallbackTypes.PICKUP, playerTouchPickup, 2);
			space.listeners.add(touchPickup);
			
			var touchEnemy:PreListener = new PreListener(InteractionType.COLLISION,
				CallbackTypes.PLAYER,
				CallbackTypes.ENEMY,
				playerTouchEnemy)
			space.listeners.add(touchEnemy);
			
			var playerTouchAir:InteractionListener = new InteractionListener(CbEvent.BEGIN, InteractionType.FLUID, CallbackTypes.PLAYER, CallbackTypes.AIR, onPlayerTouchAir, 2);
			space.listeners.add(playerTouchAir);
			
			var playerStopTouchAir:InteractionListener = new InteractionListener(CbEvent.END, InteractionType.FLUID, CallbackTypes.PLAYER, CallbackTypes.AIR, onPlayerStopTouchAir, 2);
			space.listeners.add(playerStopTouchAir);
			
			var bubbleTouchAir:InteractionListener = new InteractionListener(CbEvent.BEGIN, InteractionType.FLUID, CallbackTypes.BUBBLE, CallbackTypes.AIR, onBubbleTouchAir, 2);
			space.listeners.add(bubbleTouchAir);
		}
		
		private function onPlayerTouchAir(collision:InteractionCallback) : void
		{
			var obj1:ZlxNapeSprite = bodyRegistry.getSprite(collision.int1);
			var obj2:ZlxNapeSprite = bodyRegistry.getSprite(collision.int2);
			if (obj1 is Player)
			{
				Player(obj1).onTouchAir(true);
			}
			if (obj2 is Player)
			{
				Player(obj2).onTouchAir(true);
			}
		}
		
		private function onPlayerStopTouchAir(collision:InteractionCallback) : void
		{
			var obj1:ZlxNapeSprite = bodyRegistry.getSprite(collision.int1);
			var obj2:ZlxNapeSprite = bodyRegistry.getSprite(collision.int2);
			if (obj1 is Player)
			{
				Player(obj1).onTouchAir(false);
			}
			if (obj2 is Player)
			{
				Player(obj2).onTouchAir(false);
			}
		}
		
		private function onBubbleTouchAir(collision:InteractionCallback) : void
		{
			var obj1:ZlxNapeSprite = bodyRegistry.getSprite(collision.int1);
			var obj2:ZlxNapeSprite = bodyRegistry.getSprite(collision.int2);
			if (obj1 is Bubble)
			{
				Bubble(obj1).onTouchAir();
			}
			if (obj2 is Bubble)
			{
				Bubble(obj2).onTouchAir();
			}
		}
		
		private function playerTouchEnemy(cb:PreCallback):PreFlag {
			var obj1:ZlxNapeSprite = bodyRegistry.getSprite(cb.int1);
			var obj2:ZlxNapeSprite = bodyRegistry.getSprite(cb.int2);
			if (obj1 is Player)
			{
				Player(obj1).damage();
				hud.onPlayerDamage();
			}
			
			if (obj2 is Player)
			{
				Player(obj2).damage();
				hud.onPlayerDamage();
			}
			return PreFlag.IGNORE;
		}
		
		private function playerTouchPickup(collision:InteractionCallback) : void
		{
			var obj1:ZlxNapeSprite = bodyRegistry.getSprite(collision.int1);
			var obj2:ZlxNapeSprite = bodyRegistry.getSprite(collision.int2);
			if (obj1 is IPickup)
			{
				IPickup(obj1).pickup();
			}
			if (obj2 is IPickup)
			{
				IPickup(obj2).pickup();
			}
		}
		
		override public function update():void
		{
			if (!paused)
			{
				space.step(FRAME_RATE, 5, 3);
			}
			
			
			//		trace(space.bodies.length);
			
			super.update();	
			
			depthDarkness = FlxG.camera.scroll.y / maxDarknessY;
			
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
				
				if (FlxG.keys.justPressed("O"))
				{
					DEBUG_DRAW = !DEBUG_DRAW;
					if (!DEBUG_DRAW)
					{
						debug.clear();
						debug.flush();
					}
				}
				
				if (FlxG.keys.justPressed("T"))
				{
					extendTube(1);
				}
				
				if (FlxG.keys.justPressed("D"))
				{
					darkness.visible = !darkness.visible;
				}
				
				if (FlxG.keys.justPressed("P"))
				{
					paused = !paused;
				}
			}
			
			var time:int = getTimer();
			if (time > _nextCleanTime)
			{
				_nextCleanTime = time + CLEAN_TIME * 1000;
				ZGroupUtils .cleanGroup(bubbleLayer);
				ZGroupUtils .cleanGroup(enemyLayer);
				ZGroupUtils .cleanGroup(enemyNodeLayer);
				ZGroupUtils .cleanGroup(glowLayer);
			}
		}
		
		override public function draw():void 
		{
		   darkness.reDarken();
		   super.draw();
		 }
		
		public function setupTube(X:Number, Y:Number) : void
		{
			var tube:BreathingTube = new BreathingTube(X, Y, tubeLayer, player, bodyContext);
			tubeLayer.add(tube);
		}
		
		public function severTube() : void
		{
			for each (var tube:FlxSprite in tubeLayer.members)
			{
				if (tube is BreathingTube)
				{
					(tube as BreathingTube).sever();
				}
			}
		}
		
		public function addPlant(X:Number, Y:Number, plantType:int) : void
		{
			var plant:Plant;
			
			switch (plantType)
			{
				case Plant.FALL_PLANT:
					plant = new Plant(X, Y, plantLayer, bodyContext, 2, Math.random() * 3 + 2, plantType, 4, 6);
					break;
					
				case Plant.RISE_PLANT:
					plant = new Plant(X, Y, plantLayer, bodyContext, 2, Math.random() * 3 + 2, plantType, 4, 6);
					break;
					
				case Plant.DRAPE_PLANT:
					plant = new Plant(X, Y, plantLayer, bodyContext, Math.random() * 4 + 2, Math.random() * 2 + 5, plantType, 4, 6);
					break;
					
				case Plant.TINY_PLANT:
					plant = new Plant(X, Y, plantLayer, bodyContext, 2, 1, plantType, 4, 6);
					break;
			}
					
					
			plantLayer.add(plant);
		}
		
		public function addBigRock(X:Number, Y:Number) : void
		{
			const ROCK_COLOR:uint = 0xff571730;
			var rock:ColorSprite = new ColorSprite(X, Y, ROCK_COLOR);
			rock.createBody(100, 40, bodyContext);
			rock.collisionGroup = rock.collisionGroup | InteractionGroups.ROCK;
			rock.setMaterial(new Material(1, 1, 1, Water.DENSITY + .3, .001));
			rockLayer.add(rock);
			
		}
		
		public function addSmallRock(X:Number, Y:Number) : void
		{
			const ROCK_COLOR:uint = 0xff571730;
			var rock:ColorSprite = new ColorSprite(X, Y, ROCK_COLOR);
			rock.createBody(20, 20, bodyContext);
			rock.collisionGroup = rock.collisionGroup | InteractionGroups.ROCK;
			rock.setMaterial(new Material(1, 2, 2, Water.DENSITY + .3, .001));
			rockLayer.add(rock);
			
		}
		
		
		public function addJellyfish(X:Number, Y:Number) : void
		{
			var jellyFish:JellyFish = new JellyFish(X, Y, bodyContext, enemyNodeLayer, segmentLayer);
			enemyLayer.add(jellyFish);
		}
		
		public function addAirPocket(X:Number, Y:Number) : void
		{
			for (var i:int = 0; i < 3; i++)
			{
				var bubble:Bubble = new Bubble(X, Y, 10, bodyContext, false);
				bubbleLayer.add(bubble);
			}
		}
		
		public function attachGlow(owner:FlxSprite, radius:Number) : Glow
		{
			var glow:Glow = new Glow(owner.x, owner.y, darkness, owner, radius);
			glowLayer.add(glow);
			
			return glow;
		}
		
		public function queueText(text:Vector.<PlayText>) : void
		{
			hud.textUI.textPlayer.queue(text);
		}
		
		protected static function addText(vec:Vector.<PlayText>, text:String, duration:int = -1) : void
		{
			if (duration < 0)
			{
				duration = PlayText.DEFAULT_DURATION;
			}
			
			vec.push(new PlayText(text, duration));
		}
		
		public function onOrbReturned() : void
		{
			var text:Vector.<PlayText> = new Vector.<PlayText>();
			addText(text, "you collected an orb!");
			queueText(text);
			
			extendTube(15);
		}
		
		public function getTube() : BreathingTube
		{
			return tubeLayer.members[0] as BreathingTube;
		}
		
		private function extendTube(amt:int) : void
		{
			getTube().extend(amt);
		}
		
		public function addAirZone(startPoint:FlxPoint, endPoint:FlxPoint) : void
		{
			airZoneLayer.add(new AirZone(startPoint, endPoint, bodyContext));
		}
		
		public function addTrapDoor(X:Number, Y:Number) : void
		{
			var trapDoor:TrapDoor = new TrapDoor(X, Y, bodyContext, rockLayer);
			rockLayer.add(trapDoor);
		}
		
		public function addOneWayPlatform(X:Number, Y:Number) : void
		{
			const ROCK_COLOR:uint = 0xff571730;
			var plat:ColorSprite = new ColorSprite(X, Y, ROCK_COLOR);
			plat.createBody(20, 4, bodyContext);
			plat.setMaterial(new Material(1, 2, 2, Water.DENSITY + 4, .001));
			plat.collisionGroup = InteractionGroups.ROCK;
			plat.body.type = BodyType.STATIC;
			rockLayer.add(plat);
		}
	}
}