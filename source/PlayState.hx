package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import chars.*;

class PlayState extends FlxState
{
	var player:Player;
	var testChar:FlxSprite;

	public var npcsGroup:FlxTypedGroup<Intractable>;

	override public function create():Void
	{
		npcsGroup = new FlxTypedGroup<Intractable>();
		npcsGroup.add(new RedGuy(300, 300));
		add(npcsGroup);

		
		player = new Player();
		player.screenCenter();
		add(player);		
		
		super.create();
	}

	override public function update(elapsed:Float):Void
	{
		FlxG.collide(player, npcsGroup, function(d1, d2)
        {
            trace(" colliding hahahaha ??? " + FlxG.game.ticks);
        });
		super.update(elapsed);
	}
}
