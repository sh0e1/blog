---
title: "AWS SNS Message filtering"
author: sh0e1
type: post
date: 2021-11-13T22:14:57+09:00
categories:
- AWS
- Go
- Terraform
---

SNSのサブスクリプションにフィルターポリシーを割り当てることにより、Subscriberが受信するメッセージを制御できる。  
TerraformとGoを使って試してみた。
<!--more-->

## Terraform

まずTerraformでSNSのトピックと、SQSのキューを作成。  
SNSのトピックを一つとSQSのキューを２つ作成し、片方のキューには `filter_policy` を指定する。  
下のコードだと `sns_topic_filter_subscription` はMessage Attributesに `type=filter` が指定されているメッセージのみを受信する。  
SQSのアクセスポリシーでSNSのトピックからのアクセスを許可しないと、SNSからSQSにメッセージを流せないので注意。

```tf
provider "aws" {
  region = "ap-northeast-1"
}

locals {
  prefix = "prefix"
}

data "aws_caller_identity" "identity" {}

resource "aws_sns_topic" "sns_topic" {
  name = "${local.prefix}-sns-topic"
}

resource "aws_sqs_queue" "sqs_queue" {
  name = "${local.prefix}-sqs-queue"
}

resource "aws_sqs_queue_policy" "queue_policy" {
  queue_url = aws_sqs_queue.sqs_queue.url

  policy = <<POLICY
{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Sid": "Allow-SNS-SendMessage",
      "Effect": "Allow",
      "Principal": {
        "Service": "sns.amazonaws.com"
      },
      "Action": "sqs:SendMessage",
      "Resource": "${aws_sqs_queue.sqs_queue.arn}",
      "Condition": {
        "ArnEquals": {
          "aws:SourceArn": "${aws_sns_topic.sns_topic.arn}"
        }
      }
    }
  ]
}
POLICY
}

resource "aws_sns_topic_subscription" "sns_topic_subscription" {
  topic_arn = aws_sns_topic.sns_topic.arn
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.sqs_queue.arn
}

resource "aws_sqs_queue" "sqs_filter_queue" {
  name = "${local.prefix}-sqs-filter-queue"
}

resource "aws_sqs_queue_policy" "filter_queue_policy" {
  queue_url = aws_sqs_queue.sqs_filter_queue.url

  policy = <<POLICY
{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Sid": "Allow-SNS-SendMessage",
      "Effect": "Allow",
      "Principal": {
        "Service": "sns.amazonaws.com"
      },
      "Action": "sqs:SendMessage",
      "Resource": "${aws_sqs_queue.sqs_filter_queue.arn}",
      "Condition": {
        "ArnEquals": {
          "aws:SourceArn": "${aws_sns_topic.sns_topic.arn}"
        }
      }
    }
  ]
}
POLICY
}

resource "aws_sns_topic_subscription" "sns_topic_filter_subscription" {
  topic_arn     = aws_sns_topic.sns_topic.arn
  protocol      = "sqs"
  endpoint      = aws_sqs_queue.sqs_filter_queue.arn
  filter_policy = <<POLICY
{
  "type": ["filter"]
}
POLICY
}
```

## Go

GoでSNSへのPublisherと、SNSからメッセージを取得Subscriberを実装。

### Publisher

PublisherはSNSにメッセージをPublishする。  
`-topic` でSNSのArnを指定し、 `-filter` でMessage Attributesに `type=filter` を指定するかを制御している。

```go
package main

import (
	"context"
	"flag"
	"log"

	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/service/sns"
	"github.com/aws/aws-sdk-go-v2/service/sns/types"
)

var (
	topic  string
	filter bool
)

func main() {
	flag.StringVar(&topic, "topic", "", "topic arn")
	flag.BoolVar(&filter, "filter", false, "filter attribute")
	flag.Parse()

	if topic == "" {
		log.Fatal("topic option is required")
	}

	ctx := context.Background()
	cfg, err := config.LoadDefaultConfig(ctx)
	if err != nil {
		log.Fatal(err)
	}

	client := sns.NewFromConfig(cfg)

	in := &sns.PublishInput{
		Message:  aws.String("Hello World"),
		TopicArn: aws.String(topic),
	}
	if filter {
		in.MessageAttributes = map[string]types.MessageAttributeValue{
			"type": {
				DataType:    aws.String("String"),
				StringValue: aws.String("filter"),
			},
		}
	}

	out, err := client.Publish(ctx, in)
	if err != nil {
		log.Fatal(err)
	}

	log.Printf("message id: %s\n", *out.MessageId)
}
```

### Subscriber

Subscriberは `-queue` で指定したQueue URLからメッセージをSubscribeする。

```go
package main

import (
	"context"
	"flag"
	"log"
	"os"
	"os/signal"

	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/service/sqs"
	"github.com/aws/aws-sdk-go-v2/service/sqs/types"
)

var queue string

func main() {
	flag.StringVar(&queue, "queue", "", "queue url")
	flag.Parse()

	if queue == "" {
		log.Fatal("queue option is required")
	}

	ctx := context.Background()
	cfg, err := config.LoadDefaultConfig(ctx)
	if err != nil {
		log.Fatal(err)
	}

	sigctx, cancel := signal.NotifyContext(ctx, os.Interrupt)
	client := sqs.NewFromConfig(cfg)

	for {
		select {
		case <-sigctx.Done():
			log.Printf("shutting down subscriber..., %v\n", sigctx.Err())
			cancel()
			return
		default:
			log.Println("subscribe messages...")

			receiveIn := &sqs.ReceiveMessageInput{
				MessageAttributeNames: []string{
					string(types.QueueAttributeNameAll),
				},
				QueueUrl:        aws.String(queue),
				WaitTimeSeconds: 5,
			}
			receiveOut, err := client.ReceiveMessage(sigctx, receiveIn)
			if err != nil {
				log.Printf("receive err: %v\n", err)
				continue
			}

			for i := range receiveOut.Messages {
				log.Printf("message id: %s\n", *receiveOut.Messages[i].MessageId)

				deleteIn := &sqs.DeleteMessageInput{
					QueueUrl:      aws.String(queue),
					ReceiptHandle: receiveOut.Messages[i].ReceiptHandle,
				}
				if _, err := client.DeleteMessage(sigctx, deleteIn); err != nil {
					log.Printf("delete err: %v\n", err)
					continue
				}
				log.Printf("deleted message: %s\n", *receiveOut.Messages[i].MessageId)
			}
		}
	}
}
```

## 動作確認

PublisherでSNSへメッセージをPublishする。  
Subscriberの `-queue` オプションにフィルターポリシーを指定しているQueue、指定していないQueueのQueueURLを指定してそれぞれ受信するメッセージを確認する。

### `type=filter` 指定なし

Message Attributesに `type=filter` を指定してPublishしていないので、フィルターポリシーを指定していないキューではメッセージを受信できるが、フィルターポリシーを指定しているキューではメッセージを受信できない。

#### Publisher

```bash
go run ./cmd/publisher/main.go -topic $TOPIC_ARN
2021/11/13 23:16:24 message id: 38c44d87-821c-53d2-a4d5-178e49148b8b
```

#### Subscriber

**フィルターポリシーなし**
```bash
go run ./cmd/subscriber/main.go -queue $QUEUE_URL
2021/11/13 23:16:10 subscribe messages...
2021/11/13 23:16:15 subscribe messages...
2021/11/13 23:16:20 subscribe messages...
2021/11/13 23:16:24 message id: 88f50f67-88a2-4757-b2fc-787d3f2694de
2021/11/13 23:16:24 deleted message: 88f50f67-88a2-4757-b2fc-787d3f2694de
2021/11/13 23:16:24 subscribe messages...
2021/11/13 23:16:29 subscribe messages...
2021/11/13 23:16:34 subscribe messages...
^C2021/11/13 23:16:36 receive err: operation error SQS: ReceiveMessage, https response error StatusCode: 0, RequestID: , canceled, context canceled
2021/11/13 23:16:36 shutting down subscriber..., context canceled
```

**フィルターポリシーあり**
```bash
go run ./cmd/subscriber/main.go -queue $FILTER_QUEUE_URL
2021/11/13 23:16:08 subscribe messages...
2021/11/13 23:16:14 subscribe messages...
2021/11/13 23:16:19 subscribe messages...
2021/11/13 23:16:24 subscribe messages...
2021/11/13 23:16:29 subscribe messages...
2021/11/13 23:16:34 subscribe messages...
^C2021/11/13 23:16:35 receive err: operation error SQS: ReceiveMessage, https response error StatusCode: 0, RequestID: , canceled, context canceled
2021/11/13 23:16:35 shutting down subscriber..., context canceled
```

### `type=filter` 指定あり

Message Attributesに `type=filter` を指定してPublishしているので、フィルターポリシーを指定していないキューでも、フィルターポリシーを指定しているキューでもメッセージを受信できる。

#### Publisher

```bash
go run ./cmd/publisher/main.go -topic $TOPIC_ARN -filter
2021/11/13 23:28:26 message id: 2855b749-7442-549a-b4f5-ed40b9989f4d
```

#### Subscriber

**フィルターポリシーなし**
```bash
go run ./cmd/subscriber/main.go -queue $QUEUE_URL
2021/11/13 23:28:13 subscribe messages...
2021/11/13 23:28:19 subscribe messages...
2021/11/13 23:28:24 subscribe messages...
2021/11/13 23:28:26 message id: 0171e88d-3881-4610-b9bf-2c0001098614
2021/11/13 23:28:26 deleted message: 0171e88d-3881-4610-b9bf-2c0001098614
2021/11/13 23:28:26 subscribe messages...
2021/11/13 23:28:31 subscribe messages...
2021/11/13 23:28:36 subscribe messages...
^C2021/11/13 23:28:38 receive err: operation error SQS: ReceiveMessage, https response error StatusCode: 0, RequestID: , canceled, context canceled
2021/11/13 23:28:38 shutting down subscriber..., context canceled
```

**フィルターポリシーあり**
```bash
go run ./cmd/subscriber/main.go -queue $FILTER_QUEUE_URL
2021/11/13 23:28:12 subscribe messages...
2021/11/13 23:28:17 subscribe messages...
2021/11/13 23:28:23 subscribe messages...
2021/11/13 23:28:26 message id: 1c20fba4-a763-497a-b98d-c1cef60f99bc
2021/11/13 23:28:26 deleted message: 1c20fba4-a763-497a-b98d-c1cef60f99bc
2021/11/13 23:28:26 subscribe messages...
2021/11/13 23:28:31 subscribe messages...
2021/11/13 23:28:36 subscribe messages...
^C2021/11/13 23:28:37 receive err: operation error SQS: ReceiveMessage, https response error StatusCode: 0, RequestID: , canceled, context canceled
2021/11/13 23:28:37 shutting down subscriber..., context canceled
```

## 所感

SNSトピックを複数管理しなくても、Message Attributesでサブスクリプション先を制御できるのは嬉しい

## 参考

- [Amazon SNS message filtering](https://docs.aws.amazon.com/sns/latest/dg/sns-message-filtering.html)
