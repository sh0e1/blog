---
title: CakePHP 2.x – DebugKitの導入方法
author: sh0e1
type: post
date: 2015-06-08T13:16:35+00:00
categories:
  - CakePHP 2.x
---
CakePHP 2.xのDebugKitの導入方法です。  
DebugKitを導入すると、セッションの中身、SQL文、ログなどを見ることができ、開発に非常に重宝するので、ぜひ導入してみてください。

前回の記事の環境を元に、Debug Kitの導入をします。  
[CakePHP 2.xのローカル環境での初期設定]({{< ref "/posts/2015/06/06/initial-configuration-of-cakephp-2-x-in-local-environment.md" >}})
<!--more-->

### ソースコードのダウンロード

GitHubからソースコードをダウンロードします。  
[cakephp/debug_kit · GitHu](https://github.com/cakephp/debug_kit)

releasesをクリックしてからDebug Kit 2.2.4のSource code(zip)をクリックすると、Debug Kitのソースコードがダウンロードできます。  
3.x.xはCakePHP 3.x用でCakePHP 2.xでは正常に動作しませんのでご注意ください。

### CakePHPのディレクトリにDebugKitを配置

ダウンロードしたzipファイルを展開後、フォルダ名をDebugKitにリネームし、CakePHPのpluginsディレクトリへ配置します。

```bash
$ # zipファイルを展開
$ unzip ~/Downloads/debug_kit-2.2.4.zip
$ # 展開したフォルダをcakephp/pluginsへフォルダ名を変更して移動
$ mv debug_kit-2.2.4/ /Applications/MAMP/htdocs/cakephp/plugins/DebugKit
```

### ソースコードの編集

Debug Kitを有効にするために、ソースコードを編集します。

app/Config/bootstrap.phpに、プラグインのロードの記述を追記します。

```php
// app/Config/bootstrap.php
CakePlugin::load('DebugKit');
```

app/Controller/AppController.phpで、コンポーネントの読込を追記します。

```php
// app/Controller/AppController.php
class AppController extends Controller {
    public $components = array('DebugKit.Toolbar');
}
```

app/View/Layouts/default.phpに記述されたsql_dump エレメントの出力をコメントアウトします。


```php
// app/View/Layouts/default.php
// echo $this->element('sql_dump');
```

### 確認

ブラウザから `http://localhost/cakephp/` にアクセスすると、画面の右上にCakePHPのアイコンが表示されていると思います。  
アイコンをクリックするとDegub Kitの詳細が表示されます。これでDebug Kitの導入は完了です。

DegubKitはComposerでインストールすることもできますが、Composerでのインストール方法は後日記事にしたいと思います。

最後までご覧いただき、ありがとうございます。

### 補足

Degub Kitを使用すると、「serialization of ‘closure’ is not allowed」というエラーが表示される場合があります。  
もしエラーがでた場合は、次のようにapp/Controller/AppController.phpを修正してみてください。

```php
// app/Controller/AppController.php
class AppController extends Controller {
    public $components = array(
        'DebugKit.Toolbar' => array('panels' => array('history' => false))
    );
}
```
