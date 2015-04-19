package 
{
	
	/**
	 * ...
	 * @author zillix
	 */
	public class PlayText 
	{
		public static const DEFAULT_DURATION:Number = 3;
		public static const DEFAULT_TEXT_COLOR:uint = 0xffffff;
		public var text:String;
		public var duration:Number;
		public var callback:Function;
		public var color:uint = DEFAULT_TEXT_COLOR;
		
		public function PlayText(Text:String = "", Duration:Number = 0, Callback:Function = null, Color:uint = DEFAULT_TEXT_COLOR)
		{
			text = Text;
			duration = Duration;
			callback = Callback;
			color = Color;
		}
		
		
		
		public static function addText(vec:Vector.<PlayText>, text:String, duration:int = -1, callback:Function = null, color:uint = 0x00000000) : void
		{
			if (color == 0x00000000)
			{
				color = DEFAULT_TEXT_COLOR
			}
			
			if (duration < 0)
			{
				duration = PlayText.DEFAULT_DURATION;
			}
			
			vec.push(new PlayText(text, duration, callback, color));
		}
	}
	
}