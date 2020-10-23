---
title: CentOS 6.6にmemcachedをインストールしてPHPセッション管理
author: sh0e1
type: post
date: 2015-06-16T15:42:48+00:00
categories:
  - PHP
---
先日、CentOS 6.6にmemcachedをインストールしてみました。  
せっかくインストールしたので、そのままmemcachedでPHPのセッション管理を行うようにしました。

各バージョンは下記の通りです。

- CentOS 6.6 (Final)
- Apache 2.2.15
- PHP 5.5.25
- memcached 1.4.4
<!--more-->

### memcachedとは

> memcached は、汎用の分散型メモリキャッシュシステムである。 memcached は、データとオブジェクトをメモリ内にキャッシュすることでデータベースから読み出しを行う回数を減少させ、データベースを用いた Web サイトを高速化するために良く用いられる。
> 
> [memcached - Wikipedia](https://ja.wikipedia.org/wiki/Memcached)

データベースを用いたWebサイトを高速化するので、WordPressで作成したサイトを高速化したい場合にもmemcachedは有効です。

### memcachedインストール

早速コマンドでインストールしていきます。

```bash
$ #yumでインストール
$ sudo yum install memcached
$ #起動
$ sudo /etc/init.d/memcached start
$ #自動起動設定
$ sudo chkconfig memcached on
```

### 動作確認

インストールしたらtelnetで動作確認をします。

```bash
$ telnet localhost 11211
Trying ::1...
Connected to localhost.
Escape character is '^]'.
stats # ← statsと入力
STAT pid 9609
STAT uptime 227
STAT time 1429793229
STAT version 1.4.4
STAT pointer_size 64
STAT rusage_user 0.004999
STAT rusage_system 0.004999
STAT curr_connections 10
STAT total_connections 12
STAT connection_structures 11
STAT cmd_get 0
STAT cmd_set 0
STAT cmd_flush 0
STAT get_hits 0
STAT get_misses 0
STAT delete_misses 0
STAT delete_hits 0
STAT incr_misses 0
STAT incr_hits 0
STAT decr_misses 0
STAT decr_hits 0
STAT cas_misses 0
STAT cas_hits 0
STAT cas_badval 0
STAT auth_cmds 0
STAT auth_errors 0
STAT bytes_read 19
STAT bytes_written 7
STAT limit_maxbytes 67108864
STAT accepting_conns 1
STAT listen_disabled_num 0
STAT threads 4
STAT conn_yields 0
STAT bytes 0
STAT curr_items 0
STAT total_items 0
STAT evictions 0
END
quit  # ← quitと入力して終了
```

### memcachedの設定ファイル

設定ファイルは/etc/sysconfig/memcachedになります。今回はデフォルトのままにしました。

```bash
$ sudo vim /etc/sysconfig/memcached
PORT="11211"     # ポート番号
USER="memcached" # 実行ユーザ
MAXCONN="1024"   # 最大接続数
CACHESIZE="64"   # メモリサイズ
OPTIONS=""       # オプション
```

設定を変更したら再起動を忘れずに。

```bash
$ sudo /etc/init.d/memcached restart
```

### PHPモジュールインストール

PHPモジュールはmemcacheとmemcachedがありますが、今回はmemcachedをインストールします。  
Googleで調べてみるとmemcachedのほうが高速らしい？です。

```bash
$ sudo yum install php-pecl-memcached
```

### php.iniの変更

php.iniのセッションの設定を変更します。  
私の環境では/etc/httpd/conf.d/php.confにセッションの設定があったのでこちらを変更しました。

```bash
$ sudo vim /etc/httpd/conf.d/php.conf
# session.save_handler = files               コメントアウト
# session.save_path = "/var/lib/php/session" コメントアウト
```

次にmemcached.iniのコメントアウトを外します。

```bash
$ vim /etc/php.d/z-memcached.ini
session.save_handler = memcached      # コメントアウトをはずす
session.save_path = "localhost:11211" # コメントアウトをはずす
```

php.iniのLocal Valueのみを変えたい場合は、Apacheのconfファイル、.htaccess、プログラム内でini_set()で変更してください。

設定を変更したらApacheを再起動します。

```bash
$ sudo /etc/init.d/httpd restart
```

### cacheの確認

memcached-toolでcacheの確認ができます。

```bash
$ memcached-tool localhost:11211 dump
```

以上で、PHPセッションをmemcachedで管理するようになりました。
