package 
{
	import com.zillix.zlxnape.*;
	import flash.events.DRMCustomProperties;
	import nape.phys.Material;
	import nape.geom.*;
	import org.flixel.FlxGroup;
	import org.flixel.FlxPoint;
	import com.zillix.utils.ZMathUtils;
	
	/**
	 * ...
	 * @author zillix
	 */
	public class SuperJelly extends EnemyCore 
	{
		
		[Embed(source = "data/jellyfishTentacleSegment.png")]	public var SegmentSprite:Class;
		public static const TENTACLES:int = 5;
		public static const NODE_COUNT:int = 5;
		public static const TENTACLE_LENGTH:int = 5;
		
		private var _chains:Vector.<BodyChain> = new Vector.<BodyChain>();
		public function SuperJelly(X:Number, Y:Number, Context:BodyContext, NodeLayer:FlxGroup, SegmentLayer:FlxGroup)
		{
			super(X, Y, Context, NodeLayer, NODE_COUNT);
			setMaterial(new Material(0, 0, 0, Water.DENSITY - .1));
			
			for (var i:int = 0; i < NODE_COUNT; i++)
			{
				var chain:BodyChain
				if (i == 5)
				{
					chain  = new BodyChain(_nodes[i], 
						Vec2.get(),
						SegmentLayer, 
						Context,
						0,	// no segments
						8,
						16,
						0xffdddddd,
						0,
						2);
				}
				else
				{
					chain  = new BodyChain(_nodes[i], 
						Vec2.get(),
						SegmentLayer, 
						Context,
						NODE_COUNT,
						8,
						16,
						0xffdddddd,
						0,
						2);
				}
				
					
					
					
				chain.segmentCollisionMask = ~(InteractionGroups.NO_COLLIDE | InteractionGroups.ENEMY | InteractionGroups.ENEMY_NODE | InteractionGroups.SEGMENT);
				chain.fluidMask = 0;
				chain.segmentDrag = new FlxPoint(30, 30);
				chain.segmentMaterial = new Material(0, 4, 4, .01);
				_chains.push(chain);
				
				chain.segmentSpriteClass = SegmentSprite;
				
				chain.init();
			}
			
			chain.addCbType(CallbackTypes.ENEMY);
			
		}
		
		override protected function setupNodes() : void
		{
			_nodeDistance = 30;
			_nodeCount = 5;
			_coreRadius = 20;
			_nodeRadius = 35;
			_nodeDesnsity = 2;
			super.setupNodes();
			makeInvincible();
		}
		
		override public function update() : void
		{
			super.update();
			
		}
		
		override protected function killNode(index:int) : void
		{
			var tentacle:Tentacle = new Tentacle(_nodes[index], _chains[index]);
			PlayState.instance.enemyLayer.add(tentacle);
			_nodes[index] = null;
			_chains[index] = null;
		}
	}
	
}