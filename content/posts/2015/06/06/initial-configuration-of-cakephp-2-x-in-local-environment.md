---
title: CakePHP 2.xのローカル環境での初期設定
author: sh0e1
type: post
date: 2015-06-06T11:42:38+00:00
categories:
  - CakePHP 2.x
---
仕事でよく利用するCakePHP 2.xのローカル環境での初期設定の方法です。  
最近ではSymfony、Silex、 CodeIgniterも使いますが、個人的にはCakePHPが一番好きです。  
ちなみに私の環境は以下の通りです。パスなどは、各環境に置き換えてご覧ください。

  * OS X Yosemite（10.10.1）
  * MAMP 3.0.7.3
  * PHP 5.5
  * MySQL 5.5
  * Apache 2.2

※PHP、MySQL、ApacheはMAMP内のものです。
<!--more-->

### CakePHPとは

> CakePHP（ケイクピーエイチピー）とは、PHPで書かれたオープンソースのWebアプリケーションフレームワークである。 先行するRuby on Railsの概念の多くを取り入れており、Rails流の高速開発とPHPの機動性を兼ね備えたフレームワークと言われている。
> 
> [CakePHP - Wikipedia](http://ja.wikipedia.org/wiki/CakePHP)

Wikipediaではこのように書かれていますが、簡単にいうとPHPでWebアプリケーションを高速に開発するためのひな形みたいなものです。  
CakePHPでは、データベースを作成しコマンドを叩くだけで、簡単なアプリケーションがつくれます。

### ソースのダウンロード

ここからはCakePHPの初期設定についてです。  
[CakePHP: 高速開発 php フレームワーク](http://cakephp.jp/)  
上記サイトの下記の箇所をクリックして、ソースファイルをダウンロードします。  
cakephp-2.6.4.zipがダウンロードされます。

### ドキュメントルート(htdocs)に配置してリネーム

zipファイルを解凍するとcakephp-2.6.4ができるのでApacheのドキュメントルートに配置し、ディレクトリ名を変更します。

```bash
$ unzip ~/Download/cakephp-2.6.4.zip
$ mv ~/cakephp-2.6.4/ /Applications/MAMP/htdocs/cakephp
```

### ブラウザからアクセス

Apacheを起動してブラウザから `http://localhost/cakephp` にアクセスすると画面が表示されます。  
赤と黄色で色々エラーが表示されているので、ひとつずつエラーを消していきます。

### 'Security.salt'とSecurity.cipherSeedを変更

app/Config/core.phpの'Security.salt'と'Security.cipherSeed'を変更します。

```php
/**
* A random string used in security hashing methods.
*/
Configure::write('Security.salt', 'DYhG93b0qyJfIxfs2guVoUubWwvniR2G0FgaC9mi○○○○');
/**
* A random numeric string (digits only) used to encrypt/decrypt strings.
*/
Configure::write('Security.cipherSeed', '76859309657453542496749683645○○○○');
```

Security.saltには適当な半角英数字、Security.cipherSeedには適当な半角数字を設定して保存します。

下記は例です。  
※セキュリティ上、必ずほかの値にしてください。

```php
/**
* A random string used in security hashing methods.
*/
Configure::write('Security.salt', 'DYhG93b0qyJfIxfs2guVoUubWwvniR2G0FgaC9micakephp');
/**
* A random numeric string (digits only) used to encrypt/decrypt strings.
*/
Configure::write('Security.cipherSeed', '768593096574535424967496836451234');
```

### app/tmpディレクトリの権限変更

app/tmpディレクトリにはキャッシュファイルやログファイルが作成されます。今のままでは書き込み権限がないので、書き込み権限を付与しします。

```bash
$ chmod -R 777 /Applications/MAMP/htdocs/cakephp/app/tmp/
```

### DB設定

DBの設定を行うには、まずDBを作成する必要があります。 ここでは、次のようなDB、ユーザを作成し、それを元にCakePHPのDB設定を行います。

| DB名 | ユーザー名 | パスワード |
| --- | --- | --- |
| cakephp | cakeuser | cakepass |


まず、MySQLでDBとユーザを作成します。

```sql
-- DB作成
CREATE DATABASE cakephp CHARACTER SET utf8;
-- ユーザを作成し権限を付与
GRANT ALL ON cakephp.* to 'cakeuser'@'localhost';
-- パスワード変更
SET PASSWORD FOR 'cakeuser'@'localhost' = PASSWORD('cakepass');
```

DBを作成したら、CakePHPの設定を行います。  
app/Config/database.php.defaultを同じディレクトリにコピーし、database.phpにリネームします。

```bash
$ cp /Applications/MAMP/htdocs/cakephp/app/Config/database.php.default /Applications/MAMP/htdocs/cakephp/app/Config/database.php
```

コピーしたら、database.phpを編集し、データベースの設定を行います。 先程作成したMySQLのDB、ユーザ情報をdatabase.phpに記述します。

```php
class DATABASE_CONFIG {

    public $default = array(
        'datasource' => 'Database/Mysql',
        'persistent' => false,
        'host' => 'localhost',     // ホスト名
        'login' => 'cakeuser',     // ユーザ名
        'password' => 'cakepass',  // パスワード
        'database' => 'cakephp',   // DB名
        'prefix' => '',
        'encoding' => 'utf8',      // 文字コード
    );

    public $test = array(
        'datasource' => 'Database/Mysql',
        'persistent' => false,
        'host' => 'localhost',
        'login' => 'user',
        'password' => 'password',
        'database' => 'test_database_name',
        'prefix' => '',
        //'encoding' => 'utf8',
    );
}
```

$testはテスト用のDBの設定です。今回は何も設定しません。

### 再度ブラウザからアクセス

ここまでの設定が完了したら、再度ブラウザから `http://localhost/cakephp/` にアクセスしてみます。 赤、黄色から緑になり、エラーが消えていると思います。

### DegubKitについて

一箇所だけ黄色で  
「DebugKit is not installed. It will help you inspect and debug different aspects of your application. You can install it from GitHub」  
と表示されていると思います。  
これはDebugKitというデバッグツールをインストールすれば消えますが、なくても開発はできますので、ここではインストール方法は書きません。 DebugKitのインストール方法については、改めて記事にしたいと思います。

### 初期設定完了

以上でCakePHPのローカル環境での初期設定は完了となります。

この記事に載せているユーザ名やパスワードなどは、あくまで一例ですので、本番稼働させる場合などは、セキュリティ面を考慮した上で各設定を行ってください。
