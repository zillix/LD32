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
	public class DrapePlant extends ColorSprite 
	{
		public function DrapePlant(X:Number, Y:Number, PlantLayer:FlxGroup, Context:BodyContext)
		{
			super(X, Y, PlantLayer, Context);
			createBody(20, 20, Context, BodyType.STATIC);
			
			var segmentCollisionMask:uint = ~InteractionGroups.NO_COLLIDE;
			for (var i:int = 0; i < 5; i++)
			{
				var offsetVector:Vec2 = getEdgeVector(Math.random() * 4 + 1);
				var chain:BodyChain = new BodyChain(this, offsetVector, PlantLayer, Context, 25, 4, 4, 0, 0, 1, 2); 
			
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