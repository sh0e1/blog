---
title: Goのhtml/templateで独自関数を使う方法
author: sh0e1
type: post
date: 2019-01-10T15:47:28+00:00
categories:
  - Go
---
今回はGoの`html/template`パッケージで独自関数を使う方法について書きます。

### html/template packageとは

`html/template` パッケージはGoのhtml用のテンプレートエンジンです。  
https://golang.org/pkg/html/template/

テキストでテンプレートエンジンを使いたい場合は `text/template` パッケージを使います。  
https://golang.org/pkg/text/template/
<!--more-->

### 標準で定義されているFunctions

下記が標準パッケージで定義されているテンプレートで使える関数になります。  
これ以外の関数をテンプレートで使おうとすると、独自関数を定義する必要があります。

```
and
	Returns the boolean AND of its arguments by returning the
	first empty argument or the last argument, that is,
	"and x y" behaves as "if x then y else x". All the
	arguments are evaluated.
call
	Returns the result of calling the first argument, which
	must be a function, with the remaining arguments as parameters.
	Thus "call .X.Y 1 2" is, in Go notation, dot.X.Y(1, 2) where
	Y is a func-valued field, map entry, or the like.
	The first argument must be the result of an evaluation
	that yields a value of function type (as distinct from
	a predefined function such as print). The function must
	return either one or two result values, the second of which
	is of type error. If the arguments don't match the function
	or the returned error value is non-nil, execution stops.
html
	Returns the escaped HTML equivalent of the textual
	representation of its arguments. This function is unavailable
	in html/template, with a few exceptions.
index
	Returns the result of indexing its first argument by the
	following arguments. Thus "index x 1 2 3" is, in Go syntax,
	x[1][2][3]. Each indexed item must be a map, slice, or array.
js
	Returns the escaped JavaScript equivalent of the textual
	representation of its arguments.
len
	Returns the integer length of its argument.
not
	Returns the boolean negation of its single argument.
or
	Returns the boolean OR of its arguments by returning the
	first non-empty argument or the last argument, that is,
	"or x y" behaves as "if x then x else y". All the
	arguments are evaluated.
print
	An alias for fmt.Sprint
printf
	An alias for fmt.Sprintf
println
	An alias for fmt.Sprintln
urlquery
	Returns the escaped value of the textual representation of
	its arguments in a form suitable for embedding in a URL query.
	This function is unavailable in html/template, with a few
	exceptions.
```

二項比較演算子も関数として定義されています。

```
eq
	Returns the boolean truth of arg1 == arg2
ne
	Returns the boolean truth of arg1 != arg2
lt
	Returns the boolean truth of arg1 &lt; arg2
le
	Returns the boolean truth of arg1 &lt;= arg2 gt Returns the boolean truth of arg1 &gt; arg2
ge
	Returns the boolean truth of arg1 &gt;= arg2
```

https://golang.org/pkg/text/template/#hdr-Functions

### 独自関数を使うには

#### テンプレートで実行したい関数を実装

まずテンプレートで実行したい関数を実装します。  
今回はサンプルで `sum()` を実装します。

```go
func sum(a, b int) int {
	return a + b
}
```

#### Funcs()で関数を渡す

`func (t *Template) Funcs(funcMap FuncMap) *Template {}` を使って先程実装した `sum()` をテンプレートで使えるようにします。

```go
funcs := template.FuncMap{
	"sum": sum,
}
template.New("name").Funcs(funcs).Parse("")
```

#### テンプレートで関数を実行する

あとはテンプレートで実装した関数を実行するだけです。

```go
template.New("name").Funcs(funcs).Parse("{{sum 1 2}}")
```

#### サンプルコード

```go
package main

import (
	"html/template"
	"log"
	"net/http"
)

func main() {
	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		funcs := template.FuncMap{
			"sum": sum,
		}

		tmpl, err := template.New("name").Funcs(funcs).Parse("{{sum 1 2}}")
		if err != nil {
			log.Fatal(err)
		}
		if err := tmpl.Execute(w, nil); err != nil {
			log.Fatal(err)
		}
	})

	http.ListenAndServe(":8080", nil)
}

func sum(a, b int) int {
	return a + b
}
```

上記を実行して `http://localhost:8080` にアクセスすると `3` と表示されると思います。

### その他 Tips

#### 独自関数からHTMLを出力

関数で `string` を返すとHTMLではエスケープして表示されます。

```go
func hello() string {
	return "Hello World"
}
```

```
<p>Hello World</p>
```

関数からHTMLを出力した場合は、 `template.HTML` を返すようにします。


```go
func hello() template.HTML {
	return template.HTML("Hello World")
}
```

これでHTMLがエスケープされずにブラウザに表示されます。

以上、Goの `html/template` パッケージで独自関数を使う方法でした。
