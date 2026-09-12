package openfl.display;

class Sprite {
    public var x:Float = 0;
    public var y:Float = 0;
    public var fillColor:Int = 0xFFFFFF;
    public var fillAlpha:Float = 1.0;
    public var commands:Array<Dynamic> = [];
    public var graphics(default, null):Graphics;

    public function new() {
        graphics = new Graphics(this);
    }
}
