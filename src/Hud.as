package 
{
	import org.flixel.FlxGroup;
	import org.flixel.FlxSprite;
	
	/**
	 * ...
	 * @author zillix
	 */
	public class Hud extends FlxGroup 
	{
		private var airBar:AirBar;
		public function Hud()
		{
			airBar = new AirBar(200, 10);
			add(airBar);
		}
		
		override public function update() : void
		{
			airBar.render(PlayState.instance.player.currentAir / PlayState.instance.player.maxAir);
		}
	}
	
}