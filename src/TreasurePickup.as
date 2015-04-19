package 
{
	import com.zillix.zlxnape.*;
	import nape.phys.BodyType;
	import nape.phys.Material;
	import org.flixel.FlxPoint;
	
	/**
	 * ...
	 * @author zillix
	 */
	public class TreasurePickup extends ZlxNapeSprite implements IPickup
	{
		[Embed(source = "data/treasurePickup.png")]	public var TreasurePickupSprite:Class;
		
		private var dropOff:ZlxNapeSprite;
		private static const RETURN_DIST:Number = 50;
		
		public function TreasurePickup(X:Number, Y:Number, Context:BodyContext,DropOff:ZlxNapeSprite = null)
		{
			super(X, Y);
			loadGraphic(TreasurePickupSprite);
			scale = new FlxPoint(2, 2);
			createBody(width, height, Context, null, true, scale);
			setMaterial(new Material(0, 0, 0, Water.DENSITY + 1));
			addCbType(CallbackTypes.PICKUP);
			dropOff = DropOff;
			
			
			
			
		}
		
		public function pickup() : void
		{
			collisionMask = 0;
			//body.type = BodyType.KINEMATIC;
			_minFollowDist = 0;
			followTarget(PlayState.instance.player, 100, 200);
			//PlayState.instance.player.onTreasurePickedUp();
			PlayState.instance.endGame(PlayState.END_TREASURE);
			kill();
		}
		
		override public function update() : void
		{
			super.update();
			
			if (dropOff != null)
			{
				if (body.position.sub(dropOff.body.position).length < RETURN_DIST)
				{
					PlayState.instance.endGame(PlayState.END_TREASURE);
					kill();
				}
			}
		}
	}
	
}