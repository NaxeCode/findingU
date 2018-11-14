package;

import flixel.FlxG;
import flixel.FlxSprite;

class Intractable extends FlxSprite
{
    public function new(?X:Int = 0, ?Y:Int = 0)
    {
        super(X, Y);

        immovable = true;
    }

    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);
    }
}