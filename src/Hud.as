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
			airBar = new AirBar(FlxG.width / 2 - 100, FlxG.height / 2 - 20);
			airBar.alpha = 0;
			add(airBar);
			
			textUI = new TextUI(0, 70);
			add(textUI);
		}
		
		override public function update() : void
		{
			super.update();
			airBar.render(PlayState.instance.player.currentAir / PlayState.instance.player.maxAir);
			
			if (PlayState.instance.endingGame)
			{
				airBar.visible = false;
			}
			
			
			if (PlayState.instance.activeOrb)
			{
				textUI.visible = true;
				textUI.setY(Math.max(0, 
					Math.min(
						FlxG.height - 70, PlayState.instance.activeOrb.y - FlxG.camera.scroll.y)));
			}
			else if (PlayState.instance.showEndText)
			{
				textUI.visible = true;
				textUI.setY(FlxG.height / 2 - 35);
			}
			else
			{
				textUI.visible = false;
			}
			
			/*if (PlayState.instance.player.currentAir < PlayState.instance.player.maxAir 
			&& PlayState.instance.player.severed)
			{
				airBar.alpha += FlxG.elapsed * 1;
			}
			else
			{
				airBar.alpha -= FlxG.elapsed * 1;
			}*/
			if (PlayState.instance.player.severed)
			{
				airBar.alpha = .5;
			}
			if (PlayState.instance.player.currentAir < PlayState.instance.player.maxAir / 2)
			{
				airBar.setExhausted(true);
			}
			else
			{
				airBar.setExhausted(false);
			}
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