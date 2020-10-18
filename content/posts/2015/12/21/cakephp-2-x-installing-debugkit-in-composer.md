---
title: CakePHP 2.x - ComposerでDebugKitをインストール
author: sh0e1
type: post
date: 2015-12-21T14:27:24+00:00
categories:
  - CakePHP 2.x
---
前回はファイルをダウンロードしてDebugKitをインストールする方法を紹介しましたが、今回はComposerを使用してDebugKitをインストール方法をご紹介したいと思います。

前回の記事はこちら。  
[CakePHP 2.x – DebugKitの導入方法]()
<!--more-->

### 前提条件

Composerがインストールされていることが前提条件です。  
Composerのインストール方法、基本的な使い方は下記の記事をご覧ください。  
[]()

### そのままインストールすると...

[CakePHPのサイト](http://cakephp.jp/)からzipファイルをダウンロードして展開すると、composer.jsonが含まれています。  
composer.jsonにはDebugKitが既に含まれているので、composer installをするとDebugKitがインストールされますが、現在のフォルダ構成上、vendorディレクトリを、pluginディレクトリが2つずつ作成されてしまいます。

```bash
$ cd /path/to/cakephp2/
$ composer install
$ tree -d -L 1
.
├── Plugin
├── app
├── lib
├── plugins
├── vendor
└── vendors

6 directories
```

なので、composer installする前にvendorとpluginをインストールするディレクトリを指定する必要があります。

### vendorインストールディレクトリの変更

composer configコマンドで、まずvendorインストールディレクトリを変更します。

```bash
$ composer config vendor-dir vendors/
```

コマンド実行後、composer.jsonを開くとconfigが追加されています。

```php
{
    "name": "cakephp/cakephp",
    "description": "The CakePHP framework",
    "type": "library",
    "keywords": ["framework"],
    "homepage": "http://cakephp.org",
    "license": "MIT",
    "authors": [
        {
            "name": "CakePHP Community",
            "homepage": "https://github.com/cakephp/cakephp/graphs/contributors"
        }
    ],
    "support": {
        "issues": "https://github.com/cakephp/cakephp/issues",
        "forum": "http://stackoverflow.com/tags/cakephp",
        "irc": "irc://irc.freenode.org/cakephp",
        "source": "https://github.com/cakephp/cakephp"
    },
    "require": {
        "php": ">=5.2.8",
        "ext-mcrypt": "*"
    },
    "require-dev": {
        "phpunit/phpunit": "3.7.*",
        "cakephp/debug_kit" : "2.2.*"
    },
    "bin": [
        "lib/Cake/Console/cake"
    ],
    "config": {
        "vendor-dir": "vendors/"
    }
}
```

### pluginインストールディレクトリの変更

また、pluginインストールディレクトリの変更は、composer.jsonにextraキーを追記します。  
extraキーを追記すると、Pluginディレクトリではなく、pluginsディレクトリにCakePHPのプラグインがインストールされます。  
コマンドでもやる方法があるかもしれませんが、少し調べてもわからなかったので、ご存知の方がいれば教えて下さい。

```php
{
    "name": "cakephp/cakephp",
    "description": "The CakePHP framework",
    "type": "library",
    "keywords": ["framework"],
    "homepage": "http://cakephp.org",
    "license": "MIT",
    "authors": [
        {
            "name": "CakePHP Community",
            "homepage": "https://github.com/cakephp/cakephp/graphs/contributors"
        }
    ],
    "support": {
        "issues": "https://github.com/cakephp/cakephp/issues",
        "forum": "http://stackoverflow.com/tags/cakephp",
        "irc": "irc://irc.freenode.org/cakephp",
        "source": "https://github.com/cakephp/cakephp"
    },
    "require": {
        "php": ">=5.2.8",
        "ext-mcrypt": "*"
    },
    "require-dev": {
        "phpunit/phpunit": "3.7.*",
        "cakephp/debug_kit" : "2.2.*"
    },
    "bin": [
        "lib/Cake/Console/cake"
    ],
    "config": {
        "vendor-dir": "vendors/"
    },
    "extra": {
        "installer-paths": {
            "./plugins/{$name}/": ["type:cakephp-plugin"]
        }
    }
}
```

### 再度インストール

vendorと、pluginのインストールディレクトリを変更したら、再度composer installを実行します。  
実行前に、最初にインストールしたディレクトリを削除しておきます。

```bash
$ rm -rf vendor Plugin composer.lock
$ composer install
```

インストール後、vendorsとpluginsディレクトリの中身を確認します。

```bash
$ tree -d -L 1
.
├── app
├── lib
├── plugins
└── vendors

4 directories
$ ls plugins/
DebugKit	empty
$ ls vendors/
autoload.php	bin		composer	empty		phpunit		symfony
```

cakephp内のディレクトリに無事インストールできました。

あとは、DebugKitのファイルをダウンロードしてインストールしたときと同じように設定すると、DebugKitを利用できます。  
以上、CakePHP 2.xでComposerでDebugKitをインストール方法でした。
