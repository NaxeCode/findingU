package chars;

class RedGuy extends Intractable
{
    public function new(?X:Int = 0, ?Y:Int = 0)
    {
        super(X, Y);

        makeGraphic(64, 64, 0xFFFF0000);

    }
}