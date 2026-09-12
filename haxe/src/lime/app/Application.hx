package lime.app;

class Application {
    public var window:Dynamic;
    public var onUpdate:Float->Void;
    private var running:Bool = false;

    public function new() {}

    public function create(width:Int, height:Int):Void {
        window = { width: width, height: height };
        running = true;
    }

    public function update(delta:Float):Void {
        if (running && onUpdate != null) onUpdate(delta);
    }
}
