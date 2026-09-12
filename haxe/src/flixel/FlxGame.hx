package flixel;

import openfl.display.Stage;
import js.Syntax;

class FlxGame {
    public var width:Int;
    public var height:Int;
    public var state:FlxState;
    public var stage:Stage;

    public function new(width:Int, height:Int, initialState:FlxState) {
        this.width = width;
        this.height = height;
        this.state = initialState;
        this.stage = new Stage(width, height);
        stage.addChild(state);
        Syntax.code("__swiftRender({0})", stage.commands);
    }

    public function step(elapsed:Float):Void {
        state.update(elapsed);
        stage.commands = [];
        stage.addChild(state);
        Syntax.code("__swiftRender({0})", stage.commands);
    }
}
