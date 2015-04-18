package com.zillix.zlxnape.demos 
{
	import com.zillix.zlxnape.ConnectedPixelGroup;
	import com.zillix.zlxnape.ZlxNapeSprite;
	import com.zillix.zlxnape.InteractionGroups;
	import com.zillix.utils.ZMathUtils;
	
	import org.flixel.FlxG;
	
	import nape.geom.Vec2;
	import nape.phys.BodyType;
	/**
	 * ...
	 * @author zillix
	 */
	public class ConnectedPixelGroupDemo extends ZlxNapeDemo 
	{
		[Embed(source = "../../../../data/pixelTest4.png")]	public var PixelTest3:Class;
		
		protected var _connectedGroup:ConnectedPixelGroup;
		
		public function ConnectedPixelGroupDemo() 
		{
			_space.gravity.y = 0;
			
			var boxList:Vector.<ZlxNapeSprite> = new Vector.<ZlxNapeSprite>();
			var spawnedBox:ZlxNapeSprite;
			for (var i:int = 0; i < 8; i++)
			{
				for (var j:int = 0; j < 8; j++)
				{
					var amt:uint = (i * 8 + j);
					var blockColor:uint = 0xffff0000;
					if (amt % 3 == 0)
					{
						blockColor = 0xff00ff00;
					}
					else if (amt % 3 == 1)
					{
						blockColor = 0xff0000ff;
					}
					
					spawnedBox = spawnBox(100 + i * 30,
						100 + j * 30, 20, 0, blockColor);
					spawnedBox.collisionGroup = InteractionGroups.BOX;
					spawnedBox.collisionMask = ~InteractionGroups.BOX;
					boxList.push(spawnedBox);
				}
			}
			
			_connectedGroup = new ConnectedPixelGroup(_space, boxList);
			_connectedGroup.loadImage(PixelTest3);
			
		//	var anchor:ZlxNapeSprite = _connectedGroup.usedSprites[0];
		//	anchor.body.position.set(Vec2.weak(200, 10));
		//	anchor.body.type = BodyType.KINEMATIC;
		}
		
		override protected function doDebugDraw() : void
		{
			super.doDebugDraw();
			_connectedGroup.debugDraw(_debug);
		}
		
		
		override public function update() : void
		{
			super.update();
			
			if (FlxG.keys.SPACE)
			{
				_connectedGroup.contract(50 * FlxG.elapsed);
			}
		}
		
		override protected function get instructionsText() : String
		{
			return super.instructionsText + "\nSpace: Contract";
		}
	}

}