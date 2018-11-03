package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxPoint;

class Player extends FlxSprite
{
    var up:Bool = false;
    var down:Bool = false;
    var left:Bool = false;
    var right:Bool = false;

    var speed:Int = 200;

    var canMove:Bool = true;

    public function new()
    {
        super();

        makeGraphic(32, 32);
        
        drag.x = drag.y = 1600;
    }

    override public function update(elapsed:Float):Void
    {
        handleMovement();
        super.update(elapsed);
    }

    function handleMovement()
    {
        if (!canMove)
            return;
        
        up = FlxG.keys.anyPressed([UP, W]);
        down = FlxG.keys.anyPressed([DOWN, S]);
        left = FlxG.keys.anyPressed([LEFT, A]);
        right = FlxG.keys.anyPressed([RIGHT, D]);

        if (up && down)
            up = down = false;
        if (left && right)
            left = right = false;
        
        if (up || down || left || right)
        {
            var maxAccel:Float = 0;
            if (up)
            {
                maxAccel = -90;
                if (left)
                    maxAccel -= 45;
                else if (right)
                    maxAccel += 45;
            }
            else if (down)
            {
                maxAccel = 90;
                if (left)
                    maxAccel += 45;
                else if (right)
                    maxAccel -= 45;
            }
            else if (left)
                maxAccel = 180;
            else if (right)
                maxAccel = 0;
            
            velocity.set(speed, 0);
            velocity.rotate(FlxPoint.weak(0, 0), maxAccel);
        }

        //if (up)
    }
}