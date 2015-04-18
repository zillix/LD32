package 
{
	import com.zillix.zlxnape.*;
	import nape.phys.BodyType;
	import nape.phys.Material;
	
	/**
	 * ...
	 * @author zillix
	 */
	public class EnemyPearl extends CircleNapeSprite implements IPickup
	{
		public function EnemyPearl(X:Number, Y:Number, Context:BodyContext, Radius:int)
		{
			super(X, Y, Context, Radius);
			setMaterial(new Material(0, 0, 0, Water.DENSITY + 1));
			addCbType(CallbackTypes.PICKUP);
			
		}
		
		public function pickup() : void
		{
			collisionMask = 0;
			//body.type = BodyType.KINEMATIC;
			followTarget(PlayState.instance.player, 100, 200);
		}
	}
	
}