package 
{
	import com.zillix.zlxnape.BodyContext;
	import com.zillix.zlxnape.ZlxNapeSprite;
	import nape.geom.Vec2;
	import org.flixel.FlxGroup;
	import org.flixel.*;
	
	/**
	 * ...
	 * @author zillix
	 */
	public class Tentacle extends FlxGroup
	{
		private var _node:FlxSprite;
		private var _chain:BodyChain;
		private var _fading:Boolean = true;
		
		public static const FADE_RATE:Number = 1;
		private var _alpha:Number = 1;
		
		public function Tentacle(node:FlxSprite, chains:BodyChain)
		{
			super();
			_node = node;
			_chain = chains;
		}
		
		override public function update() : void
		{
			super.update();
			
			if (_fading)
			{
				_alpha -= FlxG.elapsed * FADE_RATE;
				_node.alpha = _alpha;
				_chain.alpha = _alpha;
				
				if (_alpha <= 0)
				{
					_node.kill();
					_chain.kill();
					this.kill();
				}
			}
		}
	}
	
}