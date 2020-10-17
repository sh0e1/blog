---
title: MacのiTerm2で作業ログを出力する方法
author: sh0e1
type: post
date: 2016-06-03T12:56:43+00:00
categories:
  - Mac
---
MacのiTerm2で作業ログを出力するように設定しました。  
今回はその設定方法を紹介します。
<!--more-->

### ログを出力するディレクトリを作成

まずログを出力するディレクトリを作成します。  
今回は `/var/log/iterm2` ディレクトリを作成し、そのディレクトリにログを出力するようにしたいと思います。

```bash
$ sudo mkdir /var/log/iterm2
```

### iTerm2の設定変更

まず、iTerm2を起動して、上部メニューからProfiles > Option Profiles...を選択します。  
次にProfile NameのDefaultを選択し、Edit Profilesをクリックします。  
次に、Profiles > Sessionとクリックして、Automatically log session input to file in:にチェックを入れ、ログを出力するディレクトリパスを入力します。  
これで設定は完了ですが、ディレクトリパスの横に「！」が表示されている場合は、書き込み権限がなく、ログを出力することができないので、ディレクトリのパーミッションを変更します。

### ディレクトリのパーミションを変更

今回作成した `/var/log/iterm2` ディレクトリに書き込み権限がありませんので、パーミッションを変更します。  
オーナーを変更してもいいですが、今回はディレクトリのグループをadminにして、グループに書き込み権限を付与しました。

```bash
$ ls -la /var/log/ | grep iterm2     # 権限の確認
drwxr-xr-x   2 root             wheel                 68  6  3 21:10 iterm2
$ sudo chown :admin /var/log/iterm2/ # グループをadminにする
$ sudo chmod 775 /var/log/iterm2/    # グループに書き込み権限を付与
$ ls -la /var/log/ | grep iterm2     # 権限の再確認
drwxrwxr-x   2 root             admin                 68  6  3 21:10 iterm2
```

<pre><code class="bash"></code></pre>

これで権限の問題は解消されたので、環境設定画面で入力したディレクトリパスの横の「！」が消えていると思います。

### ログが出力されているか確認

設定は全て環境したので、一旦iTerm2を終了し、再起動してから、lsコマンドでログが出力されているか確認します。

```bash
$ ls -la /var/log/iterm2/
total 8
drwxrwxr-x   3 root   admin   102  6  3 21:52 .
drwxr-xr-x  67 root   wheel  2278  6  3 21:10 ..
-rw-r--r--   1 sh0e1  admin   240  6  3 21:53 20160603_215248.Default.w0t0p1:E261E7BE-817A-4338-89BB-DEDCA40CA80C.17884.878741ed.log
```

ログが出力されているのが確認できました。  
以上、MacのiTerm2で作業ログを出力する方法でした。
