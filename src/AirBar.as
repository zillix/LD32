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
		
		public function AirBar(X:Number, Y:Number)
		{
			super();
			
			outline = new FlxSprite(X - OUTLINE_BUFFER, Y - OUTLINE_BUFFER);
			outline.makeGraphic(DEFAULT_LENGTH + OUTLINE_BUFFER * 2, BAR_HEIGHT + OUTLINE_BUFFER * 2, 0x99000000);
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
			innerBar.width = fraction * outerBar.width;
			innerBar.scale.x = innerBar.width / DEFAULT_LENGTH;
			outerBar.scale.x = outerBar.width / DEFAULT_LENGTH;
			
			outline.width = outerBar.width + OUTLINE_BUFFER;
			outline.scale.x = outline.width / (DEFAULT_LENGTH + OUTLINE_BUFFER)
			super.update();
			
		}
		
		
		
		
		
		
		
		
		
		
	}
	
}