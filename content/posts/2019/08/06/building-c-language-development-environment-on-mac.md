---
title: MacでC言語の開発環境構築
author: sh0e1
type: post
date: 2019-08-05T16:33:35+00:00
categories:
  - C
  - Vim
---
アルゴリズムとC言語の勉強をしようと思い下記の本を買ったので、MacでC言語の開発環境を構築しました。  
またどうせならVimを使ってコードを書いていこうと思い、Vimの設定も行ったのでそれも合わせて書きます。
<!--more-->

### 前提条件

- macOS Mojave (バージョン 10.14.6)
- Vimはインストール済み (version 8.1.1800)
- Vimのパッケージマネージャーは[Vundle.vim](https://github.com/VundleVim/Vundle.vim)

### Clangのインストール

C言語のコンパイラといえばgccだと思っていたのですが、色々調べてみたらClangというものがあるらしいです。

> Clang ([ˈklæŋ]：クランのように発音)は、プログラミング言語 C、C++、Objective-C、Objective-C++ 向けのコンパイラフロントエンドである。バックエンドとして LLVM を使用しており、LLVM 2.6以降は LLVM の一部としてリリースされている。
>
> プロジェクトの目標は、GNUコンパイラコレクション (GCC) を置き換えることのできるコンパイラを提供することである。開発は完全にオープンソースの方法で進められており、アップルやGoogleといった大企業も参加・資金提供している。ソースコードは、イリノイ大学/NCSAオープンソースライセンスで提供されている。
>
> macOSおよびiOS（ともにXcodeの付属として）、ならびにFreeBSDにおいて標準のコンパイラとして採用されている。
>
> Clang プロジェクトではコンパイラのフロントエンドに加えてClang静的コード解析ツールも開発している。

今回使おうとしていたVimプラグインもClang用みたいなので、今回はClangを使っていこうと思います。  
ClangはCommmand Line Toolsをインストールすると、一緒にインストールされるようです。

```bash
$ xcode-select --install
xcode-select: error: command line tools are already installed, use "Software Update" to install updates
```

私の環境だとすでにCommand Line Toolsがインストールされているので `xcode-select: error: command line tools are already installed, use "Software Update" to install updates` と表示されました。  
clangがインストールされれば `clang --version` でバージョン情報が表示されます。

```bash
$ clang --version
Apple LLVM version 10.0.1 (clang-1001.0.46.4)
Target: x86_64-apple-darwin18.7.0
Thread model: posix
InstalledDir: /Library/Developer/CommandLineTools/usr/bin
```

### Vimの設定

VimでC言語のコーディングをしやすくするためにVimの設定をします。  
今回は自動で入力補完をしてくれる[vim-clang](https://github.com/justmao945/vim-clang)だけインストールします。他にも `.c` と `.h` ファイル間の移動を楽にしてくれる[a.vim](https://github.com/vim-scripts/a.vim)などのプラグインもありますが、必要になったら都度インストールしていきたいと思います。

#### clang-formatのインストール

vim-clangでclang-formatを使用するようなので、インストールします。

```bash
$ brew update && brew install clang-format
Already up-to-date.
==> Downloading https://homebrew.bintray.com/bottles/clang-format-2019-01-18.mojave.bottle.tar.gz
==> Downloading from https://akamai.bintray.com/e2/e21e425f294cb6daf81dce2de430401dbc00369fc7cc2c3ff76770eee50b149f?__gda__=exp=156
######################################################################## 100.0%
==> Pouring clang-format-2019-01-18.mojave.bottle.tar.gz
🍺  /usr/local/Cellar/clang-format/2019-01-18: 12 files, 7.1MB
```

#### vim-clangのインストール

Vimのパッケージマネージャーは[Vundle.vim](https://github.com/VundleVim/Vundle.vim)を使っているので、 `.vimrc` に下記を追記します。

```vim
Plugin 'justmao945/vim-clang'
```

追記したら `:VundleInstall` を実行します。

```vim
:VundleInstall
```

これで自動補完が使えるようになってるはずです。オプションも色々ありますが、後で設定していきたいと思います。  
あと便利なのが `:ClangFormat` でコードを整形できます。

**整形前**

```c++
#include <stdio.h>

int main(void) {
printf("Hello World\n");
return 0;
}
```

**整形後**

```c++
#include <stdio.h>

int main(void) {
  printf("hello world\n");
  return 0;
}
```

Goを書くようになってフォーマッタがないとコーディング辛く感じるようになっていたので、整形できるのは本当にありがたいです。 `gofmt` のように保存時に実行してくれるように後で設定したいと思います。

### Hello World

環境が準備できたので、Hello Worldを実行します。

```bash
$ vim hello.c
```

```c++
#include <stdio.h>

int main(void) {
  printf("hello world\n");
  return 0;
}
```

ソースコードを書いたらclangでコンパイルして実行します。

```bash
$ clang hello.c -o hello.o
$ ./hello.o
Hello World
```

無事Hello Worldが実行できました。

今後はC言語のことも書いていきたいと思います。
