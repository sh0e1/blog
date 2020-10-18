---
title: 今更なComposerの基本的な使い方
author: sh0e1
type: post
date: 2015-12-14T14:16:56+00:00
categories:
  - PHP
---
かなり今更な感じはありますが、Composerの基本的な使い方をまとめておきます。  
PHPでのライブラリの管理は以前はPEARでやっていた印象がありますが、現在はComposerが主流になっていると思います。  
本当に基本的な使い方しかまとめないので、公式ドキュメントをご確認くださいが多くなると思いますが、ご了承ください。
<!--more-->

### Composerとは

PHPのパッケージ管理ツールです。プロジェクト単位での管理が基本になります。  
Composerが動作するためにはPHP 5.3.2以上の環境が必要になります。

公式サイトはこちら。  
https://getcomposer.org/

### Composerのインストール

#### curlでインストール

```bash
$ curl -sS https://getcomposer.org/installer | php
```

#### Homebrewでインストール

```bash
$ brew install composer --ignore-dependencies
```

#### Windowsでインストール

Windowsの場合は、[ここ](https://getcomposer.org/doc/00-intro.md#installation-windows)からインストーラをダウンロードしてインストールできます。  
また、ローカルインストール、グローバルインストールなどの詳細は、[こちら](https://getcomposer.org/doc/00-intro.md#downloading-the-composer-executable)をご確認ください。  
インストール後にバージョンを確認して、バージョンが出力されれば、正常にインストールできています。

```bash
$ php composer.phar -V
You are running composer with xdebug enabled. This has a major impact on runtime performance. See https://getcomposer.org/xdebug
Composer version 1.0-dev (feefd51565bb8ead38e355b9e501685b5254d0d5) 2015-12-03 16:17:58
```

または

```bash
$ composer -V
You are running composer with xdebug enabled. This has a major impact on runtime performance. See https://getcomposer.org/xdebug
Composer version 1.0-dev (feefd51565bb8ead38e355b9e501685b5254d0d5) 2015-12-03 16:17:58
```

私の環境では You are running composer with xdebug enabled. This has a major impact on runtime performance. See https://getcomposer.org/xdebug とメッセージが表示されますが、これはxdebugを有効にしていると表示されます。  
xdebugが有効だと、Composerの実行速度が遅いですよって意味ですが、遅いだけなので今回は詳細については特に記載しません。  
xdebugを無効にすれば、メッセージは表示されないと思います。

### セットアップ

ディレクトリを作成して、ディレクトリ内に、composer.jsonを作成し、requireキーでパッケージ名とバージョンを指定します。

```json
{
    "require": {
        "monolog/monolog": "1.0.*"
    }
}
```

バージョンの指定は、比較演算子、ワイルドカード、チルダ演算子も有効です。詳細は公式サイトに記載されているので、[こちら](https://getcomposer.org/doc/articles/versions.md)を参照してください。

### パッケージのインストール

```bash
$ php composer.phar install
```

これでcomposer.jsonに指定したパッケージが、指定したバージョンでvendorディレクトリ内にインストールされます。

### パッケージの更新

パッケージは自動更新されないため、新しいバージョンにアップデートするときはupdateコマンドを使います。

```bash
$ php composer.phar update
```

アップデートするパッケージを指定することも可能です。

```bash
$ php composer.phar update monolog/monolog
```

### Packagist

PackagistとはメインのComposerリポジトリで、パッケージの取得元です。  
PackagistのWebサイトがあり、パッケージの参照、検索ができます。  
https://packagist.org/

### オートローディング

Composerでパッケージをインストールすると、vendor/autoload.phpが生成されます。  
このファイルをインクルードすれば、パッケージを簡単に利用することができます。

```php
require 'vendor/autoload.php';

$log = new Monolog\Logger('name');
$log->pushHandler(new Monolog\Handler\StreamHandler('app.log', Monolog\Logger::WARNING));

$log->addWarning('Foo');
```

### 主なComposerのコマンド

composer.jsonを作成

```bash
$ php composer.phar init
```

パッケージのインストール

```bash
$ php composer.phar install
```

開発用のパッケージのインストール

```bash
$ php composer.phar install --dev
```

パッケージの更新

```bash
$ php composer.phar update
```

特定のパッケージのみ更新

```bash
$ php composer.phar updat [package name]
```

パッケージの追加

```bash
$ php composer.phar require [package name]:[version]
```

開発時のみ利用したいパッケージの追加

```bash
$ php composer.phar require --dev [package name]:[version]
```

パッケージを検索

```bash
$ php composer.phar search [package name]
```

パッケージを参照

```bash
$ php composer.phar show [package name]
```

composer自体を更新

```bash
$ php composer.phar self-update
```

comoserの設定変更

```bash
$ php composer.phar config [setting key] [setting value]
```

設定内容を確認

```bash
$ php composer.phar config --list
```

プロジェクトを作成

```bash
$ php composer.phar create-project [package name] [install path] [version]
```

オートローダーを更新

```bash
$ php composer.phar dump-autoload
```

### あとがき

最近はPHPの各フレームワークのインストールもComposerを使用するようになっているので、PHPではComposerの利用は必須だと思います。  
本当に簡単にまとめましたが、今更なComposerの基本的な使い方でした。
