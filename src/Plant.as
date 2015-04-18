package 
{
	import com.zillix.zlxnape.*;
	import com.zillix.zlxnape.ZlxNapeSprite;
	import nape.geom.Vec2;
	import org.flixel.FlxGroup;
	import nape.phys.*;
	
	/**
	 * ...
	 * @author zillix
	 */
	public class Plant extends ColorSprite 
	{
		public static const FALL_PLANT:int = 0;
		public static const RISE_PLANT:int = 1;
		public static const DRAPE_PLANT:int = 2;
		
		private static const SEGMENT_WIDTH:int = 4;
		private static const SEGMENT_HEIGHT:int = 20;
		private static const SEGMENTCOLOR:uint = 0xff00ff00;
		
		private static const SUB_COLOR:uint = 0xffffff00;
		
		private var _chains:Vector.<BodyChain> = new Vector.<BodyChain>();
		
		public function Plant(X:Number, Y:Number, PlantLayer:FlxGroup, Context:BodyContext, Fronds:int = 3, FrondSize:int = 4, plantType:int = FALL_PLANT, minDist:int = 4, maxDist:int = 8)
		{
			super(X, Y, SUB_COLOR);
			createBody(20, 20, Context, BodyType.STATIC);
			
			var segmentCollisionMask:uint = InteractionGroups.PLAYER | InteractionGroups.BUBBLE | InteractionGroups.ENEMY;
			for (var i:int = 0; i < Fronds; i++)
			{
				var offsetVector:Vec2 = getEdgeVector(Math.random() * 4 + 1);
				var chain:BodyChain = new BodyChain(this, offsetVector, PlantLayer, Context, FrondSize, SEGMENT_WIDTH, SEGMENT_HEIGHT, SEGMENTCOLOR, minDist, maxDist); 
				chain.segmentCollisionMask = segmentCollisionMask;
				if (plantType == FALL_PLANT || plantType == DRAPE_PLANT)
				{
					chain.fluidMask = 0;
				}
				else
				{
					chain.fluidMask = ~0;
				}
				chain.segmentMaterial = Material.sand();
				_chains.push(chain);
				chain.init();
			}
			
			collisionGroup = InteractionGroups.TERRAIN;
			collisionMask = ~(InteractionGroups.NO_COLLIDE | InteractionGroups.SEGMENT);
		}
	}
	
}