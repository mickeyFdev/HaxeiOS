package flixel;

import openfl.display.Sprite;

class FlxSprite extends Sprite {
    public var velocityX:Float = 0;
    public var velocityY:Float = 0;
    public var width:Float = 32;
    public var height:Float = 32;

    public function new(x:Float = 0, y:Float = 0, color:Int = 0xFFFFFF) {
        super();
        this.x = x;
        this.y = y;
        fillColor = color;
        graphics.beginFill(color);
        graphics.drawRect(0, 0, width, height);
        graphics.endFill();
    }

    public function update(elapsed:Float):Void {
        x += velocityX * elapsed;
        y += velocityY * elapsed;
    }
}
