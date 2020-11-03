---
title: "Hugo + Firebase HostingでGitHub Actionsを使ったCI/CD"
author: sh0e1
type: post
date: 2020-10-29T21:43:04+09:00
categories:
  - Firebase
  - GitHub Actions
  - CI/CD
---
今回はHugo + Firebase Hosting + GitHub ActionsでのCI/CDについて書きます。

このブログはHugo + Firebase Hostingで構築していますが、GitHub Actionsを使ってデプロイを自動化しています。  
また、Firebase Hostingのプレビューチャンネル（ベータ版）機能を利用し、公開前にサイトを確認しています。  
Firebase HostingでのGitHub Actionsの設定は `firebase init` コマンドを実行すると自動で設定され、すぐに利用できます。  
Hogoで利用する場合は `hugo` コマンドをGitHub Actionsの設定ファイルに追記するだけです。  
ただし少しハマった点もあるので、その点についても少し書きます。
<!--more-->

### CI/CDのフロー

1. featureブランチをPushしてPRを作成
1. GitHub ActionsでFirebase Hosingのプレビューチャンネルにデプロイ
1. プレビューチャンネルで確認
1. master or mainブランチへマージ
1. GitHub Actionsでライブチャンネル（本番環境）へデプロイ

### 前提条件

- [Firebase Console](https://console.firebase.google.com/?hl=JA)でプロジェクトを作成済み
- [Firebase CLI](https://firebase.google.com/docs/cli?hl=ja)をインストール済み
- [Hugo](https://gohugo.io/)でローカルにサイトを作成済み
- GitHubにリポジトリを作成済み

### GitHub ActionsでFirebase Hostingにデプロイする

`firebase init` を実行すると自動でGitHub Actionsの設定ファイルの作成、デプロイに使用するサービスアカウントのGitHub secretへの登録が実行されます。  
ローカルでHugoを使ったサイトの実装が終わってる前提で、プロジェクトのルートディレクトリで `firebase init` を実行し、対話型で設定を進めます。

```bash
firebase init

     ######## #### ########  ######## ########     ###     ######  ########
     ##        ##  ##     ## ##       ##     ##  ##   ##  ##       ##
     ######    ##  ########  ######   ########  #########  ######  ######
     ##        ##  ##    ##  ##       ##     ## ##     ##       ## ##
     ##       #### ##     ## ######## ########  ##     ##  ######  ########

You're about to initialize a Firebase project in this directory:

  /path/to/project

? Which Firebase CLI features do you want to set up for this folder? Press Space to select features, then Enter to confirm your choices. Hosting: Configure an
d deploy Firebase Hosting sites

=== Project Setup

First, let's associate this project directory with a Firebase project.
You can create multiple project aliases by running firebase use --add,
but for now we'll just set up a default project.

? Please select an option: Use an existing project
? Select a default Firebase project for this directory: YOUR_PROJECT_ID (YOUR_PROJECT)
i  Using project YOUR_PROJECT_ID (YOUR_PROJECT)

=== Hosting Setup

Your public directory is the folder (relative to your project directory) that
will contain Hosting assets to be uploaded with firebase deploy. If you
have a build process for your assets, use your build's output directory.

? What do you want to use as your public directory? public
? Configure as a single-page app (rewrite all urls to /index.html)? No
? Set up automatic builds and deploys with GitHub? Yes
✔  Wrote public/404.html
✔  Wrote public/index.html

i  Detected a .git folder at /path/to/project
i  Authorizing with GitHub to upload your service account to a GitHub repository's secrets store.

Visit this URL on this device to log in:
https://github.com/login/oauth/authorize?client_id=CLIENT_ID&redirect_uri=http%3A%2F%2Flocalhost%3A9005&scope=read%3Auser%20repo%20public_repo

Waiting for authentication...

✔  Success! Logged into GitHub as YOUR_GITHUB_USERNAME

? For which GitHub repository would you like to set up a GitHub workflow? YOUR/REPOSITORY

✔  Created service account github-action-308347407 with Firebase Hosting admin permissions.
✔  Uploaded service account JSON to GitHub as secret FIREBASE_SERVICE_ACCOUNT_YOUR_PROJECT_ID.
i  You can manage your secrets at https://github.com/YOUR/REPOSITORY/settings/secrets.

? Set up the workflow to run a build script before every deploy? No

✔  Created workflow file /path/to/project/.github/workflows/firebase-hosting-pull-request.yml
? Set up automatic deployment to your site's live channel when a PR is merged? Yes
? What is the name of the GitHub branch associated with your site's live channel? main

✔  Created workflow file /path/to/project/.github/workflows/firebase-hosting-merge.yml

i  Action required: Visit this URL to revoke authorization for the Firebase CLI GitHub OAuth App:
https://github.com/settings/connections/applications/89cf50f02ac6aaed3484
i  Action required: Push any new workflow file(s) to your repo

i  Writing configuration info to firebase.json...
i  Writing project information to .firebaserc...
i  Writing gitignore file to .gitignore...

✔  Firebase initialization complete!
```

`firebase init` で設定が終わると、 `firebase.json` と `.github/workflows` にGitHub Actionsの設定ファイルで作成されます。  
また、GitHub secretに `FIREBASE_SERVICE_ACCOUNT_YOUR_PROJECT_ID` というsecretが作成されます。これがGitHub ActionsからFirebase Hostingへデプロイするとき使用されるサービスアカウントです。

これだけでPR作成でFirebase Hostingのプレビューチャンネルへのデプロイ、master or mainチャンネルへのマージでFirebase Hostingのライブチャンネル（本番環境）へのデプロイがGitHub Actionsから実行されるようになります。

プレビューチャンネルへのデプロイが終わると、Preview URLをPRへコメントで追加してくれます。

{{< figure src="/images/2020/10/29/screenshot.png" >}}

### HogoのビルドをGitHub Actionsに追加する

`firebase init` で追加されたGitHub Actionsの設定ファイルではHogoのビルドは実装されていないので、設定ファイルに追記します。

具体的には下記の設定を追加しました。
- Hugoのテーマをsubmodulesで管理してるので、`actions/checkout@v2` にsubmodulesの設定
- `peaceiris/actions-hugo@v2` を使用したHugoのビルドステップ

最終的には下記のような設定になりました。

```yaml
# .github/workflows/firebase-hosting-pull-request.yml
name: Deploy to Firebase Hosting on PR
'on': pull_request
jobs:
  build_and_preview:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
        with:
          submodules: true
          fetch-depth: 0
      - uses: peaceiris/actions-hugo@v2
        with:
          hugo-version: 'latest'
      - run: hugo --minify --environment preview
      - uses: FirebaseExtended/action-hosting-deploy@v0
        with:
          repoToken: '${{ secrets.GITHUB_TOKEN }}'
          firebaseServiceAccount: '${{ secrets.FIREBASE_SERVICE_ACCOUNT_YOUR_PROJECT_ID }}'
          projectId: YOUR_PROJECT_ID
        env:
          FIREBASE_CLI_PREVIEWS: hostingchannels
```

```yaml
# .github/workflows/firebase-hosting-merge.yml
name: Deploy to Firebase Hosting on merge
'on':
  push:
    branches:
      - master
jobs:
  build_and_deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
        with:
          submodules: true
          fetch-depth: 0
      - uses: peaceiris/actions-hugo@v2
        with:
          hugo-version: 'latest'
      - run: hugo --minify
      - uses: FirebaseExtended/action-hosting-deploy@v0
        with:
          repoToken: '${{ secrets.GITHUB_TOKEN }}'
          firebaseServiceAccount: '${{ secrets.FIREBASE_SERVICE_ACCOUNT_YOUR_PROJECT_ID }}'
          channelId: live
          projectId: YOUR_PROJECT_ID
        env:
          FIREBASE_CLI_PREVIEWS: hostingchannels
```

### HogoでFirebase Hostingのプレビューチャンネルを使うときに考慮したこと

プレビューチャンネルでのみサイトのレイアウトが崩れるという事象がありました。

Firebase Hostingのプレビューチャンネルでは一定期間有効な一意のURLが発行されます。  
Hugoで利用しているテーマによると思いますが、ビルドのときにcssのパスなどが絶対パスでビルドされ、本番環境とプレビューチャンネルではURLが異なるため、cssなどが404エラーとなっていたのが原因でした。

そこでHogoの設定ファイルをプレビューチャンネルとライブチャンネル（本番環境）で切り替えてビルドするようにしました。  
`config/_default` ディレクトリと `config/preview` ディレクトリを用意し、プレビューチャンネル用にビルドするとき、 `config/preview/config.toml` でデフォルトの設定値を上書きするようにしました。  
`--environment` オプションでビルド用の環境を指定できます。

```bash
hugo --minify --environment preview
```

configディレクトリ詳細は[こちらのドキュメント](https://gohugo.io/getting-started/configuration/#configuration-directory)にあります。

ライブチャンネル（本番環境）へデプロイするときには絶対パスで、プレビューチャンネルへデプロイするときには相対パスでビルドするように設定することで、プレビューチャンネルでのみサイトのレイアウトが崩れるという問題を解消できました。

### 参考

- [GitHubプルリクエストを介してライブチャンネルとプレビューチャンネルにデプロイする  |  Firebase](https://firebase.google.com/docs/hosting/github-integration)
- [Configure Hugo | Hugo](https://gohugo.io/getting-started/configuration/)
