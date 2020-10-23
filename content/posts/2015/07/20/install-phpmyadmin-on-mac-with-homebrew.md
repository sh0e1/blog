---
title: HomebrewでMacにphpMyAdminをインストールする
author: sh0e1
type: post
date: 2015-07-20T03:00:12+00:00
categories:
  - Mac
  - MySQL
---
HomebrewでMacにインストールシリーズも、今回でひとまず最終回です。  
最後にphpMyAdminをインストールします。

Homebrewについては下記を参照してください。  
[MacにHomebrewをインストールしてパッケージを管理をする]({{< ref "/posts/2015/06/10/install-homebrew-on-mac-and-manage-packages.md" >}})
<!--more-->

### 前提条件

MacにApache、MySQL、PHPがインストールされていることが前提条件になります。  
各インストール方法は、各記事を参照してください。

- [HomebrewでApacheをMacにインストール]({{< ref "/posts/2015/07/07/installing-apache-on-mac-with-homebrew.md" >}})
- [HomebrewでMySQLをMacにインストール]({{< ref "/posts/2015/06/29/install-mysql-on-mac-with-homebrew.md" >}})
- [HomebrewでMacにphpenv+php-buildをインストールしてPHPのバージョンを管理する]({{< ref "/posts/2015/07/11/installing-phpenv+php-build-on-mac-with-homebrew-and-managing-php-versions.md" >}})

### インストール

brewコマンドでインストールします。

```bash
$ brew install phpmyadmin
==> Installing phpmyadmin from homebrew/homebrew-php
==> Downloading https://github.com/phpmyadmin/phpmyadmin/archive/RELEASE_4_4_11.tar.gz
==> Downloading from https://codeload.github.com/phpmyadmin/phpmyadmin/tar.gz/RELEASE_4_4_11
######################################################################## 100.0%
==> Caveats
Note that this formula will NOT install mysql. It is not
required since you might want to get connected to a remote
database server.
Webserver configuration example (add this at the end of
your /etc/apache2/httpd.conf for instance) :
Alias /phpmyadmin /usr/local/share/phpmyadmin
<directory /usr/local/share/phpmyadmin/>
    Options Indexes FollowSymLinks MultiViews
    AllowOverride All
    <ifmodule mod_authz_core.c>
        Require all granted
    </ifmodule>
    <ifmodule !mod_authz_core.c>
        Order allow,deny
        Allow from all
    </ifmodule>
</directory>
Then, open http://localhost/phpmyadmin
More documentation : file:///usr/local/Cellar/phpmyadmin/4.4.11/share/phpmyadmin/doc/
Configuration has been copied to /usr/local/etc/phpmyadmin.config.inc.php
Don't forget to:
- change your secret blowfish
- uncomment the configuration lines (pma, pmapass ...)
==> Summary
🍺  /usr/local/Cellar/phpmyadmin/4.4.11: 2001 files, 63M, built in 36 seconds
```

### ブラウザからアクセス

brewコマンドでのインストールが完了すると、Apacheの設定ファイルの例が出力されるので、Apahceのhttpd.confに出力されたまま追記します。

```bash
$ vi /usr/local/etc/apache2/2.4/httpd.conf
# phpmyadmin
Alias /phpmyadmin /usr/local/share/phpmyadmin
<directory /usr/local/share/phpmyadmin/>
    Options Indexes FollowSymLinks MultiViews
    AllowOverride All
    <ifmodule mod_authz_core.c>
        Require all granted
    </ifmodule>
    <ifmodule !mod_authz_core.c>
        Order allow,deny
        Allow from all
    </ifmodule>
</directory>
```

ApacheとMySQLを起動します。

```bash
$ sudo apachectl start
$ mysql.server start
```

ブラウザから `http://localhost/phpmyadmin` にアクセスすると、phpMyAdminのログイン画面が表示されます。

### 警告とエラーの修正

phpMyAdminにログインすると、画面の下部に警告とエラーが表示されているので、修正します。

#### The configuration file now needs a secret passphrase

まずThe configuration file now needs a secret passphraseから修正します。  
phpmyadmin/config.inc.phpの$cfg['blowfish_secret']に適当な値をいれることでエラーが消えます。

```php
$cfg['blowfish_secret'] = 'hogehoge'; /* YOU MUST FILL IN THIS FOR COOKIE AUTH! */
```

#### The phpMyAdmin configuration storage is not completely configured, some extended features have been deactivated. Find out why. Or alternately go to 'Operations' tab of any database to set it up there.

次にThe phpMyAdmin configuration storage is not completely configured, some extended features have been deactivated. Find out why. Or alternately go to 'Operations' tab of any database to set it up there.を修正します。

Find out why.のリンクをクリックすると理由が表示されるので確認します。

Configuration of pmadb… not OK  
General relation features Disabled

これはphpmyadminの設定の保存場所を設定すれば警告が消えます。

まず/usr/local/share/phpmyadmin/sql/create_tables.sqlを実行します。

```bash
$ mysql -u root -p < /usr/local/share/phpmyadmin/sql/create_tables.sql
```

実行するとphpmyadminデータベースがつくられます。  
次にconfig.inc.phpのコメントアウトを外します。

```php
/* Storage database and tables */
$cfg['Servers'][$i]['pmadb'] = 'phpmyadmin';
$cfg['Servers'][$i]['bookmarktable'] = 'pma__bookmark';
$cfg['Servers'][$i]['relation'] = 'pma__relation';
$cfg['Servers'][$i]['table_info'] = 'pma__table_info';
$cfg['Servers'][$i]['table_coords'] = 'pma__table_coords';
$cfg['Servers'][$i]['pdf_pages'] = 'pma__pdf_pages';
$cfg['Servers'][$i]['column_info'] = 'pma__column_info';
$cfg['Servers'][$i]['history'] = 'pma__history';
$cfg['Servers'][$i]['table_uiprefs'] = 'pma__table_uiprefs';
$cfg['Servers'][$i]['tracking'] = 'pma__tracking';
$cfg['Servers'][$i]['userconfig'] = 'pma__userconfig';
$cfg['Servers'][$i]['recent'] = 'pma__recent';
$cfg['Servers'][$i]['favorite'] = 'pma__favorite';
$cfg['Servers'][$i]['users'] = 'pma__users';
$cfg['Servers'][$i]['usergroups'] = 'pma__usergroups';
$cfg['Servers'][$i]['navigationhiding'] = 'pma__navigationhiding';
$cfg['Servers'][$i]['savedsearches'] = 'pma__savedsearches';
$cfg['Servers'][$i]['central_columns'] = 'pma__central_columns';
```

再度ブラウザからアクセスすると表示されていた警告とエラーが消えていると思います。

以上、phpMyAdminのインストール方法でした。
