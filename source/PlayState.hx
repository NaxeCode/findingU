package;

import flixel.FlxState;

class PlayState extends FlxState
{
	var player:Player;

	override public function create():Void
	{
		player = new Player();
		player.screenCenter();
		add(player);
		
		super.create();
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
	}
}
