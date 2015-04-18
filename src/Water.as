package 
{
	import com.zillix.zlxnape.BodyContext;
	import com.zillix.zlxnape.*;
	import nape.phys.BodyType;
	import nape.phys.FluidProperties;
	
	/**
	 * ...
	 * @author zillix
	 */
	public class Water extends ZlxNapeSprite 
	{
		public function Water(X:Number, Y:Number, Width:Number, Height:Number, Context:BodyContext)
		{
			super(X, Y);
			createBody(Width, Height, Context, BodyType.STATIC);
			var fluidProperties:FluidProperties = new FluidProperties(3, 4);
			body.setShapeFluidProperties(fluidProperties);
			collisionMask = 0;
			fluidMask = ~InteractionGroups.NO_COLLIDE;
			fluidEnabled = true;
	
		}
	}
	
}