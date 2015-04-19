package 
{
	import org.flixel.*;
	
	/**
	 * ...
	 * @author ...
	 */
	public class AirBar extends FlxGroup
	{
		public var outerBar:FlxSprite;
		private var innerBar:FlxSprite;
		private var outline:FlxSprite;
		
		private var DEFAULT_LENGTH:Number = 200;
		private var BAR_HEIGHT:Number = 20;
		private var OUTLINE_BUFFER:Number = 4;
		
		private var _currentFraction:Number = 1;
		
		private var AIR_BAR_COLOR:uint = 0xff5EECEB;
		private var EXHAUSTED_COLOR:uint = 0xffff0000;
		private var BAR_RATE:Number = 1;
		
		public function AirBar(X:Number, Y:Number)
		{
			super();
			
			outline = new FlxSprite(X - OUTLINE_BUFFER, Y - OUTLINE_BUFFER);
			outline.makeGraphic(DEFAULT_LENGTH + OUTLINE_BUFFER * 2, BAR_HEIGHT + OUTLINE_BUFFER * 2, 0x99dddddd);
			outline.scrollFactor.x = outline.scrollFactor.y = 0;
			add(outline);
			
			outerBar = new FlxSprite(X, Y);
			outerBar.makeGraphic(DEFAULT_LENGTH, BAR_HEIGHT, 0xffEC5E60);
			outerBar.scrollFactor.x = outerBar.scrollFactor.y = 0;
			
			innerBar = new FlxSprite(X, Y);
			innerBar.makeGraphic(DEFAULT_LENGTH, BAR_HEIGHT, 0xff5EECEB);
			innerBar.scrollFactor.x = innerBar.scrollFactor.y = 0;
			add(innerBar);
		}
		
		
		
		public function render(fraction:Number):void 
		{
			if (_currentFraction < fraction)
			{
				_currentFraction = Math.max(fraction, _currentFraction + BAR_RATE * FlxG.elapsed);
			}
			
			if (_currentFraction > fraction)
			{
				_currentFraction = Math.min(fraction, _currentFraction - BAR_RATE * FlxG.elapsed);
			}
			
			innerBar.width = _currentFraction * outerBar.width;
			innerBar.scale.x = innerBar.width / DEFAULT_LENGTH;
			outerBar.scale.x = outerBar.width / DEFAULT_LENGTH;
			
			outline.width = outerBar.width + OUTLINE_BUFFER;
			outline.scale.x = outline.width / (DEFAULT_LENGTH + OUTLINE_BUFFER)
			super.update();
			
			
			
		}
		
		public function flicker() : void
		{
			for each (var flxObj:FlxSprite in members)
			{
				flxObj.flicker();
			}
		}
		
		public function setExhausted(bool:Boolean) : void
		{
			if (bool)
			{
				innerBar.color = EXHAUSTED_COLOR;
			}
			else
			{
				innerBar.color = AIR_BAR_COLOR;
			}
		}
		
	}
	
}