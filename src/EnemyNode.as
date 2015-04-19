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
		public function EnemyNode(X:Number, Y:Number, Context:BodyContext, Radius:int, Image:Class = null)
		{
			super(X, Y, Context, Radius, Image);
			
			setMaterial(new Material(0, 5, 5, Water.DENSITY - .2));
			collisionGroup = InteractionGroups.ENEMY_NODE;
			
			addCbType(CallbackTypes.ENEMY);
			//collisionMask = ~InteractionGroups.ENEMY_NODE;
		}
	}
	
}