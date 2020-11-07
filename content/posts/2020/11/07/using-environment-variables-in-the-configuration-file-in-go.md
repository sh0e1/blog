---
title: "Goで設定ファイルに環境変数を使う"
author: sh0e1
type: post
date: 2020-11-07T21:52:28+09:00
categories:
  - Go
---
Goのアプリケーションでyamlやtomlで設定ファイルを読み込むときに、DBのパスワードや外部サービスのAPIキーなどの秘匿情報のみを環境変数で置換できないかなと思ってやり方を調べました。  
Kubernetesで設定ファイル全てをSecretに置くのではなく、設定ファイルはConfigMap、秘匿情報はSecretにしたかったのがきっかけです。

設定ファイルを読み込んでから `os.ExpandEnv` で環境変数を置き換えればできるようです。
<!--more-->

## サンプルコード

```go
package main

import (
	"flag"
	"fmt"
	"io/ioutil"
	"log"
	"os"

	"gopkg.in/yaml.v3"
)

func main() {
	var cfgFilePath string
	flag.StringVar(&cfgFilePath, "c", "./config.yaml", "the configuration file path")
	flag.Parse()

	cfgFile, err := ioutil.ReadFile(cfgFilePath)
	if err != nil {
		log.Fatal(err)
	}

	expaned := os.ExpandEnv(string(cfgFile))

	var cfg Config
	if err := yaml.Unmarshal([]byte(expaned), &cfg); err != nil {
		log.Fatal(err)
	}

	fmt.Printf("%#v\n", cfg)
}

type Config struct {
	DB     DBConfig `yaml:"db"`
	APIKey string   `yaml:"apikey"`
}

type DBConfig struct {
	Host     string `yaml:"host"`
	Port     int    `yaml:"port"`
	Database string `yaml:"database"`
	Username string `yaml:"username"`
	Password string `yaml:"password"`
}
```

```yaml
db:
  host: 127.0.0.1
  port: 3306
  database: sample
  username: user
  password: ${DB_PASSWORD}

apikey: ${API_KEY}
```

環境変数をセットして上記のコードを実行すると、設定ファイルに記載した環境変数部が実際の値に置き換わって出力されます。

```bash
$ DB_PASSWORD=password API_KEY=sample-api-key go run main.go
main.Config{DB:main.DBConfig{Host:"127.0.0.1", Port:3306, Database:"sample", Username:"user", Password:"password"}, APIKey:"sample-api-key"}
```

環境変数の置き換え自体は標準パッケージに関数があるので、思ってたより簡単に実装できました。

## 参考

- https://blog.kanga333.com/entry/2018/05/17/182115
- https://golang.org/pkg/os/#ExpandEnv
