package 
{
	import org.flixel.FlxGroup;
	import org.flixel.*;
	
	/**
	 * ...
	 * @author zillix
	 */
	public class Hud extends FlxGroup 
	{
		private var airBar:AirBar;
		public var textUI:TextUI;
		public function Hud()
		{
			airBar = new AirBar(200, 10);
			add(airBar);
			
			textUI = new TextUI(FlxG.height - 70, 70);
			add(textUI);
		}
		
		override public function update() : void
		{
			super.update();
			airBar.render(PlayState.instance.player.currentAir / PlayState.instance.player.maxAir);
		}
		
		public function onPlayerDamage() : void
		{
			airBar.flicker();
		}
		
		public function setPlayerExhausted(exhausted:Boolean) : void
		{
			airBar.setExhausted(exhausted);
		}
	}
	
}