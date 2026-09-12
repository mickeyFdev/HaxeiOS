package flixel;

import openfl.display.Sprite;

class FlxState extends Sprite {
    public var members:Array<FlxSprite> = [];

    public function new() {
        super();
    }

    public function add(sprite:FlxSprite):FlxSprite {
        members.push(sprite);
        commands.push({
            kind: "child",
            x: sprite.x,
            y: sprite.y,
            color: sprite.fillColor,
            alpha: sprite.fillAlpha,
            commands: sprite.commands
        });
        return sprite;
    }

    public function update(elapsed:Float):Void {
        for (sprite in members) sprite.update(elapsed);
        commands = [];
        for (sprite in members) {
            commands.push({
                kind: "child",
                x: sprite.x,
                y: sprite.y,
                color: sprite.fillColor,
                alpha: sprite.fillAlpha,
                commands: sprite.commands
            });
        }
    }
}
