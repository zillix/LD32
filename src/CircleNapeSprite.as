package 
{
	import com.zillix.zlxnape.BodyContext;
	import com.zillix.zlxnape.ZlxNapeSprite;
	import nape.shape.Circle;
	
	
	/**
	 * ...
	 * @author zillix
	 */
	public class CircleNapeSprite extends ZlxNapeSprite 
	{
		[Embed(source = "data/bubble.png")]	public var BubbleSprite:Class;
		
		public var radius:Number = 0;
		private var _initialWidth:int = 0;
		
		public function CircleNapeSprite(X:Number, Y:Number, Context:BodyContext, Radius:int, Image:Class = null)
		{
			super(X, Y);
			
			createCircleBody(Radius, Context);
			
			if (!Image)
			{
				Image = BubbleSprite;
			}
			
			loadGraphic(Image);
			_initialWidth = width;
			setRadius(Radius);
		}
		
		public function setRadius(Radius:Number) : void
		{
			radius = Radius;
			offset.x = offset.y = .5 * radius;
			scale.x = scale.y = radius * 2 / _initialWidth;
			
			if (radius > .01)
			{
				for (var i:int = 0; i < _body.shapes.length; ++i )
				{
					var circle:Circle = _body.shapes.at(i) as Circle;
					if (circle)
					{
						circle.radius = radius;
					}
				}
			}
		}
	}
	
}