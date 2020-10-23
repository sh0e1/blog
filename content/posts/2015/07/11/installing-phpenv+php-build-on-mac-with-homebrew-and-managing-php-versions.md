---
title: HomebrewでMacにphpenv+php-buildをインストールしてPHPのバージョンを管理する
author: sh0e1
type: post
date: 2015-07-11T00:40:16+00:00
categories:
  - Mac
  - PHP
---
Apache、MySQLに引き続き、HomebrewでphpenvをインストールしてMacに開発環境を構築していきます。  
普通にPHPをインストールしてもいいんですが、案件によってPHPのバージョンは変わりますし、その度にPHPをインストールし直すのは面倒なので、phpenvをインストールすることにしました。  

Homebrewについては下記を参照してください。  
[MacにHomebrewをインストールしてパッケージを管理をする]({{< ref "" >}})
<!--more-->

### phpenvをインストール

いつものbrew installコマンドでインストールします。

```bash
$ brew install phpenv
```

インストールしたらパスを通します。  
今回は.bash_profileに追記しました。

```bash
$ vi ~/.bash_profile
export PATH=/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin
export PATH=$PATH:$HOME/.phpenv/bin # 追記
eval "$(phpenv init -)" # 追記
```

パスを通したらターミナルを再起動するか、sourceコマンドで反映します。

```bash
$ source ~/.bash_profile
```

パスが通っているか確認します。

```bash
$ echo $PATH
/Users/username/.phpenv/shims:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/Users/username/.phpenv/bin
```

${HOME}/.phpenv/shimsと${HOME}/.phpenv/binが上記のようになっていればOKです。  

### php-buildのインストール

php-buildはHomebrewでインストールするのではなく、gitからクローンしてphpenvのプラグインとしてインストールします。  
phpenvのプラグインとしてインストールすることでphpenv installコマンドが使用できるようになります。

```bash
$ git clone git://github.com/CHH/php-build.git $HOME/.phpenv/plugins/php-build
```

php-buildをインストールしたら、PHPをインストールするときにApacheのモジュールも生成するようにdefault\_configure\_options変更します。

```bash
$ vim ~/.phpenv/plugins/php-build/share/php-build/default_configure_options
--with-apxs2=/usr/local/bin/apxs # 最終行に追記
```

apxsのパスはwhichコマンドで確認してください。

```bash
$ which apxs
/usr/local/bin/apxs
```

### PHPをインストール

PHPをインストールする前に先に関連パッケージをインストールしておきます。

```bash
$ brew instal re2c
$ brew install libjpeg
$ brew install libpng
$ brew reinstall libmcryp
```

関連パッケージをインストールしたら、phpenvコマンドでバージョンを確認し、インストールしたいバージョンのPHPをインストールします。

```bash
# バージョン一覧
$ phpenv install -l
# バージョンを指定してインストール
$ phpenv install 5.5.9
# インストールしているバージョンを確認
$ phpenv versions
* system (set by /Users/username/.phpenv/version)
5.5.9
# グローバルで使用するPHPのバージョンを指定
$ phpenv global 5.5.9
$ phpenv rehash
$ php -v
PHP 5.5.9 (cli) (built: Jun 29 2015 21:19:53)
Copyright (c) 1997-2014 The PHP Group
Zend Engine v2.5.0, Copyright (c) 1998-2014 Zend Technologies
with Zend OPcache v7.0.3, Copyright (c) 1999-2014, by Zend Technologies
with Xdebug v2.3.3, Copyright (c) 2002-2015, by Derick Rethans
```

PHPのインストールには結構時間がかかったので、気長に待ってください。

### phpenv-apache-versionのインストール

PHPをインストールしたら、ApacheのPHPモジュールの切り替えをしてくれるスクリプトをインストールします。

```bash
git clone https://github.com/garamon/phpenv-apache-version ~/.phpenv/plugins/phpenv-apache-version
```

phpenv-apache-versionは ~/.phpenv/versions/{version}直下にあるlibphp5.soをコピーしてApacheモジュールとして読み込ませます。 その為、PHPのインストールの際に生成されたlibphp5.soを上記のパスに移動しておく必要があります。 phpenvで各バージョンのPHPインストールした際には、下記のようにApacheのPHPモジュールを移動させます。

```bash
$ mv /usr/local/Cellar/httpd24/2.4.12/libexec/libphp5.so ~/.phpenv/versions/5.5.9/
```

移動されたら、下記のコマンドを実行するとlibphp5.soがコピーされ、Apacheが再起動されるはずなんですが、現状のままではエラーになってしまいます。

```bash
$ phpenv apache-version 5.5.9
Error: No available formula for httpd
Sorry your OS is not supported.
```

これは、httpdというformulaがないからエラーになっています。現在Apacheのformulaはhttpd22かhttpd24の為です。  
直接スクリプトを修正して対応します。

```bash
$ cd ~/.phpenv/plugins/phpenv-apache-version/bin/
$ cp -p rbenv-apache-version rbenv-apache-version.org
$ vim rbenv-apache-version
if [ -d "$(brew --prefix httpd24)" ]; then
    PHPENV_APACHE_MODULE_PATH="$(brew --prefix httpd24)/libexec"
elif [ -d "$(brew --prefix httpd22)" ]; then
    PHPENV_APACHE_MODULE_PATH="$(brew --prefix httpd22)/libexec"
fi
```

再度コマンドを実行すると、エラーにならずに終了するはずです。

```bash
$ phpenv apache-version 5.5.9
copy /Users/shoei/.phpenv/versions/5.5.9/libphp5.so to /usr/local/opt/httpd24/libexec
Restarting apache...
Password: # パスワードを入力
```

### Apachでphpinfoを確認する

ドキュメントルートにファイルを作成してブラウザからphpinfoを確認してみます。

```bash
$ vim /usr/local/var/www/htdocs/info.php
<?php phpinfo(); ?>
```

ブラウザで `http://localhost/info.php` にアクセスしてphpinfoを見ると、バージョンが5.5.9であることを確認できます。

### 他のバージョンのPHPをインストール

他のバージョンのPHPをインストールしてみます。

```bash
$ phpenv install 5.6.9
$ phpenv versions
system
* 5.5.9 (set by /Users/shoei/.phpenv/version)
5.6.9
$ phpenv global 5.6.9
$ phpenv rehash
$ php -v
PHP 5.6.9 (cli) (built: Jun 30 2015 22:00:14)
Copyright (c) 1997-2015 The PHP Group
Zend Engine v2.6.0, Copyright (c) 1998-2015 Zend Technologies
with Zend OPcache v7.0.4-dev, Copyright (c) 1999-2015, by Zend Technologies
with Xdebug v2.3.3, Copyright (c) 2002-2015, by Derick Rethans
```

忘れずにlibphp5.soを移動しておきます。

```bash
$ mv /usr/local/Cellar/httpd24/2.4.12/libexec/libphp5.so ~/.phpenv/versions/5.6.9/
$ phpenv apache-version 5.6.9
copy /Users/shoei/.phpenv/versions/5.6.9/libphp5.so to /usr/local/opt/httpd24/libexec
Restarting apache...
Password: # パスワードを入力
```

phpinfoで確認してもバージョンが変わっているのが確認できます。

### PHPのアンインストール

特定のバージョンのPHPをアンインストールする場合は、~/.phpenv/versions/{version}ディレクトリを削除します。

```bash
$ rm -rf ~/.phpenv/versions/5.5.9
$ phpenv rehash
```

### あとがき

これでApache、MySQL、PHPのインストールが終わったので、PHPの開発環境は構築環境です。あとはphpmyadminいれようか悩んでます。  
最近プライベートではPHPはほとんど触らずに、Java、あとはRaspberry Piで遊んでいるので、その辺も少しずつ載せていきたいです。
