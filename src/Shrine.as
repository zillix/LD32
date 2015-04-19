package 
{
	import com.zillix.zlxnape.BodyContext;
	import com.zillix.zlxnape.*;
	import nape.phys.BodyType;
	import nape.geom.Vec2;
	import nape.phys.Material;
	import org.flixel.FlxPoint;
	
	/**
	 * ...
	 * @author zillix
	 */
	public class Shrine extends ZlxNapeSprite 
	{
		[Embed(source = "data/shrine.png")]	public var ShrineSprite:Class;
		[Embed(source = "data/shrinePiece1.png")]	public var ShrineShard1:Class;
		
		[Embed(source = "data/shrineChunk.png")]	public var ShrineChunk:Class;
		
		public function Shrine(X:Number, Y:Number, Context:BodyContext)
		{
			super(X, Y);
			loadGraphic(ShrineSprite, true, false, 36, 40);
			scale.x = scale.y = 2;
			addAnimation("whole", [0]);
			addAnimation("broken", [1]);
			play("whole");
			createBody(width, height, Context, BodyType.STATIC, true, scale);
			collisionMask = InteractionGroups.ROCK;
			addCbType(CallbackTypes.SHRINE);
		}
		
		public function onRockHit() : void
		{
			play("broken");
			var shard:ZlxNapeSprite = new ZlxNapeSprite(x, y - height);
			shard.loadRotatedGraphic(ShrineShard1, 16);
			shard.scale = new FlxPoint(2, 2);
			shard.createBody(shard.width, shard.height, _bodyContext, null, true, shard.scale);
			
			shard.body.applyImpulse(Vec2.get(300, -300));
			shard.body.applyAngularImpulse(200);
			shard.setMaterial(new Material(0, 1, 2, Water.DENSITY + 2));
			
			PlayState.instance.rockLayer.add(shard);
			
			for (var i:int = 0; i < 3; i++)
			{
				var chunk:ZlxNapeSprite = new ZlxNapeSprite(x, y - height / 2);
				chunk.loadRotatedGraphic(ShrineChunk, 16);
				chunk.scale = new FlxPoint(2, 2);
				chunk.createBody(chunk.width, chunk.height, _bodyContext, null, true, chunk.scale);
				
				chunk.body.applyImpulse(Vec2.get(0, -30));
				chunk.body.applyAngularImpulse((Math.random() < .5 ? -1 : 1 ) * Math.random() * 200);
				chunk.setMaterial(new Material(0, 1, 2, Water.DENSITY + 2));
				PlayState.instance.rockLayer.add(chunk);
				
			}
		}
		
	}
	
}