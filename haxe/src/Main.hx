package;

import openfl.display.Sprite;
import openfl.display.Stage;
import js.Syntax;

class Main {
    static function main() {
        var stage = new Stage(640, 420);
        var card = new Sprite();
        card.x = 56;
        card.y = 52;
        card.graphics.beginFill(0x4CCB8A);
        card.graphics.drawRect(0, 0, 300, 180);
        card.graphics.endFill();
        stage.addChild(card);

        var dot = new Sprite();
        dot.x = 430;
        dot.y = 170;
        dot.graphics.beginFill(0xF5B942);
        dot.graphics.drawCircle(0, 0, 64);
        dot.graphics.endFill();
        stage.addChild(dot);

        Syntax.code("__swiftRender({0})", stage.commands);
        trace("OpenFL-compatible drawing commands sent to Swift");
    }
}
