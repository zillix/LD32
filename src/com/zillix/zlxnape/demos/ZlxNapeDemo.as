package com.zillix.zlxnape.demos
{
	import com.zillix.zlxnape.BodyContext;
	import com.zillix.zlxnape.BodyRegistry;
	import com.zillix.zlxnape.ColorSprite;
	import com.zillix.zlxnape.ConnectedPixelGroup;
	import com.zillix.zlxnape.interfaces.IBoxSpawner;
	import com.zillix.zlxnape.SpriteChain;
	import com.zillix.zlxnape.InteractionGroups;
	import com.zillix.zlxnape.ZlxNapeSprite;
	import com.zillix.zlxnape.CallbackTypes;
	import com.zillix.utils.ZMathUtils;
	import com.zillix.utils.ZGroupUtils;
	import flash.utils.Dictionary;
	import nape.callbacks.CbEvent;
	import nape.callbacks.InteractionCallback;
	import nape.callbacks.InteractionListener;
	import nape.callbacks.InteractionType;
	import nape.dynamics.CollisionArbiter;
	import nape.phys.Body;
	import nape.phys.BodyType;
	import nape.space.Space;
	import nape.util.BitmapDebug;
	import nape.util.Debug;
	import nape.geom.Vec2;
	import org.flixel.FlxPoint;
	import org.flixel.FlxText;
	
	import org.flixel.FlxGroup;
	import org.flixel.FlxG;
	
	/**
	 * ...
	 * @author zillix
	 */
	public class ZlxNapeDemo extends FlxGroup implements IBoxSpawner
	{
		[Embed(source = "../../../../data/player.png")]	public var BoxSprite:Class;
		
		private static const CLEAN_FREQ:int = 1;
		private var _cleanTime:Number = 0;
		
		public var GRAVITY:Number = 70;
		public static const FRAME_RATE :Number = 1 / 30;
		
		protected var _player:Player;
		
		protected var _cleaningGroups:FlxGroup;
		
		protected var _foreground:FlxGroup;
		protected var _background:FlxGroup;
		
		protected var _boxes:FlxGroup;
		protected var _deadBoxes:FlxGroup;
		
		protected var _space:Space;
		
		protected var _bodyRegistry:BodyRegistry;
		
		protected var _debug:Debug;
		
		protected var DEBUG_DRAW:Boolean = false;
		
		public static const ECHO_SPRITE_DEMO:int = 1;
		public static const TENTACLE_DEMO:int = 2;
		public static const POLYGON_READER_DEMO:int = 3;
		public static const CONNECTED_PIXEL_GROUP_DEMO:int = 6;
		public static const SPRITE_CHAIN_DEMO:int = 4;
		
		private var _instructions:FlxText;
		
		public function ZlxNapeDemo() : void
		{
			_bodyRegistry = new BodyRegistry;
			
			_foreground = new FlxGroup();
			_background = new FlxGroup();
			
			add(_background);
			
			_instructions = new FlxText(0, 20, FlxG.width, instructionsText);
			_instructions.setFormat(null, 20, 0x000000, "center");
			add(_instructions);
			
			_space = new Space(new Vec2(0, GRAVITY));
			
			var context:BodyContext = new BodyContext(_space, _bodyRegistry);
			
			const FLOOR_COLOR:uint = 0xff0000ff;
			var floor:ColorSprite = new ColorSprite(0, 450, FLOOR_COLOR);
			floor.createBody(640, 30, context, BodyType.STATIC);
			floor.addCbType(CallbackTypes.GROUND);
			add(floor);
			
			floor = new ColorSprite(0, 0, FLOOR_COLOR);
			floor.createBody(30, 480, context, BodyType.STATIC);
			floor.addCbType(CallbackTypes.GROUND);
			add(floor);
			
			floor = new ColorSprite(610, 0, FLOOR_COLOR);
			floor.createBody(30, 480, context, BodyType.STATIC);
			floor.addCbType(CallbackTypes.GROUND);
			add(floor);
			
			_debug = new BitmapDebug(FlxG.width, FlxG.height, 0xdd000000, true );
			FlxG.stage.addChild(_debug.display);
			
			_boxes = new FlxGroup();
			_deadBoxes = new FlxGroup();
			
			_cleaningGroups = new FlxGroup();
			_cleaningGroups.add(_foreground);
			_cleaningGroups.add(_background);
			_cleaningGroups.add(_boxes);
			_cleaningGroups.add(_deadBoxes);
			
			add(_deadBoxes);
			
			add(_boxes);
			
			add(_foreground);
			
			setUpPlayer();
			
			setUpListeners();
		}
		
		override public function update() : void
		{
			super.update();
			
			_space.step(FRAME_RATE, 5, 3);
			super.update();	
			
			if (DEBUG_DRAW)
			{
				_debug.clear();
				doDebugDraw();
				_debug.flush();
			}
			
			// Periodically purge groups of dead children
			_cleanTime -= FlxG.elapsed;
			if (_cleanTime < 0)
			{
				_cleanTime = CLEAN_FREQ;
				ZGroupUtils.cleanGroup(_cleaningGroups);
			}
			
			if (FlxG.mouse.justPressed())
			{
				onMousePressed();
			}
			
			if (FlxG.keys.justPressed("P"))
			{
				DEBUG_DRAW = !DEBUG_DRAW;
				if (!DEBUG_DRAW)
				{
					_debug.clear();
					_debug.flush();
				}
			}
		}
		
		protected function get instructionsText() : String
		{
			// Overridden by children
			return "";
		}
		
		protected function setUpPlayer() : void
		{
			// Overridden by children
		}
		
		protected function doDebugDraw() : void
		{
			_debug.draw(_space);
		}
		
		protected function onMousePressed() : void
		{
			spawnBox(FlxG.mouse.screenX, FlxG.mouse.screenY);
		}
		
		public function spawnBox(x:Number, y:Number, width:int = 20, angle:Number = 0, color:uint = 0) : ZlxNapeSprite
		{
			if (color == 0)
			{
				// Random color
				color = 0xff000000 + Math.random() * 0xffffff; 
			}
			
			var box:ColorSprite = new ColorSprite(x, 
				y, 
				color);
			box.createBody(width, width, new BodyContext(_space, _bodyRegistry));
			box.collisionGroup = InteractionGroups.BOX;
			box.body.rotation = ZMathUtils.toRadians(angle);
			
			if (color != 0)
			{
				box.makeGraphic(width, width, color);
			}
			
			_boxes.add(box);
			
			return box;
		}
		
		private function setUpListeners() : void
		{
			var playerTouchGround:InteractionListener = new InteractionListener(CbEvent.BEGIN, InteractionType.COLLISION, CallbackTypes.PLAYER, CallbackTypes.GROUND, onPlayerLand);
			_space.listeners.add(playerTouchGround);
	
			var absorb:InteractionListener = new InteractionListener(CbEvent.ONGOING, InteractionType.COLLISION, CallbackTypes.PLAYER, CallbackTypes.ABSORB, onPlayerAbsorb);
			_space.listeners.add(absorb);
		}
		
		private function onPlayerAbsorb(collision:InteractionCallback) : void
		{
			if (_bodyRegistry.getSprite(collision.int1) != null)
			{
				var obj:ZlxNapeSprite = _bodyRegistry.getSprite(collision.int1);
				var obj2:ZlxNapeSprite = _bodyRegistry.getSprite(collision.int2);
				if (obj is Player)
				{
					Player(obj).onAbsorb(obj2);
				}
			}
		}
		
		private function onPlayerLand(collision:InteractionCallback) : void
		{
			if (_bodyRegistry.getSprite(collision.int1) != null)
			{
				var colArb:CollisionArbiter = collision.arbiters.at(0) as CollisionArbiter;
				if (colArb.normal.y < 0)
				{
					var obj:ZlxNapeSprite = _bodyRegistry.getSprite(collision.int1);
					if (obj is Player)
					{
						Player(obj).onLand();
					}
				}
			}
		}
		
		public function cleanUp() : void
		{
			_space.clear();
			FlxG.stage.removeChild(_debug.display);
		}
	}
	
}