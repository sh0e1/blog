---
title: CakePHP 2.x - SSL通信(https)を強制する
author: sh0e1
type: post
date: 2015-12-02T12:26:04+00:00
categories:
  - CakePHP 2.x
---
CakePHP 2.xでSSL通信（https）を強制する方法です。  
httpでのリクエストがあった場合は、httpsにしてリダイレクトさせるようにします。  
.htaccessなどでリダイレクトさせる方法もありますが、今回はCakePHPの機能を使ってリダイレクトさせます。
<!--more-->

### Security Componentの読込

AppController.phpでSecurity Componentを読み込みます。

```php
// app/Controller/AppController.php
public $components = array(
    'Security',
);
```

### beforeFilterメソッドを変更

AppControllerのbeforeFilterメソッドにhttpリクエストのときに実行するメソッド、 httpsを強制したいアクションを指定します。

```php
// app/Controller/AppController.php
public function beforeFilter() {
    parent::beforeFilter();
    // httpリクエストのときに実行するメソッド
    $this->Security->blackHoleCallback = 'forceSecure';
    // httpsを強制したいアクション
    // requireSecureメソッドに引数がない場合は全てのアクションでhttpsを強制する
    $this->Security->requireSecure();
}
```

### httpリクエストのときに実行するメソッドを定義

httpリクエストのときに実行するメソッド（今回はforceSecureメソッド）を、AppControllerに定義します。

```php
// app/Controller/AppController.php
public function forceSecure() {
    $this->redirect("https://".env('SERVER_NAME').$this->here);
}
```

メソッド内の処理は、現在のURLにhttpsでリダイレクトさせているだけです。

### https接続のページを指定するには

指定したいControllerでbeforeFilterメソッド内に処理を追加し、requireSecureメソッドでhttps接続にしたいアクション名を引数で渡せば、特定のURLへのアクセスのみhttpsに強制することができます。

```php
// app/Controller/HogeController.php
class HogeController extends AppController {

    public function beforeFilter() {
        parent::beforeFilter();
        $this->Security->blackHoleCallback = 'forceSecure';
        // https接続したいアクション名を配列で指定
        $this->Security->requireSecure(array('index', 'add'));
    }
}
```

### Security Component導入でPOST, Ajaxなどがうまくいかなくなった場合

結論からいうと、beforeFilterメソッドに下記を追記すれば直ると思います。

```php
public function beforeFilter() {
    parent::beforeFilter();
    $this->Security->blackHoleCallback = 'forceSSL';
    $this->Security->requireSecure();
    // 下記を追加
    $this->Security->validatePost = false;
    $this->Security->csrfCheck = false;
}
```

#### validatePost

Security Componentには、CakePHPがフォームを生成時にフォームの内容をハッシュ化し、フォーム送信時にフォームの内容に差異が生じていると、フォームを不正に改変されたと判定する機能があります。  
そのため、Javascriptでフォームの内容を動的に変更するとエラーとなり、Black Holeに吸い込まれます。  
この機能を無効にするために、$this->Security->validatePost = falseとします。  
フォーム中の特定の項目だけ無効にしたい場合は、FormHelperで下記のようにすると無効にすることができます。

```php
$this->Form->unlockFields('Model.field_name');
```

#### csrfCheck

Security Componentにはcsrf対策機能もあり、フォーム生成時にトークンを発行し、トークンチェックを行います。  
そのため、トークンがなかったり、トークンの値が書き換えられていた場合エラーとなり、Black Holeに吸い込まれます。  
この機能を無効にするために、$this->Security->csrfCheck = falseとします。  
CakePHPのFormHelperを使用してフォームを生成しないと、そもそもトークンが発行されないため、エラーとなり、Black Holeに吸い込まれます。

validatePost、csrfCheck共に、無効にすれば当然セキュリティレベルは落ちるので、色々と考慮してから無効にしたほうがいいかと思います。

以上、CakePHP 2.xでSSL通信(https)を強制する方法でした。
