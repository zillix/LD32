package 
{
	import org.flixel.*;
	[SWF(width="640", height="480", backgroundColor="#000000")]
	[Frame(factoryClass="Preloader")]
	public class Main extends FlxGame
	{
		public function Main():void
		{
			super(640, 480, PlayState, 1);
		}
	}
}