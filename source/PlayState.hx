package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.FlxSprite;

class PlayState extends FlxState
{
	var player:Player;
	var testChar:FlxSprite;

	override public function create():Void
	{
		player = new Player();
		player.screenCenter();
		add(player);

		testChar = new FlxSprite(300, 300);
		testChar.makeGraphic(64, 64, 0xFFFF0000);
		add(testChar);
		
		super.create();
	}

	override public function update(elapsed:Float):Void
	{
		FlxG.overlap(player, testChar, function(d1, d2) {
			if (FlxG.keys.justPressed.SPACE)
				trace("Yo whassup");
		});

		super.update(elapsed);
	}
}
