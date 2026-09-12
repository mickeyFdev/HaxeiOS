import Foundation
import JavaScriptCore
import PlaygroundSupport

final class HaxePlaygroundRuntime {
    private let context: JSContext

    init() {
        context = JSContext()!

        context.exceptionHandler = { _, exception in
            let message = exception?.toString() ?? "Unknown JavaScript exception"
            print("[Haxe exception] \(message)")
        }

        // Haxeのtrace()はconsole.logへ出力される。
        let log: @convention(block) (String) -> Void = { message in
            print("[Haxe] \(message)")
        }
        context.setObject(log, forKeyedSubscript: "__swiftLog" as NSString)
        context.evaluateScript("var console = { log: function(value) { __swiftLog(String(value)); } };")
    }

    func run() {
        guard let url = Bundle.main.url(forResource: "main", withExtension: "js") else {
            print("main.js not found. Run scripts/build.sh before opening the Playground.")
            return
        }

        do {
            let source = try String(contentsOf: url, encoding: .utf8)
            context.evaluateScript(source, withSourceURL: url)
        } catch {
            print("Could not load main.js: \(error)")
        }
    }
}

let runtime = HaxePlaygroundRuntime()
runtime.run()
PlaygroundPage.current.needsIndefiniteExecution = false
