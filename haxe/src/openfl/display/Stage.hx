package openfl.display;

class Stage extends Sprite {
    public var stageWidth:Int;
    public var stageHeight:Int;

    public function new(width:Int, height:Int) {
        super();
        stageWidth = width;
        stageHeight = height;
    }

    public function addChild(child:Sprite):Sprite {
        commands.push({
            kind: "child",
            x: child.x,
            y: child.y,
            color: child.fillColor,
            alpha: child.fillAlpha,
            commands: child.commands
        });
        return child;
    }
}
