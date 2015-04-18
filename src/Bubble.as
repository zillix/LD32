package 
{
	import com.zillix.zlxnape.BodyContext;
	import com.zillix.zlxnape.*;
	import flash.display.Shape;
	import flash.utils.getTimer;
	import nape.phys.Body;
	import nape.shape.Circle;
	
	/**
	 * ...
	 * @author zillix
	 */
	public class Bubble extends ZlxNapeSprite 
	{
		[Embed(source = "data/bubble.png")]	public var BubbleSprite:Class;
		
		public var radius:Number = 0;
		public var initialRadius:Number;
		
		public var LIFESPAN:Number = 3;
		public var SHRINK_LIFESPAN:Number = 1;
		
		private var _deathTime:Number = 0;
		
		public function Bubble(X:Number, Y:Number, Radius:Number, Context:BodyContext)
		{
			super(X, Y);
			radius = Radius;
			createCircleBody(Radius, Context);
			loadGraphic(BubbleSprite);
			
			initialRadius = Radius;
			setRadius(Radius);
			
			collisionMask = ~(InteractionGroups.NO_COLLIDE);
			collisionGroup = InteractionGroups.BUBBLE;
			
			_deathTime = getTimer() + LIFESPAN * 1000;
		}
		
		override public function update() : void
		{
			super.update();
			
			var time:int = getTimer();
			if (time > _deathTime)
			{
				var killTime:Number = _deathTime + SHRINK_LIFESPAN * 1000;
				if (time > killTime)
				{
					this.kill();
					return;
				}
				
				setRadius((1 - (time - _deathTime) / (SHRINK_LIFESPAN * 1000)) * initialRadius);
				
			}
		}
		
		private function setRadius(Radius:Number) : void
		{
			radius = Radius;
			offset.x = offset.y = radius;
			scale.x = scale.y = radius * 2 / 10;
			
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