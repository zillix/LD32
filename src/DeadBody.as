package 
{
	import com.zillix.zlxnape.BodyContext;
	import com.zillix.zlxnape.ZlxNapeSprite;
	import com.zillix.zlxnape.CallbackTypes;
	import nape.phys.BodyType;
	
	/**
	 * ...
	 * @author zillix
	 */
	public class DeadBody extends ZlxNapeSprite 
	{
		[Embed(source = "data/deadBody.png")]	public var DeadSprite:Class;
		
		public function DeadBody(X:Number, Y:Number, Context:BodyContext)
		{
			super(X, Y);
			loadGraphic(DeadSprite);
			scale.x = scale.y = 2;
			createBody(width, height, Context, BodyType.STATIC);
			addCbType(CallbackTypes.DEADBODY);
		}
		
	}
	
}