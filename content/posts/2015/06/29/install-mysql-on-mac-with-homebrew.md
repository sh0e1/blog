---
title: HomebrewでMySQLをMacにインストール
author: sh0e1
type: post
date: 2015-06-29T11:36:16+00:00
categories:
  - Mac
  - MySQL
---
ローカルの開発環境をHomebrewに移行することにしたので、MySQLをHomebrewでインストールしてみました。  
今回はインストール方法から初期設定までです。

Homebrewについては下記を参照してください。  
[MacにHomebrewをインストールしてパッケージを管理をする]({{< ref "/posts/2015/06/10/install-homebrew-on-mac-and-manage-packages.md" >}})
<!--more-->

### インストールして起動

まずはいつものbrew installコマンドでMySQLをインストールします。

```bash
$ brew install mysql
```

インストールが完了したらMySQLを起動します。

```bash
$ mysql.server start
Starting MySQL
. SUCCESS!
```

### 初期設定

インストール、起動と問題なく完了したら初期設定を行います。  
初期設定は対話形式で何点か質問を投げられますが、基本的には全てYesで問題ないです。

```bash
$ mysql_secure_installation
NOTE: RUNNING ALL PARTS OF THIS SCRIPT IS RECOMMENDED FOR ALL MySQL
SERVERS IN PRODUCTION USE!  PLEASE READ EACH STEP CAREFULLY!
In order to log into MySQL to secure it, we'll need the current
password for the root user.  If you've just installed MySQL, and
you haven't set the root password yet, the password will be blank,
so you should just press enter here.
Enter current password for root (enter for none): #rootのパスワードを入力
OK, successfully used password, moving on...
Setting the root password ensures that nobody can log into the MySQL
root user without the proper authorisation.
Set root password? [Y/n] y #rootのパスワードを変更するか
New password: #新しいパスワードを入力
Re-enter new password: #新しいパスワードをもう一度入力
Password updated successfully!
Reloading privilege tables..
... Success!
By default, a MySQL installation has an anonymous user, allowing anyone
to log into MySQL without having to have a user account created for
them.  This is intended only for testing, and to make the installation
go a bit smoother.  You should remove them before moving into a
production environment.
Remove anonymous users? [Y/n] y #anonymousユーザを削除するか
... Success!
Normally, root should only be allowed to connect from 'localhost'.  This
ensures that someone cannot guess at the root password from the network.
Disallow root login remotely? [Y/n] y #リモートからrootでのログインを拒否するか
... Success!
By default, MySQL comes with a database named 'test' that anyone can
access.  This is also intended only for testing, and should be removed
before moving into a production environment.
Remove test database and access to it? [Y/n] y #testデータベースを削除するか
- Dropping test database...
... Success!
- Removing privileges on test database...
... Success!
Reloading the privilege tables will ensure that all changes made so far
will take effect immediately.
Reload privilege tables now? [Y/n] y #特権テーブルをリロードするか
... Success!
All done!  If you've completed all of the above steps, your MySQL
installation should now be secure.
Thanks for using MySQL!
Cleaning up...
```

### MySQLに接続

初期設定まで完了したら、MySQLに接続します。  
接続は普段のmysqlコマンドで接続できます。

```bash
$ mysql -u root -p
Enter password: #rootのパスワードを入力
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 14
Server version: 5.6.25 Homebrew
Copyright (c) 2000, 2015, Oracle and/or its affiliates. All rights reserved.
Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.
Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.
mysql>
```

接続したら文字コードの確認。

```sql
mysql> show variables like 'character_set%';
+--------------------------+------------------------------------------------------+
| Variable_name            | Value                                                |
+--------------------------+------------------------------------------------------+
| character_set_client     | utf8                                                 |
| character_set_connection | utf8                                                 |
| character_set_database   | utf8                                                 |
| character_set_filesystem | binary                                               |
| character_set_results    | utf8                                                 |
| character_set_server     | utf8                                                 |
| character_set_system     | utf8                                                 |
| character_sets_dir       | /usr/local/Cellar/mysql/5.6.25/share/mysql/charsets/ |
+--------------------------+------------------------------------------------------+
8 rows in set (0.00 sec)
```

HomebrewでインストールしたMySQLは、デフォルトで文字コードがUTF-8になっているようです。  
いつもはmy.cnfを修正して文字コードをUTF-8にしていますが、今回は何もせずにすみました。

### その他の操作

ここでは、MySQLの停止、再起動、リロードだけ紹介します。

```bash
$ mysql.server stop #停止
$ mysql.server restart #再起動
$ mysql.server reload #リロード
```

### 設定ファイルの変更

my.cnfで設定を変更する場合は、my.cnfが読み込まれる場所を確認し、デフォルトのmy.cnfをその場所に配置します。

```bash
# my.cnfが読み込まれる場所を確認
$ mysql --help | grep my.cnf
order of preference, my.cnf, $MYSQL_TCP_PORT,
/etc/my.cnf /etc/mysql/my.cnf /usr/local/etc/my.cnf ~/.my.cnf
# HomebrewでインストールしたMySQLのmy-default.cnfをコピー
$ sudo cp /usr/local/Cellar/mysql/5.6.25/support-files/my-default.cnf /usr/local/etc/my.cnf
```

今回は/usr/local/etc/にmy.cnfをコピーしました。  
あとは/usr/local/etc/my.cnfを適宜変更して設定を変更します。

以上、HomebrewでのMySQLのインストール方法から初期設定まででした。
