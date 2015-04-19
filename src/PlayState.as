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
		[Embed(source = "data/map1shafttiny.png")]	public var Map1:Class;
		
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
		
		public static const ORB_COLLECT_TUBE_EXTEND:int = 10;
		
		public var mapReader:MapReader;
		
		public var blockerJellyPoints:Vector.<FlxPoint> = new Vector.<FlxPoint>();
		
		
		public var terrainLayer:FlxGroup = new FlxGroup();
		public var bubbleLayer:FlxGroup = new FlxGroup();
		public var tubeLayer:FlxGroup = new FlxGroup();
		public var plantLayer:FlxGroup = new FlxGroup();
		public var rockLayer:FlxGroup = new FlxGroup();
		private var hudLayer:FlxGroup = new FlxGroup();
		public var enemyLayer:FlxGroup = new FlxGroup();
		private var enemyNodeLayer:FlxGroup = new FlxGroup();
		public var darkLayer:FlxGroup = new FlxGroup();
		public var glowLayer:FlxGroup = new FlxGroup();
		public var airZoneLayer:FlxGroup = new FlxGroup();
		public var messageLayer:FlxGroup = new FlxGroup();
		public var treasureLayer:FlxGroup = new FlxGroup();
		
		public var endFadeLayer:FlxGroup = new FlxGroup();
		
		public var segmentLayer:FlxGroup = new FlxGroup();
		
		private var darkness:Darkness;
		public var hud:Hud;
		
		public static const GRAVITY:Number = 100;
		public static const FRAME_RATE :Number = 1 / 30;
		
		public var bubbleRenderer:FluidRenderer;
		
		public static const CLEAN_TIME:Number = 1;
		private var _nextCleanTime:Number = 0;
		
		// Things mapReader sets
		public var playerSpawn:FlxPoint = new FlxPoint();
		
		public var depthDarkness:Number = 0;
		public static const MIN_DARKNESS_VAL:Number = .3;
		public static const MAX_DARKNESS_VAL:Number = .8;
		public static const MAX_DARKNESS_OFFSET:Number = 200;
		public var maxDarknessY:Number = 1;
		
		public var paused:Boolean = false;
		
		public var setupCompleteTime:int;
		public var SETUP_DURATION:int = 1;
		
		public var activeOrb:MessageOrb =  null;
		public var viewedOneOrb:Boolean = false;
		
		public static const END_TREASURE:int = 0;
		public static const END_DEATH:int = 1;
		public static const END_JELLY:int = 2;
		public static const END_BODY:int = 3;
		
		public static var currentEnding:int = END_DEATH;
		
		public var showEndText:Boolean = false;
		
		public var endFade:FlxSprite;
		public var endFadeCallback:Function;
		public var END_FADE_RATE:Number = .5;
		public var endingGame:Boolean = false;
		
		public var jellyMinX:Number = 0;
		
		
		override public function create():void
		{
			instance = this;
			FlxG.bgColor = 0xffA3948B;
			
			add(treasureLayer);
			
			bubbleRenderer = new FluidRenderer(FlxG.width, FlxG.height, bubbleLayer.members);
			add(bubbleRenderer);
			//fluidRenderer.alpha = .5;
			add(airZoneLayer);
			
			add(glowLayer);
			add(terrainLayer);
			add(messageLayer);
			add(bubbleLayer);
			add(tubeLayer);
			add(plantLayer);
			add(rockLayer);
			add(segmentLayer);
			add(enemyNodeLayer);
			add(enemyLayer);
			
			
			add(darkLayer);
			
			add(endFadeLayer);
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
			
			setupCompleteTime = getTimer() + SETUP_DURATION * 1000;
			
			
		}
		
		private function setUpListeners() : void
		{
			var touchPickup:InteractionListener = new InteractionListener(CbEvent.BEGIN, InteractionType.COLLISION, CallbackTypes.PLAYER, CallbackTypes.PICKUP, playerTouchPickup, 2);
			space.listeners.add(touchPickup);
			
			var touchEnemy:PreListener = new PreListener(InteractionType.COLLISION,
				CallbackTypes.PLAYER,
				CallbackTypes.ENEMY,
				playerTouchEnemy, 0)
			space.listeners.add(touchEnemy);
			
			var playerTouchAir:InteractionListener = new InteractionListener(CbEvent.BEGIN, InteractionType.FLUID, CallbackTypes.PLAYER, CallbackTypes.AIR, onPlayerTouchAir, 2);
			space.listeners.add(playerTouchAir);
			
			var playerStopTouchAir:InteractionListener = new InteractionListener(CbEvent.END, InteractionType.FLUID, CallbackTypes.PLAYER, CallbackTypes.AIR, onPlayerStopTouchAir, 2);
			space.listeners.add(playerStopTouchAir);
			
			var bubbleTouchAir:InteractionListener = new InteractionListener(CbEvent.BEGIN, InteractionType.FLUID, CallbackTypes.BUBBLE, CallbackTypes.AIR, onBubbleTouchAir, 2);
			space.listeners.add(bubbleTouchAir);
			
			var rockTouchShrine:InteractionListener = new InteractionListener(CbEvent.BEGIN, InteractionType.COLLISION, CallbackTypes.SHRINE, CallbackTypes.ENEMY, onRockTouchShrine, 2);
			space.listeners.add(rockTouchShrine);
			
			var bubbleTouchMessage:InteractionListener = new InteractionListener(CbEvent.BEGIN, InteractionType.FLUID, CallbackTypes.BUBBLE, CallbackTypes.MESSAGE, onBubbleTouchMessage, 2);
			space.listeners.add(bubbleTouchMessage);
			
			var bubbleTouchMessageCollide:InteractionListener = new InteractionListener(CbEvent.BEGIN, InteractionType.COLLISION, CallbackTypes.BUBBLE, CallbackTypes.MESSAGE, onBubbleTouchMessage, 2);
			space.listeners.add(bubbleTouchMessageCollide);
			
			var bubbleTouchTreasure:InteractionListener = new InteractionListener(CbEvent.BEGIN, InteractionType.FLUID, CallbackTypes.BUBBLE, CallbackTypes.TREASURE, onBubbleTouchTreasure, 2);
			space.listeners.add(bubbleTouchTreasure);
			
			var bubbleTouchTreasureCollide:InteractionListener = new InteractionListener(CbEvent.BEGIN, InteractionType.COLLISION, CallbackTypes.BUBBLE, CallbackTypes.TREASURE, onBubbleTouchTreasure, 2);
			space.listeners.add(bubbleTouchTreasureCollide);
			
			var rockTouchEnemy:InteractionListener = new InteractionListener(CbEvent.BEGIN, InteractionType.COLLISION, CallbackTypes.ROCK, CallbackTypes.ENEMY, onRockTouchEnemy, 2);
			space.listeners.add(rockTouchEnemy);
			
			var touchRock:PreListener = new PreListener(InteractionType.COLLISION,
				CallbackTypes.PLAYER,
				CallbackTypes.ROCK,
				playerTouchRock, 0)
			space.listeners.add(touchRock);
			
			var playerTouchBody:InteractionListener = new InteractionListener(CbEvent.BEGIN, InteractionType.COLLISION, CallbackTypes.PLAYER, CallbackTypes.DEADBODY, onPlayerTouchBody, 2);
			space.listeners.add(playerTouchBody);
		}
		
		private function onPlayerTouchBody(collision:InteractionCallback) : void
		{
			endGame(END_BODY);
		}
		
		private function onRockTouchEnemy(collision:InteractionCallback) : void
		{
			var obj1:ZlxNapeSprite = bodyRegistry.getSprite(collision.int1);
			var obj2:ZlxNapeSprite = bodyRegistry.getSprite(collision.int2);
			if (obj1 is BigRock)
			{
				BigRock(obj1).onTouchEnemy();
			}
			if (obj2 is BigRock)
			{
				BigRock(obj2).onTouchEnemy();
			}
		}
		
		private function onBubbleTouchTreasure(collision:InteractionCallback) : void
		{
			var obj1:ZlxNapeSprite = bodyRegistry.getSprite(collision.int1);
			var obj2:ZlxNapeSprite = bodyRegistry.getSprite(collision.int2);
			if (obj1 is Treasure)
			{
				Treasure(obj1).onTouchBubble(Bubble(obj2));
			}
			if (obj2 is Treasure)
			{
				Treasure(obj2).onTouchBubble(Bubble(obj1) );
			}
		}
		
		private function onBubbleTouchMessage(collision:InteractionCallback) : void
		{
			var obj1:ZlxNapeSprite = bodyRegistry.getSprite(collision.int1);
			var obj2:ZlxNapeSprite = bodyRegistry.getSprite(collision.int2);
			if (obj1 is MessageOrb)
			{
				MessageOrb(obj1).onTouchBubble(Bubble(obj2));
			}
			if (obj2 is MessageOrb)
			{
				MessageOrb(obj2).onTouchBubble(Bubble(obj1) );
			}
		}
		
		private function onBubbleTouchMessageCollide(collision:InteractionCallback) : void
		{
			var obj1:ZlxNapeSprite = bodyRegistry.getSprite(collision.int1);
			var obj2:ZlxNapeSprite = bodyRegistry.getSprite(collision.int2);
			if (obj1 is MessageOrb)
			{
				MessageOrb(obj1).onTouchBubble(Bubble(obj2));
			}
			if (obj2 is MessageOrb)
			{
				MessageOrb(obj2).onTouchBubble(Bubble(obj1) );
			}
		}
		
		private function onRockTouchShrine(collision:InteractionCallback) : void
		{
			var obj1:ZlxNapeSprite = bodyRegistry.getSprite(collision.int1);
			var obj2:ZlxNapeSprite = bodyRegistry.getSprite(collision.int2);
			if (obj1 is Shrine)
			{
				Shrine(obj1).onRockHit();
			}
			if (obj2 is Shrine)
			{
				Shrine(obj2).onRockHit();
			}
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
		
		private function playerTouchRock(cb:PreCallback):PreFlag {
			var obj1:ZlxNapeSprite = bodyRegistry.getSprite(cb.int1);
			var obj2:ZlxNapeSprite = bodyRegistry.getSprite(cb.int2);
			if (obj1 is Player)
			{
				obj1.body.velocity = obj1.body.velocity.normalise().mul( -1 * 300);
			}
			
			if (obj2 is Player)
			{
				obj2.body.velocity = obj1.body.velocity.normalise().mul( -1 * 300);
			}
			return PreFlag.IGNORE;
		}
		
		
		private function playerTouchEnemy(cb:PreCallback):PreFlag {
			var obj1:ZlxNapeSprite = bodyRegistry.getSprite(cb.int1);
			var obj2:ZlxNapeSprite = bodyRegistry.getSprite(cb.int2);
			if (obj1 is Player)
			{
				if (Player(obj1).x > jellyMinX)
				{
					endGame(END_JELLY);
				}
				else
				{
					Player(obj1).damage();
					hud.onPlayerDamage();
				}
			}
			
			if (obj2 is Player)
			{
				if (Player(obj2).x > jellyMinX)
				{
					endGame(END_JELLY);
				}
				else
				{
					Player(obj2).damage();
					hud.onPlayerDamage();
				}
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
			
			if (getTimer() < setupCompleteTime || !viewedOneOrb)
			{
				player.setPosition(playerSpawn.x, playerSpawn.y);
			}
			
				depthDarkness = FlxG.camera.scroll.y / maxDarknessY * (MAX_DARKNESS_VAL - MIN_DARKNESS_VAL) + MIN_DARKNESS_VAL;
			
			if (endFade != null)
			{
				if (endFade.alpha < 1)
				{
					endFade.alpha += FlxG.elapsed * END_FADE_RATE;
					if (endFade.alpha >= 1)
					{
						if (endFadeCallback != null)
						{
							endFadeCallback();
						}
					}
				}
			}
				
			
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
				
				if (FlxG.keys.justPressed("R"))
				{
					extendTube(ORB_COLLECT_TUBE_EXTEND);
				}
				
				if (FlxG.keys.A)
				{
					player.currentAir = player.maxAir;
				}
				
				if (FlxG.keys.justPressed("ONE"))
				{
					endGame(END_TREASURE);
				}
				
				if (FlxG.keys.justPressed("TWO"))
				{
					endGame(END_DEATH);
				}
				
				if (FlxG.keys.justPressed("THREE"))
				{
					endGame(END_JELLY);
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
			
			viewedOneOrb = true;
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
			var rock:BigRock = new BigRock(X, Y, bodyContext);
			rockLayer.add(rock);
		}
		
		public function addSmallRock(X:Number, Y:Number) : void
		{
			/*const ROCK_COLOR:uint = 0xff571730;
			var rock:ColorSprite = new ColorSprite(X, Y, ROCK_COLOR);
			rock.createBody(20, 20, bodyContext);
			rock.collisionGroup = rock.collisionGroup | InteractionGroups.ROCK;
			rock.setMaterial(new Material(1, 2, 2, Water.DENSITY + .3, .001));
			rockLayer.add(rock);*/
			const ROCK_COLOR:uint = 0xff571730;
			var rock:ColorSprite = new ColorSprite(X, Y, ROCK_COLOR);
			rock.createBody(60, 60, bodyContext);
			rock.collisionGroup = rock.collisionGroup | InteractionGroups.ROCK;
			rock.setMaterial(new Material(-5, 1, 1, Water.DENSITY, .001));
			rockLayer.add(rock);
			rock.addCbType(CallbackTypes.ROCK);
			
		}
		
		
		public function addJellyfish(X:Number, Y:Number) : JellyFish
		{
			var jellyFish:JellyFish = new JellyFish(X, Y, bodyContext, enemyNodeLayer, segmentLayer);
			enemyLayer.add(jellyFish);
			return jellyFish;
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
		
		public function onOrbReturned() : void
		{
			extendTube(ORB_COLLECT_TUBE_EXTEND);
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
			plat.collisionMask = InteractionGroups.ROCK | InteractionGroups.PLAYER
			
			
			plat.body.type = BodyType.STATIC;
			rockLayer.add(plat);
		}
		
		public function addShrine(X:Number, Y:Number) : void
		{
			var treasure:Treasure = new Treasure(X, Y, bodyContext);
			//var shrine:Shrine = new Shrine(X, Y, bodyContext);
			treasureLayer.add(treasure);
		}
		
		public function addRoundCorner(X:Number, Y:Number, type:uint) : void
		{
			var terrain:ZlxNapeSprite = new ZlxNapeSprite(X, Y);
			switch (type)
			{
				case MapReader.TOP_RIGHT_ROUND_TERRAIN:
					terrain.createCircleBody(20, bodyContext);
					terrain.setPosition(terrain.x, terrain.y + 20);
					break;
			}
			
			terrain.setMaterial(new Material(0, 0, 0, 0));
			terrain.body.type = BodyType.STATIC;
			terrainLayer.add(terrain);
		}
		
		public function addMessageOrb(X:Number, Y:Number) : void
		{
			var orb:MessageOrb = new MessageOrb(X, Y, bodyContext, messageLayer.members.length);
			messageLayer.add(orb);
		}
		
		public function setActiveOrb(orb:MessageOrb) : void
		{
			activeOrb = orb;
			viewedOneOrb = true;
		}
		
		public static function getEndColor(ending:int) : uint
		{
			switch (ending)
			{
				case END_TREASURE:
					return 0xffE4D870;
					
				case END_DEATH:
					return 0xff820C0D;
					
				case END_JELLY:
					return 0xff4DFDFC;
					
				case END_BODY:
					return 0xff000000;
					
				default:
					return 0xff000000;
			}
		}
		
		public static function endTextColor(ending:int) : uint
		{
			var text:Vector.<PlayText> = new Vector.<PlayText>();
			switch (ending)
			{
				case END_TREASURE:
					return 0xff000000;
					
				case END_DEATH:
					return 0xffffffff;
					
				case END_JELLY:
					return 0xff000000;
					
				case END_BODY:
					return 0xffffffff;
					
				default:
					return 0xff000000;
			}
			
			return text;
		}
		
		public  function getEndText(ending:int) : Vector.<PlayText>
		{
			var text:Vector.<PlayText> = new Vector.<PlayText>();
			var endTextColor:uint = endTextColor(ending);
			switch (ending)
			{
				case END_TREASURE:
					PlayText.addText(text, "celebrate your trinket, little one", -1, null, endTextColor);
					PlayText.addText(text, "may it bring happiness to what life you have left", -1, finishEndingGame, endTextColor);
					break;
					
				case END_DEATH:
					PlayText.addText(text, "do not fear, child", -1, null, endTextColor);
					PlayText.addText(text, "now you are free", -1, finishEndingGame, endTextColor);
					break;
					
				case END_JELLY:
					PlayText.addText(text, "welcome to my home", -1, finishEndingGame, endTextColor);
					break;
					
					
				case END_BODY:
					PlayText.addText(text, "finally, you two reuinite", -1, finishEndingGame, endTextColor);
					break;
					

					
				default:
					return text;
			}
			
			return text;
		}
		
		public function endGame(ending:int) : void
		{
			if (endingGame)
			{
				return;
			}
			
			endingGame = true;
			var endColor:uint = getEndColor(ending);
			currentEnding = ending;
			startEndFade(endColor);
			endFadeCallback = 
			function() : void
			{
				showEndText = true;
				queueText(getEndText(ending));
			};
		}
		
		public function startEndFade(color:uint) : void
		{
			endFade = new FlxSprite();
			endFade.scrollFactor = new FlxPoint(0, 0);
			endFade.makeGraphic(FlxG.width, FlxG.height, color);
			endFade.alpha = 0;
			endFadeLayer.add(endFade);
		}
		
		public function finishEndingGame() : void
		{
			FlxG.fade(0xff000000, 1, function () : void
			{
				FlxG.switchState(new PlayState);
			}
			);
		}
		
		public function addSuperJelly(X:Number, Y:Number) : void
		{
			var superJelly:SuperJelly = new SuperJelly(X, Y, bodyContext, enemyNodeLayer, enemyNodeLayer);
			enemyLayer.add(superJelly);
		}
		
		public function addBlockerJellyPoint(X:Number, Y:Number) : void
		{
			blockerJellyPoints.push(new FlxPoint(X, Y));
		}
		
		public var jellyKilled:Boolean = false;
		public function onJellyKilled() : void
		{
			if (jellyKilled)
			{
				return;
			}
			
			jellyKilled = true;
			
			for each (var point:FlxPoint in blockerJellyPoints)
			{
				var jelly:JellyFish = addJellyfish(point.x, point.y);
				jelly.makeInvincible();
			}
			
		}
		
		public function addDeadBody(X:Number, Y:Number) : void
		{
			var deadBody:DeadBody = new DeadBody(X, Y, bodyContext);
			rockLayer.add(deadBody);
		}
	}
}