---
title: HomebrewでApacheをMacにインストール
author: sh0e1
type: post
date: 2015-07-07T14:13:00+00:00
categories:
  - Mac
---
MySQLに引き続き、HomebrewでApacheをインストールしてMacに開発環境を構築していきます。  
今回もインストールから初期設定まで行い、最後にブラウザからアクセスしてページが表示されるか確認します。

Homebrewについては下記を参照してください。  
[MacにHomebrewをインストールしてパッケージを管理をする]({{< ref "/posts/2015/06/10/install-homebrew-on-mac-and-manage-packages.md" >}})
<!--more-->

### インストール

いつも通り、brew installコマンドでインストールします。

```bash
$ brew tap homebrew/dupes
$ brew tap homebrew/apache
$ brew install httpd24
```

HomebrewではApacheはバージョン2.2と2.4がインストールできるみたいですが、今回はバージョン2.4をインストールしました。  
Apache 2.2をインストールしたい場合は、brew install httpd22でインストールできます。

インストールが完了したらパスを確認します。  
MacにはデフォルトでApacheがインストールされているので、apachectlコマンドのパスがHomebrewでインストールしたApacheを向いているかの確認です。

```bash
$ which apachectl
/usr/local/bin/apachectl
```

パスが/usr/local/bin/apachectlと表示されれば大丈夫です。

### 設定ファイルの変更

設定ファイルを変更します。  
設定ファイルのパスは/usr/local/etc/apache2/2.4/httpd.confです。

```bash
#一応バックアップをとっておく
$ cp -p /usr/local/etc/apache2/2.4/httpd.conf /usr/local/etc/apache2/2.4/httpd.conf.org
$ vi /usr/local/etc/apache2/2.4/httpd.conf
#ポート番号の変更
Listen 80
# ServerNameの変更
ServerName localhost:80
# .htaccessでoverrideを許可
<Directory "/usr/local/var/www/htdocs">
    AllowOverride All
</Directory>
# index.phpを使えるように修正
<ifmodule dir_module="">
    DirectoryIndex index.html index.php
</ifmodule>
# .phpを実行できるようにMIMEタイプを追加
<ifmodule mime_module="">
    AddType application/x-httpd-php .php
</ifmodule>
```

#### 2015/07/27追記

.htaccessでのmod_rewriteを有効にするために、libexec/mod_rewrite.soのコメントも外しておいたほうがいいかもしれません。  
CakePHPを動かそうとしたときにハマりました...

```bash
# コメントアウトを外す
LoadModule rewrite_module libexec/mod_rewrite.so
```

設定ファイルを変更したら、Apacheを起動します。

```sh
$ sudo apachectl start
```

### ブラウザから確認

ブラウザから `http://localhost` にアクセスして、It works!と表示されればOKです。  
ちなみに、ドキュメントルートは今回はデフォルトのままなので、/usr/local/var/www/htdocsです。

### あとがき

最近環境構築ネタ、しかもHomebrewばかりになってしまっているので、あとphpenvとphpmyadminを書いたらとりあえず環境構築ネタは終わりにして、サンプルとかコードとか載せていきたいと考えています。  
それと7/6にGoogle Cloud Platformの研修に参加してきたので、その辺のことも載せていきたいです。
