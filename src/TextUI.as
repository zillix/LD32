package 
{
	import org.flixel.*;
	
	/**
	 * ...
	 * @author zillix
	 */
	public class TextUI extends FlxGroup 
	{
		public var background:FlxSprite;
		public var text:GameText;
		public var textPlayer:TextPlayer = new TextPlayer();
		
		
		[Embed(source="/data/HACHEA__.ttf", fontFamily="HACHEA", embedAsCFF="false")] 	public	var	HACHEA:String;
		
		
		public function TextUI(offsetY:Number = 100, Height:int = 70)
		{
			background = new FlxSprite(0, offsetY);
			background.makeGraphic(FlxG.width, Height, 0x88888888);
			background.scrollFactor = new FlxPoint(0, 0);
			add(background);
			
			text = new GameText(0, offsetY + 12, FlxG.width, null, true);
			text.setFormat("HACHEA", 20, 0xff000000, "center");
			text.shadow = 0xff888888;
			text.scrollFactor = new FlxPoint(0, 0);
			add(text);
		}
		
		override public function update():void
		{
			/*if (parent == null)
			{
				visible = false;
			}*/
			
			super.update();
			
			textPlayer.update();
			
			text.text = textPlayer.currentText;
			text.color = textPlayer.currentColor;
		}
	}
	
}