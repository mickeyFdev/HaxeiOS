import UIKit
import Foundation
import JavaScriptCore
import PlaygroundSupport

final class HaxeRuntime {
    private let context: JSContext
    var onLog: ((String) -> Void)?

    init() {
        context = JSContext()!
        context.exceptionHandler = { [weak self] _, exception in
            self?.onLog?("[exception] \(exception?.toString() ?? "Unknown JavaScript exception")")
        }

        let log: @convention(block) (String) -> Void = { [weak self] value in
            self?.onLog?(value)
        }
        context.setObject(log, forKeyedSubscript: "__swiftLog" as NSString)
        context.evaluateScript("var console = { log: function(value) { __swiftLog(String(value)); } };")
    }

    func run(bundle: Bundle = .main) {
        guard let url = bundle.url(forResource: "main", withExtension: "js") else {
            onLog?("main.js がありません。Macで scripts/build.sh を実行してください。")
            return
        }
        do {
            let source = try String(contentsOf: url, encoding: .utf8)
            context.evaluateScript(source, withSourceURL: url)
        } catch {
            onLog?("[load error] \(error.localizedDescription)")
        }
    }
}

final class IDEViewController: UIViewController, UITextViewDelegate {
    private let editor = UITextView()
    private let output = UITextView()
    private let status = UILabel()
    private let runtime = HaxeRuntime()

    private let source = """package;\n\nclass Main {\n    static function main() {\n        trace(\"Hello from Haxe\");\n    }\n}\n"""

    override func loadView() {
        view = UIView()
        view.backgroundColor = UIColor(red: 0.055, green: 0.067, blue: 0.086, alpha: 1)
        setupIDE()
    }

    private func setupIDE() {
        let top = UIView()
        top.backgroundColor = UIColor(red: 0.10, green: 0.12, blue: 0.15, alpha: 1)
        top.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(top)

        let brand = UILabel()
        brand.text = "  Haxe iOS  ›  Playground"
        brand.textColor = .white
        brand.font = .monospacedSystemFont(ofSize: 15, weight: .semibold)
        brand.translatesAutoresizingMaskIntoConstraints = false
        top.addSubview(brand)

        let run = UIButton(type: .system)
        run.setTitle("▶ Run", for: .normal)
        run.setTitleColor(UIColor(red: 0.40, green: 0.86, blue: 0.62, alpha: 1), for: .normal)
        run.titleLabel?.font = .monospacedSystemFont(ofSize: 14, weight: .bold)
        run.addTarget(self, action: #selector(runHaxe), for: .touchUpInside)
        run.translatesAutoresizingMaskIntoConstraints = false
        top.addSubview(run)

        let sidebar = UILabel()
        sidebar.text = "  EXPLORER\n\n  ▾ haxe\n      ▾ src\n          Main.hx\n      build.hxml\n\n  ▾ playground\n      Contents.swift"
        sidebar.textColor = UIColor(red: 0.66, green: 0.70, blue: 0.76, alpha: 1)
        sidebar.font = .monospacedSystemFont(ofSize: 12, weight: .regular)
        sidebar.numberOfLines = 0
        sidebar.backgroundColor = UIColor(red: 0.075, green: 0.09, blue: 0.115, alpha: 1)
        sidebar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(sidebar)

        let tab = UILabel()
        tab.text = "  Main.hx   ×"
        tab.textColor = .white
        tab.font = .monospacedSystemFont(ofSize: 13, weight: .medium)
        tab.backgroundColor = UIColor(red: 0.12, green: 0.14, blue: 0.18, alpha: 1)
        tab.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tab)

        editor.text = source
        editor.delegate = self
        editor.textColor = UIColor(red: 0.86, green: 0.89, blue: 0.93, alpha: 1)
        editor.backgroundColor = UIColor(red: 0.055, green: 0.067, blue: 0.086, alpha: 1)
        editor.font = .monospacedSystemFont(ofSize: 15, weight: .regular)
        editor.autocorrectionType = .no
        editor.autocapitalizationType = .none
        editor.alwaysBounceVertical = true
        editor.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(editor)

        let outputTitle = UILabel()
        outputTitle.text = "  TERMINAL  ·  Haxe output"
        outputTitle.textColor = UIColor(red: 0.65, green: 0.72, blue: 0.80, alpha: 1)
        outputTitle.font = .monospacedSystemFont(ofSize: 11, weight: .bold)
        outputTitle.backgroundColor = UIColor(red: 0.10, green: 0.12, blue: 0.15, alpha: 1)
        outputTitle.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(outputTitle)

        output.text = "Haxe iOS Playground\nReady. Press Run to execute generated JavaScript.\n"
        output.textColor = UIColor(red: 0.40, green: 0.86, blue: 0.62, alpha: 1)
        output.backgroundColor = UIColor(red: 0.035, green: 0.043, blue: 0.055, alpha: 1)
        output.font = .monospacedSystemFont(ofSize: 13, weight: .regular)
        output.isEditable = false
        output.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(output)

        status.text = "  ●  Haxe JS runtime   |   edit source, rebuild on Mac"
        status.textColor = UIColor(red: 0.65, green: 0.70, blue: 0.76, alpha: 1)
        status.font = .monospacedSystemFont(ofSize: 10, weight: .regular)
        status.backgroundColor = UIColor(red: 0.12, green: 0.38, blue: 0.27, alpha: 1)
        status.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(status)

        let guide: [NSLayoutConstraint] = [
            top.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor), top.leadingAnchor.constraint(equalTo: view.leadingAnchor), top.trailingAnchor.constraint(equalTo: view.trailingAnchor), top.heightAnchor.constraint(equalToConstant: 44),
            brand.leadingAnchor.constraint(equalTo: top.leadingAnchor), brand.centerYAnchor.constraint(equalTo: top.centerYAnchor),
            run.trailingAnchor.constraint(equalTo: top.trailingAnchor, constant: -16), run.centerYAnchor.constraint(equalTo: top.centerYAnchor),
            sidebar.leadingAnchor.constraint(equalTo: view.leadingAnchor), sidebar.topAnchor.constraint(equalTo: top.bottomAnchor), sidebar.widthAnchor.constraint(equalToConstant: 180), sidebar.bottomAnchor.constraint(equalTo: status.topAnchor),
            tab.leadingAnchor.constraint(equalTo: sidebar.trailingAnchor), tab.topAnchor.constraint(equalTo: top.bottomAnchor), tab.trailingAnchor.constraint(equalTo: view.trailingAnchor), tab.heightAnchor.constraint(equalToConstant: 32),
            editor.leadingAnchor.constraint(equalTo: sidebar.trailingAnchor), editor.topAnchor.constraint(equalTo: tab.bottomAnchor), editor.trailingAnchor.constraint(equalTo: view.trailingAnchor), editor.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.52),
            outputTitle.leadingAnchor.constraint(equalTo: sidebar.trailingAnchor), outputTitle.topAnchor.constraint(equalTo: editor.bottomAnchor), outputTitle.trailingAnchor.constraint(equalTo: view.trailingAnchor), outputTitle.heightAnchor.constraint(equalToConstant: 28),
            output.leadingAnchor.constraint(equalTo: sidebar.trailingAnchor), output.topAnchor.constraint(equalTo: outputTitle.bottomAnchor), output.trailingAnchor.constraint(equalTo: view.trailingAnchor), output.bottomAnchor.constraint(equalTo: status.topAnchor),
            status.leadingAnchor.constraint(equalTo: view.leadingAnchor), status.trailingAnchor.constraint(equalTo: view.trailingAnchor), status.bottomAnchor.constraint(equalTo: view.bottomAnchor), status.heightAnchor.constraint(equalToConstant: 22)
        ]
        NSLayoutConstraint.activate(guide)
        runtime.onLog = { [weak self] line in
            DispatchQueue.main.async { self?.output.text += "[Haxe] \(line)\n" }
        }
    }

    @objc private func runHaxe() {
        output.text += "\n$ run haxe/build.hxml\n"
        status.text = "  ●  Running bundled Haxe JavaScript"
        runtime.run()
        status.text = "  ●  Haxe JS runtime   |   edit source, rebuild on Mac"
    }

    func textViewDidChange(_ textView: UITextView) {
        status.text = "  ●  Modified   |   run scripts/build.sh to update main.js"
    }
}

let controller = IDEViewController()
PlaygroundPage.current.liveView = controller
PlaygroundPage.current.needsIndefiniteExecution = false
