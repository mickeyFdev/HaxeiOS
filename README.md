# HaxeiOS

HaxeコードをJavaScriptへ事前コンパイルし、iOSのSwift Playgroundから`JavaScriptCore`で実行する、VSCode風のHaxeワークスペースです。

## できること

- VSCode風のファイルエクスプローラー、タブ、エディター、ターミナル出力
- `Main.hx`の編集と、生成済みHaxe JavaScriptの`Run`実行
- Haxeの純粋な言語機能と、JavaScriptへ変換できるHaxeライブラリの利用
- Swift側からJavaScriptCoreへ安全なネイティブ関数を公開する拡張

## 重要な制約

**Haxeコンパイラ自体はiOS Swift Playground内では動かしていません。** HaxeはMacまたはCIでJavaScriptへ事前コンパイルし、Playgroundには生成物を同梱します。Playground内で編集した内容は、見た目とワークスペース状態には反映されますが、コンパイルにはMac側で再度`./scripts/build.sh`を実行する必要があります。

OpenFL、Lime、HaxeFlixelを含む「Haxe関連の物を全部」無変更でiOS Playground内で動かすことはできません。これらは通常、C++/Objective-C、UIKit、Metal、OpenGL、ファイルシステム、スレッド、またはブラウザーのDOM/Canvasを必要とするためです。対応の目安は次のとおりです。

| ライブラリ | この構成での対応 | 理由 |
| --- | --- | --- |
| Haxe標準の純粋コード | 対応 | JavaScriptへ変換できる |
| HaxeのJS向けライブラリ | 条件付き対応 | JavaScriptCoreが提供するAPIの範囲内 |
| OpenFL | 原則非対応 | HTML5版はDOM/Canvas、iOS版はネイティブビルドが必要 |
| Lime | 原則非対応 | ネイティブウィンドウ・GPU・入力などのバックエンドが必要 |
| HaxeFlixel | 原則非対応 | OpenFL/Limeと描画・入力バックエンドに依存 |
| OpenFL/Lime/Flixelの事前生成JS | 大規模な移植が必要 | DOM/CanvasをJavaScriptCore向けに置き換える必要がある |

つまり、このリポジトリは**HaxeコードをiOS上で実行する軽量IDE**として動作します。OpenFL/Lime/Flixelを使ったゲームは、Mac上で通常どおりiOSアプリまたはHTML5向けにビルドし、iOS Playgroundとは別のアプリとして実行するのが正しい構成です。

## 必要なもの

- macOS（Haxeコードのビルド用）
- Haxe 4.x
- Xcode 15以降、またはiPad版Swift Playgrounds
- iOS 13以降（`JavaScriptCore`利用）

## 使い方

```sh
./scripts/build.sh
```

生成された`HaxeiOS.playground`をXcodeまたはiPad版Swift Playgroundsで開きます。画面にはVSCode風のExplorer、`Main.hx`タブ、ソースエディター、ターミナルが表示されます。`▶ Run`を押すと、同梱されたHaxe生成JavaScriptが実行されます。

Haxeコードは`haxe/src/Main.hx`です。変更後は次の手順でPlaygroundの実行物を更新します。

```sh
./scripts/build.sh
```

## 構成

| パス | 役割 |
| --- | --- |
| `haxe/build.hxml` | Haxe→JavaScriptのコンパイル設定 |
| `haxe/src/Main.hx` | 実行するHaxeコード |
| `HaxeiOS.playground/Contents.swift` | VSCode風UI、JavaScriptCoreブリッジ、実行ボタン |
| `HaxeiOS.playground/Resources/main.js` | Haxeが生成したJavaScript |
| `scripts/build.sh` | 生成物をPlaygroundへコピーするスクリプト |

## HaxeからiOS機能を使う

UIKitなどのiOS APIはSwift側でラッパーを作り、`JSContext`に関数として公開します。Haxeコードへ値を渡す場合は、JavaScriptコード文字列を連結せず、JavaScriptCoreの引数として渡してください。これにより、入力値によるコードインジェクションを避けられます。

## トラブルシューティング

- **`main.js`が見つからない**: Macで`./scripts/build.sh`を実行してください。
- **`JavaScriptCore`をimportできない**: iOS向けのPlaygroundとして開いてください。
- **編集内容が実行結果に反映されない**: Playgroundを閉じ、Macでビルドスクリプトを実行し、再度Playgroundを開いてください。
- **OpenFL/Lime/Flixelを使いたい**: これらを直接Playgroundへ追加するのではなく、MacでiOS/HTML5向けの通常のプロジェクトとしてビルドしてください。
