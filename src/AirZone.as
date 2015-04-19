package 
{
	import com.zillix.zlxnape.BodyContext;
	import com.zillix.zlxnape.ZlxNapeSprite;
	import com.zillix.zlxnape.CallbackTypes;
	import com.zillix.zlxnape.InteractionGroups;
	import org.flixel.FlxPoint;
	
	/**
	 * ...
	 * @author zillix
	 */
	public class AirZone extends ZlxNapeSprite 
	{
		public function AirZone(startPoint:FlxPoint, endPoint:FlxPoint, Context:BodyContext)
		{
			super(startPoint.x, startPoint.y);
			createBody(endPoint.x - startPoint.x, endPoint.y - startPoint.y, Context);
			makeGraphic(endPoint.x - startPoint.x, endPoint.y - startPoint.y);
			
			makeFluid( -40, 40);
			
			addCbType(CallbackTypes.AIR);
			
			collisionGroup = InteractionGroups.TERRAIN;
		}
		
	}
	
}