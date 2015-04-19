package 
{
	import org.flixel.FlxGroup;
	import org.flixel.*;
	import flash.utils.getTimer;
	
	/**
	 * ...
	 * @author zillix
	 */
	public class TitleScreen extends FlxGroup 
	{
		[Embed(source = "data/pixel-love.ttf", fontFamily = "pixel-love", embedAsCFF = "false")] 	public	var	PIXEL_LOVE:String;
		[Embed(source = "data/arrowKeys.png")]	public var ArrowSprites:Class;
		
		private var darkness:FlxSprite;
		private var endings:Vector.<FlxSprite> = new Vector.<FlxSprite>();
		private var titleText:GameText;
		private var zillixText:GameText;
		private var versionText:GameText;
		private var arrowSprite:FlxSprite;
		
		private var showVersionTime:int = 0;
		
		
		public function TitleScreen()
		{
			var endDist:Number = 200;
			for (var i:int = 0; i < PlayState.MAX_ENDINGS; ++i )
			{
				var x:int = FlxG.width / 2 - endDist / 2 + 66 * i;
				var end:FlxSprite = new FlxSprite(x, FlxG.height  / 2 - 60);
				end.makeGraphic(40, 40, PlayState.getEndColor(i));
				end.offset.x = end.width / 2;
				end.offset.y = end.height / 2;
				end.scrollFactor = new FlxPoint();
				add(end);
				if (!PlayState.instance.hasUnlockedEnding(i))
				{
					end.visible = false;
				}
				
			}
			
			titleText = new GameText(0, FlxG.height / 2 - 150, FlxG.width, "respire", true);
			titleText.setFormat("pixel-love", 48, 0xffffffff, "center");
			titleText.scrollFactor = new FlxPoint();
			add(titleText);
			
			zillixText = new GameText(0, FlxG.height / 2 + 120, FlxG.width, "made by zillix",true);
			zillixText.setFormat("pixel-love", 16, 0xffffffff, "center");
			zillixText.scrollFactor = new FlxPoint();
			add(zillixText)
			
			versionText = new GameText(0, FlxG.height / 2 + 140, FlxG.width, PlayState.instance.version, true);
			versionText.setFormat("pixel-love", 12, 0xffffffff, "center");
			versionText.scrollFactor = new FlxPoint();
			add(versionText)
			versionText.visible = false;
			versionText.alpha = 0;
			
			arrowSprite = new FlxSprite(FlxG.width / 2, FlxG.height / 2 + 35, ArrowSprites);
			add(arrowSprite);
			arrowSprite.offset.x = arrowSprite.width / 2;
			arrowSprite.offset.y = arrowSprite.height / 2;
			arrowSprite.scale = new FlxPoint(4, 4);
			
			showVersionTime = getTimer() + 15 * 1000;
		}
		
		public function set alpha(val:Number) : void
		{
			for each (var flxObj:FlxSprite in members)
			{
				flxObj.alpha = val;
			}
		}
		
		public function get alpha() : Number
		{
			return members[0].alpha;
		} 
		
		override public function update() : void
		{
			if (getTimer() > showVersionTime)
			{
				versionText.visible = true;
				versionText.alpha += FlxG.elapsed;
			}
		}
		
	}
	
}