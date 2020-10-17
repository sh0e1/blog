---
title: VagrantでNode.jsの開発環境を整える
author: sh0e1
type: post
date: 2016-04-19T13:05:18+00:00
categories:
  - Node.js
---
かなり久しぶりの更新になりました。  
今回はPHPから離れてMacでVagrantを使って、Node.jsの開発環境構築についてです。
<!--more-->

### 前提条件

- Mac OS X Yosemite(10.10.5)
- Homebrew Caskがインストールされていること

Homebrewについては[こちら]()を参照してください。

### Vagrant、VirtualBoxのインストール

#### VirtualBoxのインストール

```bash
$ brew cask install virtualbox
```

#### Vagrantのインストール

```bash
$ brew cask install vagrant
```

### Vagrantの起動/設定

#### 初期化

```bash
$ vagrant init
```

初期化すると現在のディレクトリにVagrantfileが作成されます。

#### 設定変更

Vagrantfileを編集し、boxの設定をします。今回はcentos6で環境を構築します。

```bash
$ vi Vagrantfile

# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure(2) do |config|
  # The most common configuration options are documented and commented below.
  # For a complete reference, please see the online documentation at
  # https://docs.vagrantup.com.

  # Every Vagrant development environment requires a box. You can search for
  # boxes at https://atlas.hashicorp.com/search.
  config.vm.box = "puphpet/centos65-x64" <-centos6に変更

  # Disable automatic box update checking. If you disable this, then
  # boxes will only be checked for updates when the user runs
  # `vagrant box outdated`. This is not recommended.
  # config.vm.box_check_update = false

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine. In the example below,
  # accessing "localhost:8080" will access port 80 on the guest machine.
  # config.vm.network "forwarded_port", guest: 80, host: 8080

  # Create a private network, which allows host-only access to the machine
  # using a specific IP.
  # config.vm.network "private_network", ip: "192.168.33.10"

  # Create a public network, which generally matched to bridged network.
  # Bridged networks make the machine appear as another physical device on
  # your network.
  # config.vm.network "public_network"

  # Share an additional folder to the guest VM. The first argument is
  # the path on the host to the actual folder. The second argument is
  # the path on the guest to mount the folder. And the optional third
  # argument is a set of non-required options.
  # config.vm.synced_folder "../data", "/vagrant_data"

  # Provider-specific configuration so you can fine-tune various
  # backing providers for Vagrant. These expose provider-specific options.
  # Example for VirtualBox:
  #
  # config.vm.provider "virtualbox" do |vb|
  #   # Display the VirtualBox GUI when booting the machine
  #   vb.gui = true
  #
  #   # Customize the amount of memory on the VM:
  #   vb.memory = "1024"
  # end
  #
  # View the documentation for the provider you are using for more
  # information on available options.

  # Define a Vagrant Push strategy for pushing to Atlas. Other push strategies
  # such as FTP and Heroku are also available. See the documentation at
  # https://docs.vagrantup.com/v2/push/atlas.html for more information.
  # config.push.define "atlas" do |push|
  #   push.app = "YOUR_ATLAS_USERNAME/YOUR_APPLICATION_NAME"
  # end

  # Enable provisioning with a shell script. Additional provisioners such as
  # Puppet, Chef, Ansible, Salt, and Docker are also available. Please see the
  # documentation for more information about their specific syntax and use.
  # config.vm.provision "shell", inline: &lt;&lt;-SHELL
  #   sudo apt-get update
  #   sudo apt-get install -y apache2
  # SHELL
end
```

#### 起動

Vagrantfileを変更したら、Vagrantを起動します。

```bash
$ vagrant up
```

初回起動時のみboxのダウンロードがあるので少し時間がかかりますが、2回目以降からはすぐに起動するようになります。

#### SSH接続

Vagrantで起動した仮想環境にSSHで接続します。

```bash
$ vagrant ssh
Last login: Sat Apr 16 13:14:02 2016 from 10.0.2.2
----------------------------------------------------------------
  CentOS 6.7                                  built 2015-12-01
----------------------------------------------------------------
```

Macだとvagrant sshコマンドを叩けばsshで接続されますが、Windowsのコマンドプロンプトではssh接続情報が表示されるので、Tera Term、PuTTYなどのsshクライアントで接続する必要があります。その際のユーザ名、パスワードは下記の通りです。

| ユーザ名 | パスワード |
| --- | --- |
| vagrant | vagrant |

#### Vagrantのその他の設定

今回は使わないが、よく使うVagrantの設定を簡単に紹介します。

##### ポートフォワード

VirtualBoxでもポートフォワードはできますが、VagrantではVagrantfileに設定を記述するだけで、ポートフォワードができます。

```bash
config.vm.network "forwarded_port", guest: 80, host: 8080
```

上記の設定ではホストマシンの8080番ポートをゲストマシンの80番ポートにポートフォワードしています。  
つまりlocalhost:8080でブラウザからゲストマシンのwebページ（80番ポート）にアクセスできるようになります。

##### ディレクトリの同期

Vagrantではホストマシンのディレクトリと、ゲストマシンのディレクトリを同期することができます。  
デフォルトではホストマシンのホームディレクトリと、ゲストマシンの/vagrantディレクトリが同期されます。  
同期するディレクトリを変更したい場合はVagrantfileに記述します。

```bash
config.vm.synced_folder "../data", "/vagrant_data"
```

例えばホストマシンのworkspaceディレクトリと、ゲストマシンの/var/wwwを同期する場合は下記のようになります。

```bash
config.vm.synced_folder "/path/to/workspace", "/var/www"
```

### Node.jsのインストール

#### nvmのインストール

今回は[nvm](https://github.com/creationix/nvm)でNode.jsをインストールします。  
nvmとはNode.jsのバージョンを簡単に管理するもの(Node Version Managerの略)です。  
Node.jsはVagrantの仮想環境にインストールします。  
nvmをインストールするにはホームディレクトリで下記コマンドを実行します。

```bash
$ curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.31.0/install.sh | bash
```

インストールが完了したらパスを通します。今回は~/.bashrcに追記しました。

```bash
$ vi ~/.bashrc

# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
    . /etc/bashrc
fi

# User specific aliases and functions

export NVM_DIR="/home/vagrant/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"  # This loads nvm
```

追記したらsourceコマンドで反映します。

```bash
$ source ~/.bashrc
```

反映後、バージョンが表示されれば、nvmのインストールは完了です。

```bash
$ nvm --version
0.31.0
```

#### Node.jsのインストール

nvmでインストールできるNode.jsのバージョン一覧を確認します。

```bash
$ nvm ls-remote
```

今回はv0.12.13をインストールします。

```bash
$ nvm install v0.12.13
```

インストールしたらバージョンを確認します。

```bash
$ node -v
v0.12.13
```

これでNode.jsのインストールは完了です。

### Hello world!

ホストマシンとゲストマシンのディレクトリを同期しているので、ホストマシンでコーディングし、ゲストマシンで動作確認ができます。  
まず、ホストマシンでhelloworld.jsを作成します。

```javascript
// helloworld.js
console.log("Hello world!");
```

ホストマシンで作成したhelloworld.jsをゲストマシンで実行します。

```bash
$ node /path/to/helloworld.js
Hello world!
```

以上、「VagrantでNode.jsの開発環境を整える」でした。
