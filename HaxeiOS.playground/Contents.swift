import UIKit
import Foundation
import JavaScriptCore
import PlaygroundSupport

final class HaxeRuntime {
    private let context: JSContext
    var onLog: ((String) -> Void)?
    var onRender: ((Any?) -> Void)?

    init() {
        context = JSContext()!
        context.exceptionHandler = { [weak self] _, exception in
            self?.onLog?("[exception] \(exception?.toString() ?? "Unknown JavaScript exception")")
        }

        let log: @convention(block) (String) -> Void = { [weak self] value in
            self?.onLog?(value)
        }
        context.setObject(log, forKeyedSubscript: "__swiftLog" as NSString)
        let render: @convention(block) (JSValue) -> Void = { [weak self] value in
            self?.onRender?(value.toObject())
        }
        context.setObject(render, forKeyedSubscript: "__swiftRender" as NSString)
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

final class OpenFLCanvasView: UIView {
    var commands: [[String: Any]] = [] { didSet { setNeedsDisplay() } }

    override func draw(_ rect: CGRect) {
        UIColor(red: 0.035, green: 0.043, blue: 0.055, alpha: 1).setFill()
        UIRectFill(rect)
        for child in commands {
            let offsetX = number(child["x"])
            let offsetY = number(child["y"])
            let color = uiColor(child["color"])
            color.withAlphaComponent(CGFloat(number(child["alpha"], fallback: 1))).setFill()
            guard let shapes = child["commands"] as? [[String: Any]] else { continue }
            for shape in shapes {
                switch shape["kind"] as? String {
                case "rect":
                    let frame = CGRect(x: offsetX + number(shape["x"]), y: offsetY + number(shape["y"]), width: number(shape["width"]), height: number(shape["height"]))
                    UIBezierPath(roundedRect: frame, cornerRadius: 10).fill()
                case "circle":
                    let radius = number(shape["radius"])
                    let center = CGPoint(x: offsetX + number(shape["x"]), y: offsetY + number(shape["y"]))
                    UIBezierPath(arcCenter: center, radius: radius, startAngle: 0, endAngle: .pi * 2, clockwise: true).fill()
                default: break
                }
            }
        }
    }

    private func number(_ value: Any?, fallback: Double = 0) -> CGFloat {
        if let value = value as? NSNumber { return CGFloat(value.doubleValue) }
        return CGFloat(fallback)
    }

    private func uiColor(_ value: Any?) -> UIColor {
        let hex = Int(number(value))
        return UIColor(red: CGFloat((hex >> 16) & 255) / 255, green: CGFloat((hex >> 8) & 255) / 255, blue: CGFloat(hex & 255) / 255, alpha: 1)
    }
}

final class IDEViewController: UIViewController, UITextViewDelegate {
    private let editor = UITextView()
    private let output = UITextView()
    private let canvas = OpenFLCanvasView()
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

        canvas.layer.borderColor = UIColor(red: 0.16, green: 0.20, blue: 0.25, alpha: 1).cgColor
        canvas.layer.borderWidth = 1
        canvas.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(canvas)

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
            editor.leadingAnchor.constraint(equalTo: sidebar.trailingAnchor), editor.topAnchor.constraint(equalTo: tab.bottomAnchor), editor.trailingAnchor.constraint(equalTo: view.trailingAnchor), editor.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.39),
            canvas.leadingAnchor.constraint(equalTo: sidebar.trailingAnchor), canvas.topAnchor.constraint(equalTo: editor.bottomAnchor), canvas.trailingAnchor.constraint(equalTo: view.trailingAnchor), canvas.heightAnchor.constraint(equalToConstant: 190),
            outputTitle.leadingAnchor.constraint(equalTo: sidebar.trailingAnchor), outputTitle.topAnchor.constraint(equalTo: canvas.bottomAnchor), outputTitle.trailingAnchor.constraint(equalTo: view.trailingAnchor), outputTitle.heightAnchor.constraint(equalToConstant: 28),
            output.leadingAnchor.constraint(equalTo: sidebar.trailingAnchor), output.topAnchor.constraint(equalTo: outputTitle.bottomAnchor), output.trailingAnchor.constraint(equalTo: view.trailingAnchor), output.bottomAnchor.constraint(equalTo: status.topAnchor),
            status.leadingAnchor.constraint(equalTo: view.leadingAnchor), status.trailingAnchor.constraint(equalTo: view.trailingAnchor), status.bottomAnchor.constraint(equalTo: view.bottomAnchor), status.heightAnchor.constraint(equalToConstant: 22)
        ]
        NSLayoutConstraint.activate(guide)
        runtime.onLog = { [weak self] line in
            DispatchQueue.main.async { self?.output.text += "[Haxe] \(line)\n" }
        }
        runtime.onRender = { [weak self] value in
            guard let commands = value as? [[String: Any]] else { return }
            DispatchQueue.main.async { self?.canvas.commands = commands }
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
