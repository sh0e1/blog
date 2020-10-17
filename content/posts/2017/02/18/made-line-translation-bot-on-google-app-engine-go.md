---
title: Google App Engine/GoでLINEの翻訳botをつくってみた
author: sh0e1
type: post
date: 2017-02-18T02:57:09+00:00
categories:
  - Go
  - Google Cloud Platform
---
[LINE BOT AWARDS](https://botawards.line.me/ja/)に応募しようと思ってGoogle App Engine / Goで翻訳botをつくってみたので紹介します。  
~~[レベッカ（翻訳家）LINE bot](https://translation-konjac.appspot.com/)~~
<!--more-->

### 機能の紹介

#### 主な機能

- テキストメッセージの翻訳
- 写真内の文字の翻訳
- ボイスメッセージの翻訳
- グループトークでの複数言語への翻訳

日本語以外の言語で入力すると、全て日本語に翻訳して返信します。日本語で入力すると、友達追加時に選択した言語（未選択の場合は英語）に翻訳します。  
写真内の文字も、テキストメッセージと同様に翻訳して返信します。  
ボイスメッセージは、ボイスメッセージ送信後に何語のボイスメッセージか選択しなければなりません。元の言語が何語かわからないと、音声認識が正確に出来ないためです。これは少し面倒ですね。  
グループトークはグループ追加時に選択した言語（複数選択可）に、テキストメッセージ、写真内の文字、ボイスメッセージを翻訳します。

#### 対応言語

現在、下記の言語に対応しています。

日本語 / 英語 / 中国語（繁体字、簡体字） / フランス語 / ロシア語 / スペイン語 / アラビア語 / ドイツ語 / ヒンディー語 / イタリア語 / ポルトガル語 / 韓国語 / インドネシア語 / オランダ語

#### 注意事項

<span class="text-danger">翻訳結果が必ずしも正しいとは限らないのでご注意ください。</span>

#### 友達追加

~~もし良ければ、QRコード、または友達追加ボタンから友達に追加して使ってみてください。~~

### 技術的な話

ここからは技術的な話。

#### サーバ構成

Google Cloud Platformのサービスのみ使って実装しました。具体的には下記を使っています。

- App Engine
- Compute Engine
- Cloud DataStore
- Cloud Storage

#### API

翻訳、画像認識、音声認識も全てGoogleのAPIを使っています。

- Vision API
- Speech API
- Translate API

#### 各機能の処理詳細

各機能をどのように処理しているか、簡単な説明です。

##### テキストメッセージ

送信されたメッセージをTranslate APIで翻訳。

##### 写真内の文字

送信された写真内の文字をVision　APIで認識し、認識した文字をTranslate APIで翻訳。

##### ボイスメッセージ

これの実装が少し面倒だった。LINEから取得できるボイスメッセージがmp4なのだが、mp4だとSpeech APIで音声認識が出来ないため、mp4からflacに変換する必要があった。しかし、App Engineではファイルの変換は出来ないため、mp4からflacへ変換用のプログラムを書いて（これもGo）、Compute Engineでデーモンで動かすことにした。ファイルの変換には[FFmpeg](https://ffmpeg.org/)を使っている。  
まず、送信されたボイスメッセージをCloud Storageにアップロードしてテンプレートメッセージを返信。ユーザがテンプレートメッセージを選択してくれたら、App EngineのTask Queueにタスクを登録。一旦テンプレートメッセージを送っているのは、ボイスメッセージの言語がわからないと音声が正しく認識出来ないため。  
Compute Engineで動いているプログラムは、Task Queueを監視していて、タスク追加されたらまずCloud Storageから対象のmp4ファイルをダウンロードし、ローカル(Compute Engine内)でflacに変換。Speech APIで変換したflacファイルの音声認識を行い、取得したテキストをTranslate APIで翻訳している。

### 課題

『先生』とか熟語を入力すると、英語翻訳にしていても、そのまま『先生』と返ってくることがあります。これは『先生』という言葉が中国語だと認識されているのが原因ですが、日本語以外の言語は全て日本語に翻訳するという仕様がまずかったかもしれません。  
対応言語が多いせいか、直感的に使いづらくなってしまったような気がします。言語の選択とかないほうが使いやすかったと思います。多機能でも使いづらければ意味がなく、ここの両立は中々難しいところです。

### あとがき

ひとまず完成してエントリーできたので良かったです。このまま運用していきたいですが、LINEのPushメッセージの送信には結構お金がかかる（LINE BOT AWARDSが終わるまでは無料）ので、どうしようか悩んでます。  
もしよかったら友達登録して使ってみてください。

### 2017/03/11追記

Botの維持費が結構かかるので、LINEアカウントを削除しました。