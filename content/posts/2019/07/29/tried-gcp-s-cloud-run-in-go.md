---
title: GCPのCloud RunをGoで試してみた
author: sh0e1
type: post
date: 2019-07-28T16:08:05+00:00
categories:
  - Go
  - Google Cloud Platform
  - Cloud Run
---
GoでHello WorldをGCPのCloud Runを試してみました。  
Cloud RunはFull ManagedかGKEで利用することができますが、今回はFull ManagedのCloud Runを利用しました。
<!--more-->

### Cloud Runとは

> Cloud Run is a managed compute platform that automatically scales your stateless containers. Cloud Run is serverless: it abstracts away all infrastructure management, so you can focus on what matters most — building great applications.
>
> Cloud Runは、ステートレスコンテナを自動的に拡張するマネージドコンピューティングプラットフォームです。 Cloud Runはサーバーレスです。すべてのインフラストラクチャ管理を抽象化するので、最も重要なことに集中できます。優れたアプリケーションを構築できます。

Google翻訳そのままですみません。。。

### 前提条件

- gloud command-line toolをインストールしていること
- 検証用のプロジェクトを作成していること
- 検証用のプロジェクトに対して課金が有効になっていること
- Dockerをイントールしていること

### 環境のセットアップ

Cloud RunはPublic Betaなのでgcloud command-line toolでbeta componentをインストールする必要があります。

```bash
$ gcloud components install beta
$ gcloud components update
```
<pre><code class="bash">$ </code></pre>

Cloud Runの設定

```bash
$ gcloud config set run/platform managed
Updated property [run/platform].
$ gcloud config set run/region us-central1
Updated property [run/region].
```

### GoでHello Worldアプリケーション

GoでHello Worldアプリケーションを書きます。

```go
package main

import (
	"fmt"
	"log"
	"net/http"
	"os"
)

func main() {
	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		fmt.Printf("Hello World")
	})

	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}
	log.Fatal(http.ListenAndServe(fmt.Sprintf(":%s", port)))
}
```

Docker imageをデプロイするのでDockerfileも用意します。

```docker
FROM golang:1.12 as builder
WORKDIR /go/src/github.com/sh0e1/cloud-run-samples/helloworld
COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -v -o helloworld

FROM alpine
RUN apk add --no-cache ca-certificates
COPY --from=builder /go/src/github.com/sh0e1/cloud-run-samples/helloworld/helloworld /helloworld
CMD ["/helloworld"]
```

ソースコードはここに置いてます。
https://github.com/sh0e1/cloud-run-samples

### ビルドとデプロイ

アプリケーションの準備が終わったら、ビルドとデプロイを行います。

Cloud Buildを利用して、Docker imageをビルドし、Container RegistoryへPushします。  
途中でCloud Build APIを有効にしますかと聞かれるので `y` と入力します。

```bash
$ gcloud builds submit --tag gcr.io/${PROJECT_ID}/helloworld
```

Cloud Buildが正常に終了したら、Cloud Runへデプロイします。

```bash
$ gcloud beta run deploy --image gcr.io/${PROJECT_ID}/helloworld --platform managed
Service name (helloworld): # サービス名の入力、今回はエンターでデフォルトのサービス名を使用
Allow unauthenticated invocations to [helloworld] (y/N)?  y # 認証されていないリクエストを許可するか、今回はyを入力

Deploying container to Cloud Run service [helloworld] in project [YOUR_PROJECT_ID] region [us-central1]
✓ Deploying new service... Done.
  ✓ Creating Revision...
  ✓ Routing traffic...
  ✓ Setting IAM Policy...
Done.
Service [helloworld] revision [helloworld-00001] has been deployed and is serving traffic at https://helloworld-g5renum3oq-uc.a.run.app
```

デプロイ中に `ERROR: (gcloud.beta.run.deploy) User does not have permission to access project ...` とエラーになる場合は、表示されているURLへアクセスし、GCPのWebコンソールからCloud Run APIを有効にしてください。

デプロイが正常に終了すると、URLが表示されます。

### 動作確認

デプロイ終了後に表示されたURLへアクセスすると、 `Hello World` と表示されます。

```bash
$ curl https://helloworld-g5renum3oq-uc.a.run.app
Hello World%
```

次はCloud RunでPub/Subを利用する方法とか書こうと思います。

### 参考

- https://cloud.google.com/run/docs/?hl=ja
