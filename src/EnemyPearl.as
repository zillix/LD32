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
		
		private var dropOff:ZlxNapeSprite;
		private static const RETURN_DIST:Number = 50;
		
		public function EnemyPearl(X:Number, Y:Number, Context:BodyContext, Radius:int, DropOff:ZlxNapeSprite = null)
		{
			super(X, Y, Context, Radius);
			setMaterial(new Material(0, 0, 0, Water.DENSITY + 1));
			addCbType(CallbackTypes.PICKUP);
			dropOff = DropOff;
			
		}
		
		public function pickup() : void
		{
			collisionMask = 0;
			//body.type = BodyType.KINEMATIC;
			followTarget(PlayState.instance.player, 100, 200);
		}
		
		override public function update() : void
		{
			super.update();
			
			if (dropOff != null)
			{
				if (body.position.sub(dropOff.body.position).length < RETURN_DIST)
				{
					PlayState.instance.onOrbReturned();
					kill();
				}
			}
		}
	}
	
}