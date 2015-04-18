package 
{
	import com.zillix.zlxnape.*;
	import flash.events.DRMCustomProperties;
	import nape.phys.Material;
	import nape.geom.*;
	import org.flixel.FlxGroup;
	
	/**
	 * ...
	 * @author zillix
	 */
	public class JellyFish extends EnemyCore 
	{
		public static const TENTACLES:int = 4;
		public static const NODE_COUNT:int = 4;
		public static const TENTACLE_LENGTH:int = 3;
		
		private var _chains:Vector.<BodyChain> = new Vector.<BodyChain>();
		public function JellyFish(X:Number, Y:Number, Context:BodyContext, NodeLayer:FlxGroup)
		{
			super(X, Y, Context, NodeLayer, NODE_COUNT);
			setMaterial(new Material(0, 0, 0, Water.DENSITY));
			
			for (var i:int = 0; i < NODE_COUNT; i++)
			{
				var offsetVector:Vec2 = getEdgeVector(Math.random() * 4 + 1);
				var chain:BodyChain = new BodyChain(_nodes[i], 
					Vec2.get(),
					NodeLayer, 
					Context,
					NODE_COUNT,
					8,
					16,
					0xffdddddd,
					0,
					2);
				
					
					
					
				chain.segmentCollisionMask = ~(InteractionGroups.NO_COLLIDE | InteractionGroups.ENEMY | InteractionGroups.ENEMY_NODE | InteractionGroups.SEGMENT);
				chain.fluidMask = 0;
				chain.segmentMaterial = new Material(0, 4, 4, .01);
				_chains.push(chain);
				chain.init();
			}
			
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