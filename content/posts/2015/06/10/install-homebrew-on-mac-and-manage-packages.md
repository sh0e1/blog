---
title: MacにHomebrewをインストールしてパッケージを管理をする
author: sh0e1
type: post
date: 2015-06-10T14:35:42+00:00
categories:
  - Mac
---
Macの開発環境が結構ごちゃごちゃしてきたので、今更ながらHomebrewで管理しようと思い立ちました。  
Homebrewを使えばPHP、MySQLなどはもちろん、GUIアプリケーションも管理できるとのことなので、少しずつHomebrewに移行していこうと思います。  
ということで、今回はHomeberwのインストール方法と基本的な使用方法についてです。
<!--more-->

### Homebrewとは

> Homebrew（ホームブルー）は、Mac OS Xオペレーティングシステム上でソフトウェアの導入を単純化するパッケージ管理システムのひとつである。MacPortsやFinkと同様の目的と機能を備えている。
> 
> [Homebrew (パッケージ管理システム) - Wikipedia](http://ja.wikipedia.org/wiki/Homebrew_%28%E3%83%91%E3%83%83%E3%82%B1%E3%83%BC%E3%82%B8%E7%AE%A1%E7%90%86%E3%82%B7%E3%82%B9%E3%83%86%E3%83%A0%29)

Homebrewでは、パッケージをインストールすると/usr/lcoal/Cellar/配下にパッケージがインストールされ、/usr/local/bin/にシンボリックリンクがつくられます。

### 事前準備

Homebrewのインストールには、Command Line Tools for Xcodeが必要です。  
App StoreからXcodeをインストール後、下記コマンドを実行してCommand Line Toolsをインストールします。

```bash
$ xcode-select --install
```

### Homebrewをインストール

公式サイトに記載されているコマンドをコピペして実行するとHomebrewをインストールできます。  
[Homebrew — OS X用パッケージマネージャー](http://brew.sh/index_ja.html)

```bash
$ ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
```

※コマンドのURLが更新されることがあるので、サイトで確認してから実行したほうが確実です。

インストールが完了したら問題がないか確認します。

```bash
$ brew doctor
Your system is ready to brew.
```

Warningが出る場合は、表示される解決策に沿って対応してください。

以上でインストールは完了です。

### brewコマンド

Homebrewの基本的なコマンドです。

バージョンを確認

```bash
$ brew -v
```

パッケージをインストール

```bash
$ brew install FORMULA...
```

パッケージをアンインストール

```bash
$ brew uninstall FORMULA...
```

パッケージを検索

```bash
$ brew search [foo]
```

インストールしたパッケージの確認

```bash
$ brew list [FORMULA...]
```

パッケージの更新

```bash
$ brew update # Homebrew自体と、インストールできるパッケージリストを更新
$ brew upgrade [--all | FORMULA...] # インストールされているパッケージを更新
```

### GUIアプリケーションの管理

MacのGUIアプリケーションを管理するにはHomebrew Caskをインストールします。  
Homebrew Caskをインストールすると、brew caskコマンドが使えるようになります。

```bash
$ brew install caskroom/cask/brew-cask
```

### brew caskコマンド

Homebrew-caskの基本的なコマンドです。

アプリケーションをインストール

```bash
brew cask install
```

アプリケーションをアンインストール

```bash
brew cask uninstall
```

アプリケーションを検索

```bash
brew cask search
```

インストールしたアプリケーションを確認

```bash
brew cask list
```

アプリケーションの更新

```bash
brew cask update
```

ダウンロードファイルの削除

```bash
brew cask cleanup
```

### Homebrew Caskのインストール先

brew caskコマンドでインストールしたアプリケーションは、/opt/homebrew-cask/Caskroom/配下にインストールされ、~/Applicationsにシンボリックリンクがつくられます。

### Homebrewを使ってみた所感

まだ移行中ですが、パッケージの管理が一元化でき、かなり楽になった印象です。  
アプリケーションを色々インストールして管理が面倒という方はぜひHomebrewでパッケージ管理をしてみてください。

最後までご覧いただき、ありがとうございます。
