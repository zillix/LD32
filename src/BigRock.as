package 
{
	import com.zillix.zlxnape.BodyContext;
	import com.zillix.zlxnape.ZlxNapeSprite;
	import com.zillix.zlxnape.InteractionGroups;
	import com.zillix.zlxnape.CallbackTypes;
	import nape.phys.Material;
	import org.flixel.*;
	
	/**
	 * ...
	 * @author zillix
	 */
	public class BigRock extends ZlxNapeSprite 
	{
		[Embed(source = "data/bigRock.png")]	public var BigRockSprite:Class;
		
		private var fading:Boolean = false;
		
		public function BigRock(X:Number, Y:Number, Context:BodyContext)
		{
			super(X, Y);
			
			loadRotatedGraphic(BigRockSprite, 128, -1, false, true);
			scale.x = scale.y = 2;
			createBody(50, 20, Context);
			collisionGroup = collisionGroup | InteractionGroups.ROCK;
			fluidMask = 0;
			setMaterial(new Material(-5, 20, 20, .5, .001));
			addCbType(CallbackTypes.ROCK);
		}
		
		public function onTouchEnemy() : void
		{
				fading = true;
		}
		
		override public function update() : void
		{
			super.update();
			if (fading)
			{
				alpha -= FlxG.elapsed * 1;
				if (alpha <= 0)
				{
					kill();
				}
			}
		}
	}
	
}