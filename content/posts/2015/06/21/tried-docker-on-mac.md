---
title: 今更MacでDockerを使ってみた
author: sh0e1
type: post
date: 2015-06-21T13:28:13+00:00
categories:
  - Docker
  - Mac
---
今更ですが、MacでDockerの環境を整えて使ってみました。  
今まで難しそうなイメージで避けてきましたが、そろそろ手を出しておかないと本気でまずいと思い今回使ってみましたが、思ったよりも簡単に使えました。
<!--more-->

### Dockerとは

> Docker（ドッカー）はソフトウェアコンテナ内のアプリケーションのデプロイメントを自動化するオープンソースソフトウェアである。
> 
> LinuxカーネルにおけるLXCと呼ばれるLinuxコンテナ技術とAufsという特殊なファイルシステムを利用してコンテナ型の仮想化を行う。VMware製品などの完全仮想化を行うハイパーバイザー型製品と比べて、ディスク使用量は少なく、インスタンス作成やインスタンス起動は速く、性能劣化がほとんどないという利点を持つ。dockerfileと呼ばれる設定ファイルからコンテナイメージファイルを作成可能という特性を持つ。一方で、コンテナOSとしてはホストOSと同じLinuxカーネルしか動作しない。
> 
> [Docker - Wikipedia](https://ja.wikipedia.org/wiki/Docker)

### MacでDockerを使うには

MacでDockerを使うには、VirtualBox、boot2docker、Dockerをインストールする必要があります。今回は全てHomebrewからインストールしました。

Homebrewのインストール方法、使い方はこちらを参照してください。  
[MacにHomebrewをインストールしてパッケージを管理をする]({{< ref "/posts/2015/06/10/install-homebrew-on-mac-and-manage-packages.md" >}})

VirtualBoxでなくても仮想化ソフトなら問題ないと思います。

MacではVirtualBoxなどの仮想化ソフトでboot2docker(Dockerサーバ)の仮想環境を構築し、ローカルからDockerサーバを操作し Dockerコンテナを実行しているみたいです。

### VirtualBoxのインストール

まずはVirtualBoxからインストールします。

```bash
$ brew cask install virtualbox
```

### Docker、boot2dockerをインストール

次にDockerとboot2dockerをインストールします。

```bash
$ brew install docker boot2docker
```

インストールをしたらboot2dockerの初期化の為に下記コマンドを実行します。

```bash
$ boot2docker init
```

初期化後、boot2dockerを起動します。

```bash
$ boot2docker up
```

boot2dockerを起動すると、To connect the Docker client to the Docker daemon, please set:とメッセージが表示されるので、表示された通りに環境変数を設定します。  
今回は.zshrcに設定しました。

```bash
$ cat<<'EOS'>~/.zshrc
> # boot2docker
> export DOCKER_HOST=tcp://192.168.59.103:2376
> export DOCKER_CERT_PATH=/Users/username/.boot2docker/certs/boot2docker-vm
> export DOCKER_TLS_VERIFY=1
> EOS
```

```bash
$ source ~/.zshrc
```

ここまで完了したらdockerコマンドが正常に動作するか下記コマンドで確認します。

```bash
$ docker version
Client version: 1.6.2
Client API version: 1.18
Go version (client): go1.4.2
Git commit (client): 7c8fca2
OS/Arch (client): darwin/amd64
Server version: 1.6.2
Server API version: 1.18
Go version (server): go1.4.2
Git commit (server): 7c8fca2
OS/Arch (server): linux/amd64
```

私の環境ではこのように表示されました。  
これでインストールは完了です。

### コンテナの操作

dockerコマンドでコンテナを操作します。  
個人的にCentOSを使うことが多いので、ここではCentOS 6を例にしたいと思います。

まずCentOSのイメージファイルを取得します。

```bash
$ docker pull centos:centos6
```

取得したイメージファイルは下記コマンドで確認できます。

```bash
$ docker images
REPOSITORY          TAG                 IMAGE ID            CREATED             VIRTUAL SIZE
centos              centos6             b9aeeaeb5e17        8 weeks ago         202.6 MB
```

取得したイメージファイルをdocer runコマンドでコンテナとして起動します。

```bash
$ docker run -i -t --name centos centos:centos6 /bin/bash
```

ここでは -name オプションでコンテナ名をcentosとして起動しています。コンテナ名をつけるとコンテナ操作時にコンテナ名で操作できるようになります。  
また、上記コマンド実行後は起動したコンテナに接続した状態になります。

コンテナを確認するには、次のコマンドを実行します。

```bash
$ docker ps -a
CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS              PORTS               NAMES
9da3dd45d0d5        centos:centos6      "/bin/bash"         2 minutes ago       Up 2 minutes                            centos
```

起動しているコンテナを停止するには次のコマンドを実行します。

```bash
$ docker stop centos
```

centosはdocker run時に-nameで指定したコンテナ名です。コンテナ名を指定していない場合は、docker ps -aコマンドで表示されるCONTAINER IDで指定します。

一度停止したコンテナを再起動するにはdocker startコマンドを実行します。

```bash
$ docker start centos
```

コンテナに再接続するには次のコマンドを実行します。

```bash
$ docker attach centos
```

### コンテナにApacheをインストールしてブラウザで表示

コンテナに接続している状態でApacheをインストールします。

```bash
# yum update
# yum install httpd
# chkconfig httpd on
# /etc/init.d/httpd start
Starting httpd: httpd: Could not reliably determine the server's fully qualified domain name, using 172.17.0.4 for ServerName
[  OK  ]
```

コンテナはコミットすると、現在のコンテナの状態をイメージファイルを保存できます。

```bash
$ docker commit centos docker/centos
```

このコミットしたイメージファイルを起動すると、Apacheがインストールされた状態のコンテナが起動されます。

```bash
$ docker run -i -t -d -p 80:80 --name centos docker/centos /sbin/init
```

-d オプションを指定すると、SSHでログインせずにバックグラウンドで起動されます。  
-p オプションでホスト(boot2docker)とコンテナをポートマッピングを指定します。ポートマッピングを指定することで、boot2dockerの80番ポートにアクセスするとコンテナの80ポートにアクセスできるようになります。

ポートマッピングを指定してコンテンを起動したら、boot2dockerのipを確認します。

```bash
$ boot2docker ip
```

表示されたipにブラウザからアクセスすると、ApacheのTest Pageが表示されると思います。

以上、Dockerのインストールから基本的な使い方でした。

### その他

まだ試していませんが、DockerではDockerfileを作成してdocker buildコマンドを使えば、自動で環境を構築できるらしいです。自動で環境を構築してくれるのは非常にありがたいです。これは試してみて改めて記事として書きたいと思います。

また、テスト環境としてDockerを使うのはイメージしやすいのですが、開発環境として使うにはもう少し色々とやらないといけないんじゃないかと思っています。ちらっと調べてみたら、VagrantとDockerを使えば、ローカルのソースとコンテナのソースを同期できるみたいなので、こちらの後で試してみたいと思います。

かなり話題になっていたDockerですが、手を出すのが遅すぎました。話題の技術はどんどん習得していかねばと思う今日このごろです。
