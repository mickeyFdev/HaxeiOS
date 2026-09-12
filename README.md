# HaxeiOS

HaxeコードをJavaScriptへ事前コンパイルし、iOSのSwift Playgroundから`JavaScriptCore`で実行する最小構成です。

> iPad / iPhone上でHaxeコンパイラを実行するのではなく、MacまたはCIでHaxeをビルドします。生成されたJavaScriptはPlaygroundに同梱され、iOS上では追加ランタイムなしで実行されます。

## 必要なもの

- macOS（Haxeコードのビルド用）
- Haxe 4.x
- Xcode 15以降、またはiPad版Swift Playgrounds
- iOS 13以降（`JavaScriptCore`利用）

## 使い方

```sh
# Haxeをインストール済みの環境で
./scripts/build.sh
```

生成された`HaxeiOS.playground/Resources/main.js`を含むフォルダを、XcodeまたはSwift Playgroundsで開きます。`Contents.swift`を実行すると、Haxe側の`trace`出力がSwift Playgroundの実行結果に表示されます。

Haxeコードは`haxe/src/Main.hx`です。変更後は必ず`./scripts/build.sh`を再実行してください。

## 構成

| パス | 役割 |
| --- | --- |
| `haxe/build.hxml` | Haxe→JavaScriptのコンパイル設定 |
| `haxe/src/Main.hx` | 実行するHaxeコード |
| `HaxeiOS.playground/Contents.swift` | JavaScriptCoreブリッジとPlaygroundエントリポイント |
| `HaxeiOS.playground/Resources/main.js` | Haxeが生成したJavaScript |
| `scripts/build.sh` | 生成物をPlaygroundへコピーするスクリプト |

## 制約

Haxeの`sys`パッケージ、ファイルシステム、ソケット、ネイティブ拡張はこの方式では利用できません。`String`、`Array`、`Map`などの純粋なHaxeコードや、独自のiOSブリッジを追加したコードに向いています。

UIKitをHaxeから直接操作することはできません。必要なiOS APIはSwift側でラッパーを作り、JavaScriptCoreの`JSContext`へ関数として公開してください。

## Swift側へ関数を公開する例

`Contents.swift`の`context["iosLog"] = ...`のようにSwiftブロックを登録し、Haxeでは`untyped __js__("iosLog(...)" ...)`または専用のexternを通じて呼び出します。外部入力をJavaScriptコードとして連結せず、値は引数で渡してください。

## トラブルシューティング

- **`main.js`が見つからない**: `./scripts/build.sh`を実行し、`Resources`フォルダ内に生成物があることを確認してください。
- **Playgroundで`JavaScriptCore`をimportできない**: iOS向けのPlaygroundとして開いていることを確認してください。macOS Playgroundでは利用できるAPIが異なります。
- **Haxeの変更が反映されない**: XcodeのPlayground実行を停止してからビルドスクリプトを再実行し、Playgroundを再読み込みしてください。
