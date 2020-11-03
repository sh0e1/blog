---
title: "coc.nvimでtextlintを使う"
author: sh0e1
type: post
date: 2020-10-26T22:28:56+09:00
categories:
  - Vim
  - neovim
---
WordPressからHogoへの移行に伴い、記事をMarkdownで書くようになったのでtextlintのセットアップを行いました。  
普段nvimとcoc.nvimを使っているので、textlintもefm-langserverを使ってcoc.nvimから使えるようにしました。

coc.nvim -> efm-langserver -> textlint

設定ファイルはGitHubの[dotfiles](https://github.com/sh0e1/dotfiles)リポジトリにもあげています。
<!--more-->

### 前提条件

- neovimとcoc.nvimを導入済み
    - neovim  v0.4.4
    - coc.nvim 0.0.79-6cb5c6cd2d

### 各ツールのインストール

#### textlint

[textlint](https://github.com/textlint/textlint)とtextlintルールの[textlint-rule-preset-ja-technical-writing](https://github.com/textlint-ja/textlint-rule-preset-ja-technical-writing)をインストールします。

```bash
npm install -g textlint
npm install -g textlint-rule-preset-ja-technical-writing
```

#### efm-langserver

[efm-langserver](https://github.com/mattn/efm-langserver)を使いtextlintをLanguage Server化することで、coc.nvimでdiagnosticsを表示できるようにします。

```bash
go get github.com/mattn/efm-langserver
```

### 各設定

#### textlint

textlintは `$HOME/.textlintrc` に下記のように設定ファイルを用意しました。  
インストールしたルールプリセットの `preset-ja-technical-writing` を有効にしています。

```json
{
  "rules": {
    "preset-ja-technical-writing": true
  }
}
```

設定ファイルの詳細は下記のドキュメントにあります。  
https://github.com/textlint/textlint/blob/master/docs/configuring.md

#### efm-langserver

efm-langserverは `$HOME/.config/efm-langserver/config.yaml` に下記のように設定ファイルを用意しました。

```yaml
version: 2
root-markers:
  - .git/

tools:
  textlint: &textlint
    lint-command: 'textlint --format unix --stdin --stdin-filename ${INPUT}'
    lint-ignore-exit-code: true
    lint-stdin: true
    lint-formats:
      - '%f:%l:%c: %m [%trror/%r]'
    root-markers:
      - .textlintrc

languages:
  markdown:
    - <<: *textlint
```

lint-commandにはtextlintの実行コマンドを設定しています。  
`--format unix` オプションをつけて実行すると、実行結果が下記のように出力されるので、出力に合わせてlint-formatsでフォーマットを指定しています。

```bash
textlint --format unix README.md
/path/to/README.md:5:5: 文末が"。"で終わっていません。 [Error/ja-technical-writing/ja-no-mixed-period]

1 problem
```

`--stdin --stdin-filename ${INPUT}` はバッファに対してlintを実行するようにしていますが、 `--stdin` だけだとプレインテキストとしてlintが実行されるので、 `--stdin-filename` オプションでファイル名も渡す必要があります。  
下記のGitHub Issueに記載がありました。  
https://github.com/textlint/textlint/issues/117

#### coc.nvim

coc.nvimの設定は[efm-langserver](https://github.com/mattn/efm-langserver)のREADMEにある設定をそのままもってきました。

```json
{
  "languageserver": {
    "efm": {
      "command": "efm-langserver",
      "args": [],
      "filetypes": ["markdown"]
    }
  }
}
```

### 動作

最終的に下記のように動作するようになりました。

{{< figure src="/images/2020/10/26/screenshot.png" >}}

### 参考

下記を参考にさせていただきました。

- https://www.getto.systems/entry/2020/01/31/003734
- https://mattn.kaoriya.net/software/lang/go/20190205190203.htm
