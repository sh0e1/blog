---
title: Cloud Run/GoでCloud Pub/Subのサブスクライブ
author: sh0e1
type: post
date: 2019-12-21T15:51:59+00:00
categories:
  - Go
  - Google Cloud Platform
  - Cloud Run
---
Goで実装したCloud Run(fully managed)をCloud Pub/SubのPushサブスクリプションに使ってみました。  
Cloud Run(fully managed)は、先日BetaからGAになりました。  
環境構築がまだの場合は[前回の記事](/posts/2019/07/29/tried-gcp-s-cloud-run-in-go/)に書いているので、ご覧いただければと思います。

今回のソースコードは[GitHub](https://github.com/sh0e1/cloud-run-samples/tree/master/pubsub)へあげてます。
<!--more-->

### Cloud Pub/Sub トピックを作成

```bash
gcloud pubsub topics create cloud-run-topic
```

### Goの実装

```go
package main

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"os"
)

func main() {
	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		dump, err := httputil.DumpRequest(r, true)
		if err != nil {
			log.Printf("httputil.DumpRequest: %v", err)
			http.Error(w, "Internal Server Error", http.StatusInternalServerError)
			return
		}
		log.Printf("dump: %s", string(dump))

		var m pubSubMessage
		if err := json.NewDecoder(r.Body).Decode(&m); err != nil {
			log.Printf("json.NewDecoder: %v", err)
			http.Error(w, "Bad Request", http.StatusBadRequest)
			return
		}

		name := string(m.Message.Data)
		if name == "" {
			name = "World"
		}
		log.Printf("Hello %s!", name)
	})

	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
		log.Printf("Defaulting to port %s", port)
	}

	log.Printf("Listening on port %s", port)
	log.Fatal(http.ListenAndServe(fmt.Sprintf(":%s", port), nil))
}

type pubSubMessage struct {
	Message struct {
		Data []byte `json:"data,omitempty"`
		ID   string `json:"id"`
	} `json:"message"`
	Subscription string `json:"subscription"`
}
```

httpサーバを起動して、リクエストボディのメッセージをログに表示されているだけです。  
Cloud Pub/Subからどんなリクエストがくるか確認するために、 `httputil.DumpRequest()` を使ってリクエストのdumpもしています。  
Cloud Runのドキュメントにも記載されていますが、httpステータスコードを正確に返すように実装する必要があります。

> 正確な HTTP レスポンス コードを返すようにサービスをコーディングする必要があります。HTTP 200 や 204 などの成功コードは、Cloud Pub/Sub メッセージの処理の完了を意味します。HTTP 400 や 500 などのエラーコードは、[push を使用したメッセージの受信](https://cloud.google.com/pubsub/docs/push)で説明されているように、メッセージが再試行されることを示します。

### Dockerfile

Docker imageをデプロイするので、Dockerfileも用意します。

```docker
FROM golang as builder
WORKDIR /app
COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -v -o pubsub

FROM alpine
COPY --from=builder /app/pubsub .
CMD ["/pubsub"]
```

### デプロイ

Cloud Buildでコンテナイメージをビルドし、そのイメージをContainer Registryにアップロード、最後に、アップロードしたイメージをCloud Runにデプロイします。

```bash
gcloud builds submit --tag gcr.io/${PROJECT-ID}/pubsub
gcloud run deploy pubsub --image gcr.io/gcr.io/${PROJECT-ID}/pubsub/pubsub
```

デプロイ時に `Allow unauthenticated invocations to [pubsub] (y/N)?` と聞かれるので、 `n` を入力します。  
非公開にすることで、Cloud RunとCloud Pub/Subの自動統合でリクエストの認証を行うことができます。

### Cloud Pub/Subと統合

Cloud Pub/Subにpublishされたら、メッセージをCloud RunへpushするようにCloud Pub/Subを構成します。

```bash
# プロジェクトで Cloud Pub/Sub 認証トークンを作成できるようにする
gcloud projects add-iam-policy-binding ${PROJECT-ID} \
     --member=serviceAccount:service-${PROJECT-NUMBER}@gcp-sa-pubsub.iam.gserviceaccount.com \
     --role=roles/iam.serviceAccountTokenCreator

# Cloud Pub/SubサブスクリプションIDを表すサービスアカウントを作成
gcloud iam service-accounts create cloud-run-pubsub-invoker \
     --display-name "Cloud Run Pub/Sub Invoker"

# サービスアカウントにCloud Runのサービスを呼び出す権限を付与
gcloud run services add-iam-policy-binding pubsub \
     --member=serviceAccount:cloud-run-pubsub-invoker@${PROJECT-ID}.iam.gserviceaccount.com \
     --role=roles/run.invoker

# サービスアカウントでCloud Pub/Subサブスクリプションを作成
gcloud beta pubsub subscriptions create cloud-run-subscription --topic cloud-run-topic \
   --push-endpoint=${SERVICE-URL}/ \
   --push-auth-service-account=cloud-run-pubsub-invoker@${PROJECT-ID}.iam.gserviceaccount.com
```

`${SERVICE-URL}` はサービスのデプロイ時に表示されたURLです。

fully managedのCloud Runを使えば、リクエストの認証処理は自前で実装しなくても自動でやってくれます。  
on GKEのCloud Runだと、Cloud Pub/Subリクエストの一部として送信されたJSON Web Tokenを確認して、認証処理を実装しなくてはなりません。

### 動作確認

Cloud Pub/Subのトピックにメッセージを送信して動作確認をします。

```bash
gcloud pubsub topics publish cloud-run-topic --message "Runner"
```

GCPのWebコンソールからCloud Run -> pubsub(サービス名) -> ログタブでログを確認できます。  
正常に動作していると、下記のようにログが出力されます。

```
2019/12/21 15:28:38 Hello Runner!
```

またリクエストのdumpもログに出力するようにしたので、Cloud Pub/Subからどのようなリクエストがきているかも確認できます。  
ただ改行があるとログが別々に表示されるので、今回の出力方法だとログが見づらいですね...

次回はCloud RunとCloud Pub/SubではまったGoのContextのことを書こうと思います。

### 参考

- https://cloud.google.com/run/docs/tutorials/pubsub
