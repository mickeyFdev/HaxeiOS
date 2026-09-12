package;

import flixel.FlxGame;
import flixel.FlxSprite;
import flixel.FlxState;
import lime.app.Application;

class Main {
    static function main() {
        var limeApp = new Application();
        limeApp.create(640, 420);

        var state = new FlxState();
        var player = new FlxSprite(56, 52, 0x4CCB8A);
        player.velocityX = 48;
        state.add(player);

        var enemy = new FlxSprite(430, 170, 0xF5B942);
        state.add(enemy);

        var game = new FlxGame(640, 420, state);
        game.step(1.0 / 60.0);
        trace("Lime + HaxeFlixel-compatible game loop is running");
    }
}
