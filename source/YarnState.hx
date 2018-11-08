package;

import flixel.util.FlxSave;
import haxe.Json;
import openfl.Assets;
import hscript.Interp;
import hscript.Parser;

class YarnState
{
    public var title:String;
    var body:String;
    public var transitions:Map<String,String>;
    public var message:String;
    public var choices:Array<String>;
    var controller:Yarn;


    public function run_parse():Void
    {
        this.transitions = new Map();
        this.message = "";

        var code = this.body;

        var code_rgx = ~/<<([a-z]+) (.*?)>>/g;
        var var_rgx = ~/^([a-zA-Z0-9_]+) = (.*)$/;
        var str = code_rgx.map(code, function(r) 
        {
	        var line = r.matched(0);
	        var mod  = r.matched(1);
            var args = r.matched(2);

	        if (mod == "print")
            {
	            var result = controller.interp.expr(controller.parser.parseString(args));
	            return Std.string(result);
	        } 
            else if (mod == "run")
            {
	            controller.interp.expr(controller.parser.parseString(args));
	            return "";
	        }
            else if (mod == "clear")
            {
	            controller.interp.execute(controller.parser.parseString("1;"));
	            return "";
	        }
            else if (mod == "include")
            {
	            var thestate=controller.states[args];
	            thestate.run_parse();
	            return thestate.message;
	        }
            else if (mod == "var")
            {
	            if (var_rgx.match(args))
                {
	                var var_str = var_rgx.matched(1);
	                var val_str = var_rgx.matched(2);
    
	                var val = controller.interp.expr(controller.parser.parseString(val_str));
                    controller.interp.variables.set(var_str,val);
	            } 
                else
	                return "SYNTAX ERROR";

	            return "";
	        } 
            else
	            return "UNKNOWN MACRO";
        });

        var link_rgx = ~/\[\[(.*?)\|(.*?)\]\]/g;
        while (link_rgx.match(str))
        {
            this.transitions[link_rgx.matched(1)]=link_rgx.matched(2);
            this.message+=link_rgx.matchedLeft();      
            if (controller.echo())
            {
	            this.message+=link_rgx.matched(1);
            }
            str = link_rgx.matchedRight();
        }

        this.message += str;
        this.choices = [for (a in this.transitions.keys()) a];
    }

    public function new(title:String, body:String, controller:Yarn)
    {
        this.title = title;
        this.body = body;
        this.transitions = new Map();
        this.message = "";
        this.controller = controller;
    }
}

class Yarn
{
    public var states:Map<String,YarnState>;
    var vars:Map<String,String>;
    var state:YarnState;
    public var parser:hscript.Parser;
    public var interp:hscript.Interp;
    //private var _gameSave:FlxSave;
    var name:String;
    private var echo_links:Bool=false;

    public function new(path:String,name:String)
    {
    
        parser = new hscript.Parser();
        interp = new hscript.Interp();
        interp.execute(parser.parseString("1;"));

        this.name = name;

        var json_src = Assets.getText(path);
        var parsed:Array<Dynamic> = Json.parse(json_src);
        var body:String;
        var title:String;
        states = new Map();
        vars = new Map();
    
        for(state in parsed)
        {
            body = state.body;
            title = state.title;
            states[title] = new YarnState(title, body, this);
        }
        state = states["Start"];
        state.run_parse();
    }

    public function setState(title:String):Void
    {
        state = states[title];
        state.run_parse();
    }

    public function message():String
    {
        return state.message;
    }

    public function echo():Bool
    {
        return echo_links;
    }

    public function transition(choice:String):Void
    {
        state = states[state.transitions[choice]];
        state.run_parse();
    }

    public function choices():Array<String>
    {
        return state.choices;
    }

  /*
  public function saveIn(saveObj:FlxSave){
    saveObj.data.yarnStates[name]=state.title;
    saveObj.data.yarnVars[name]=vars;   
  }
  public function loadFrom(saveObj:FlxSave){
    state=states[saveObj.data.yarnStates[name]];
    vars=saveObj.data.yarnVars[name];   
  }
  */

}