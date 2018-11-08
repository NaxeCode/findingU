package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxMath;
import flixel.util.FlxAngle;
import flixel.util.FlxSave;
import flixel.util.FlxPoint;
import flixel.plugin.MouseEventManager;

private class CartoonBubble extends FlxSprite
{

    private var dialog:FlxYarn;
    private var parent:FlxObject;
    private var content:String;
  
    public function new(content:String, dialog:FlxYarn, ?parent:FlxObject, x:Float, y:Float)
    {

        var w = 100;
        var h = 80;
        x -= w / 2;

        if(parent != null)
        {
            var pt = cast(parent, FlxSprite).getGraphicMidpoint();
     
            if (pt.x < x)
	            x-=20;
            else
	            x+=20;
        }

        super(x, y);

        loadGraphic(this.graphicPath(),false,w,h,true);

        if(parent != null)
        {
          var pt = cast(parent, FlxSprite).getGraphicMidpoint();

          var tag = new FlxSprite(0, 0);
          tag.loadGraphic(this.tagPath());
          tag.angle = FlxAngle.getAngle(pt, this.getGraphicMidpoint());

          if (pt.x < x)
	        this.stamp(tag, 0, 50);
          else
	        this.stamp(tag, 70, 50);
        }

        var text = new FlxText(0, 0, 80, content);
        text.setFormat(null, 8, 0x000000, "center");
        this.stamp(text, 10, 15);

        this.parent = parent;
        this.dialog = dialog;
        this.content = content;
    }

    private function tagPath():String
    {
      return "assets/images/say.png";
    }

    private function graphicPath():String
    {
      return "assets/images/speech2.png";
    }

    public function onMouseDown(sprite:FlxSprite)
    {
      this.onClick();
      MouseEventManager.remove(this);
      destroy();
    }

    public function onClick() { }
}

private class SoundBubble extends CartoonBubble
{
    override private function graphicPath():String
    {
        return "assets/images/sound3.png";
    }
}


private class SpeechBubble extends CartoonBubble
{
    override private function graphicPath():String
    {
      return "assets/images/speech3.png";
    }  

    override private function tagPath():String
    {
      return "assets/images/say.png";
    }
}

private class ThoughtBubble extends CartoonBubble
{
    override private function tagPath():String
    {
      return "assets/images/think.png";
    }

    override private function graphicPath():String
    {
      return "assets/images/thought3.png";
    }  

    override public function onClick()
    {
      this.dialog.action(this.content);
    }
}

class FlxYarn
{
    var characters:Map<String,FlxObject>;
    var conversation:String;
    var yarn:Yarn;
    var protagonist:FlxObject;
    var bubbles:Array<CartoonBubble>;
    var state:FlxState;
    var x:Float;
    var y: Float;
    var index:Int;
    var ticks:Int;


    public function new(path:String, name:String, chars:Map<String, FlxObject>, state:FlxState, mainChar:FlxObject, x:Float, y:Float)
    { 
        this.yarn = new Yarn(path, name);
        this.characters = chars;
        this.state = state;
        this.protagonist = mainChar;
        this.bubbles = new Array();
        this.x = x;
        this.y = y;
    }

    public function destroyBubbles()
    {
        for(bubble in this.bubbles)
        {
            bubble.destroy();
        }
        this.bubbles = new Array();
    }

    public function createBubbles()
    {
        this.destroyBubbles();
        this.index = 0;
        this.ticks = 0;

        this.conversation = this.yarn.message();

        var line_rgx = ~/^([a-zA-Z0-9]+): (.*)$/m ;
        var sound_rgx = ~/^\*(.*)\*$/m ;

        var name:String;
        var quip:String;
        var sb:CartoonBubble;
        var y1 = y;

        var lines = this.conversation.split("\n");

        for (line in lines)
        {
            if (line_rgx.match(line))
            {
        	    name = line_rgx.matched(1);
        	    quip = line_rgx.matched(2);

        	    sb = new SpeechBubble(quip, this, this.characters[name], x, y1);
        	    this.bubbles.push(sb);
        	    y1+ = 80;
            }
            if (sound_rgx.match(line))
            {


        	    quip = sound_rgx.matched(1);

        	    sb = new SoundBubble(quip, this, null, x, y1);
        	    this.bubbles.push(sb);
        	    y1+ = 80;
            }
        }

        var x1 = this.protagonist.x + (this.protagonist.x - x);
        y1 = y;
        var tb:ThoughtBubble;
        for(choice in this.yarn.choices())
        {
          sb = new ThoughtBubble(choice, this, this.protagonist, x1, y1);
          y1 += 80;
          this.bubbles.push(sb);
        }
    }

    public function update()
    {
        if(this.index < this.bubbles.length)
        {
            if(this.ticks > 50)
            {
    	        this.state.add(this.bubbles[this.index]);
    	        MouseEventManager.add(this.bubbles[this.index], this.bubbles[this.index].onMouseDown, null, null, null);
    	        this.index += 1;
    	        this.ticks = 0;
            } 
            else
    	        this.ticks += 1;
        }
    }

    public function action(option)
    {
        yarn.transition(option);
        this.createBubbles();
    }
}