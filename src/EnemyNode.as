package 
{
	import com.zillix.zlxnape.*;
	import com.zillix.zlxnape.ZlxNapeSprite;
	import nape.phys.Material;
	
	
	/**
	 * ...
	 * @author zillix
	 */
	public class EnemyNode extends CircleNapeSprite 
	{
		public function EnemyNode(X:Number, Y:Number, Context:BodyContext, Radius:int, Image:Class = null, Density:Number = 0)
		{
			super(X, Y, Context, Radius, Image);
			
			if (Density == 0)
			{
				Density = Water.DENSITY - .2;
			}
			
			setMaterial(new Material(0, 5, 5, Density));
			collisionGroup = InteractionGroups.ENEMY_NODE;
			
			addCbType(CallbackTypes.ENEMY);
			//collisionMask = ~InteractionGroups.ENEMY_NODE;
		}
	}
	
}