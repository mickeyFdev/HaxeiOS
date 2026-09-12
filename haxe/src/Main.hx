package;

class Main {
    static function main() {
        var language = "Haxe";
        var platform = "iOS Swift Playground";
        var values = [1, 2, 3, 4, 5];
        var total = 0;

        for (value in values) {
            total += value;
        }

        trace(language + " is running in " + platform);
        trace("sum(1...5) = " + total);
    }
}
