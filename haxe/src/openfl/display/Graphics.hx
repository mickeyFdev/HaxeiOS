package openfl.display;

class Graphics {
    private var owner:Sprite;

    public function new(owner:Sprite) {
        this.owner = owner;
    }

    public function clear():Void {
        owner.commands = [];
    }

    public function beginFill(color:Int, alpha:Float = 1.0):Void {
        owner.fillColor = color;
        owner.fillAlpha = alpha;
    }

    public function endFill():Void {}

    public function drawRect(x:Float, y:Float, width:Float, height:Float):Void {
        owner.commands.push({ kind: "rect", x: x, y: y, width: width, height: height });
    }

    public function drawCircle(x:Float, y:Float, radius:Float):Void {
        owner.commands.push({ kind: "circle", x: x, y: y, radius: radius });
    }
}
