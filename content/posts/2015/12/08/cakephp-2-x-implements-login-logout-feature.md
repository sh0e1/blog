---
title: CakePHP 2.x - ログイン/ログアウト機能を実装
author: sh0e1
type: post
date: 2015-12-08T14:42:15+00:00
categories:
  - CakePHP 2.x
---
今回はCakePHP 2.xでログイン/ログアウト機能を実装してみます。  
具体的には、先日ローカル環境にbakeコマンドでつくったタスク管理アプリにログイン機能を追加しようと思います。  
[CakePHP 2.x – bakeコマンドを使って10分でタスク管理アプリを開発する方法]({{< ref "/posts/2015/12/05/cakephp-2-x-how-to-develop-task-management-app-in-10-minutes-using-the-base-command.md" >}})
<!--more-->

### 想定

- ユーザ登録時にユーザ名、メールアドレス、パスワードを登録し、ログイン時には、ユーザ名とパスワードでログインできるようにする
- ユーザ登録時の入力チェックはbake allコマンドで自動で生成されるもののみ
- パスワードは暗号化してDBに保存する（セキュリティ対策）

### usersテーブルを作成

先日つくったタスク管理アプリでは、ユーザ情報を保持しておくテーブルがないので、usersテーブルを作成します。

```sql
-- usersテーブル作成
CREATE TABLE cakephp.users (
  id int(11) NOT NULL AUTO_INCREMENT,
  username varchar(255) NOT NULL UNIQUE,
  email varchar(255) NOT NULL UNIQUE,
  password varchar(255) NOT NULL,
  created datetime,
  modified datetime,
  PRIMARY KEY (id)
) DEFAULT CHARSET = utf8;
```

### bakeコマンドでユーザのCRUDページを機能を追加

テーブルを作成したら、前回と同様にbake allコマンドでユーザの追加、紹介、更新、削除画面を生成します。

```bash
$ php /path/to/app/Console/cake.php bake all

Welcome to CakePHP v2.6.10 Console
---------------------------------------------------------------
App : app
Path: /path/to/cakephp/app/
---------------------------------------------------------------
Bake All
---------------------------------------------------------------
Possible Models based on your current database:
1. Task
2. User
Enter a number from the list above,
type in the name of another model, or 'q' to exit
[q] > 2 # Userを入力

Baking model class for User...

Creating file /path/to/cakephp/app/Model/User.php
Wrote `/path/to/cakephp/app/Model/User.php`
PHPUnit is not installed. Do you want to bake unit test files anyway? (y/n)
[y] > y

You can download PHPUnit from http://phpunit.de

Baking test fixture for User...

Creating file /path/to/cakephp/app/Test/Fixture/UserFixture.php
Wrote `/path/to/cakephp/app/Test/Fixture/UserFixture.php`
Bake is detecting possible fixtures...

Baking test case for User Model ...

Creating file /path/to/cakephp/app/Test/Case/Model/UserTest.php
Wrote `/path/to/cakephp/app/Test/Case/Model/UserTest.php`

Baking controller class for Users...

Creating file /path/to/cakephp/app/Controller/UsersController.php
Wrote `/path/to/cakephp/app/Controller/UsersController.php`
PHPUnit is not installed. Do you want to bake unit test files anyway? (y/n)
[y] > y

You can download PHPUnit from http://phpunit.de
Bake is detecting possible fixtures...

Baking test case for Users Controller ...

Creating file /path/to/cakephp/app/Test/Case/Controller/UsersControllerTest.php
Wrote `/path/to/cakephp/app/Test/Case/Controller/UsersControllerTest.php`

Baking `index` view file...

Creating file /path/to/cakephp/app/View/Users/index.ctp
Wrote `/path/to/cakephp/app/View/Users/index.ctp`

Baking `view` view file...

Creating file /path/to/cakephp/app/View/Users/view.ctp
Wrote `/path/to/cakephp/app/View/Users/view.ctp`

Baking `add` view file...

Creating file /path/to/cakephp/app/View/Users/add.ctp
Wrote `/path/to/cakephp/app/View/Users/add.ctp`

Baking `edit` view file...

Creating file /path/to/cakephp/app/View/Users/edit.ctp
Wrote `/path/to/cakephp/app/View/Users/edit.ctp`

Bake All complete
```

### ログイン機能を実装

#### Auth Componentの読込

CakePHP 2.xでログイン認証を行うにはAuth Componentを利用します。  
app/Controller/AppController.phpにAuth Componentを読み込む記述を追加します。

```php
// app/Controller/AppController.php
class AppController extends Controller {

    public $components = array(
        'DebugKit.Toolbar',
        'Session',
        'Auth' => array(
            'loginRedirect' => array('controller' => 'tasks', 'action' => 'index'),
            'logoutRedirect' => array('controller' => 'users', 'action' => 'login')
        )
    );
}
```

loginRedirectにはログイン後のリダイレクト先を、logoutRedirectにはログアウト後のリダイレクト先を指定します。  
今回はログイン後にはタスク一覧画面に、ログアウト後はログイン画面にリダイレクトするようにしています。

#### ログアウト状態でアクセスできるアクションの指定

ログイン画面、ユーザ登録画面など、ログアウト状態でもアクセスできるページを指定します。  
app/Controller/UserController.phpにbeforeFilterアクションを追加し、ログイン画面とユーザ登録画面へのログアウト状態でのアクセスを許可します。

```php
// app/Controller/UserController.php
public function beforeFilter() {
    parent::beforeFilter();
    $this->Auth->allow('login', 'add');
}
```

#### loginアクション

app/Controller/UserController.phpにloginアクションを追加し、ログイン処理を実装します。

```php
// app/Controller/UserController.php
public function login() {
    if ($this->request->is('post')) {
        if ($this->Auth->login()) {
            $this->redirect($this->Auth->redirect());
        } else {
            $this->Session->setFlash(__('Invalid username or password, try again'));
        }
    }
}
```

まずPOSTリクエストかどうか判定し、POSTリクエストの場合は$this->Auth->login()でログイン判定を行います。  
正常にログインできればAuthコンポーネントに指定したログイン後のリダイレクト先へリダイレクトし、ログインに失敗すると、セッションにメッセージを保持し、ビューでログイン画面でメッセージを表示します。

#### ログイン画面の作成

bakeコマンドで生成したViewファイルにはログイン画面はないので、新たに作成します。  
app/View/Users/login.ctpファイルを作成し、以下のコードを記述してください。

```html
<!-- app/View/Users/login.ctp -->
<div class="users form">
<?php echo $this->Session->flash('auth'); ?>
<?php echo $this->Form->create('User'); ?>
    <fieldset>
        <legend><?php echo __('Please enter your username and password'); ?></legend>
        <?php
            echo $this->Form->input('username');
            echo $this->Form->input('password');
        ?>
    </fieldset>
<?php echo $this->Form->end(__('Login')); ?>
</div>
```

#### パスワードの暗号化

今のままでは、パスワードがそのままデータベースに登録されるため、セキュリティ上好ましくありません。もしデータベースのデータが流出した場合、パスワードが全てわかってします。セキュリティを考慮して、データベースにパスワードを暗号化して登録するようにします。

パスワードのハッシュ化をするにはSimplePasswordHasherクラスを利用します。UserモデルでbeforeSaveメソッドをオーバライドしパスワードを暗号化してからDBに保存します。

```php
// app/Model/User.php
App::uses('AppModel', 'Model');
App::uses('SimplePasswordHasher', 'Controller/Component/Auth');

/**
 * User Model
 *
 */
class User extends AppModel {

    /**
     * Validation rules
     *
     * @var array
     */
    public $validate = array(
        'username' => array(
            'notEmpty' => array(
                'rule' => array('notEmpty'),
                //'message' => 'Your custom message here',
                //'allowEmpty' => false,
                //'required' => false,
                //'last' => false, // Stop validation after this rule
                //'on' => 'create', // Limit validation to 'create' or 'update' operations
            ),
        ),
        'email' => array(
            'email' => array(
                'rule' => array('email'),
                //'message' => 'Your custom message here',
                //'allowEmpty' => false,
                //'required' => false,
                //'last' => false, // Stop validation after this rule
                //'on' => 'create', // Limit validation to 'create' or 'update' operations
            ),
        ),
        'password' => array(
            'notEmpty' => array(
                'rule' => array('notEmpty'),
                //'message' => 'Your custom message here',
                //'allowEmpty' => false,
                //'required' => false,
                //'last' => false, // Stop validation after this rule
                //'on' => 'create', // Limit validation to 'create' or 'update' operations
            ),
        ),
    );

    /**
     * beforeSave method
     * 
     * @param  array $options
     * @return boolean
     */
    public function beforeSave($options = array()) {

        parent::beforeSave($options);

        if (isset($this->data[$this->alias]['password'])) {
            $passwordHasher = new SimplePasswordHasher();
            $this->data[$this->alias]['password'] = $passwordHasher->hash($this->data[$this->alias]['password']);
        }

        return true;
    }
}
```

これでパスワードは暗号化されてからDBへ登録されるようになります。

### ログアウト機能

ログアウトはapp/Controller/UserControlelr.phpにlogoutアクションを追加して1行コードを書くだけです。

```php
// app/Controller/UserController.php
public function logout() {
     $this->redirect($this->Auth->logout());
}
```

ログアウトのURLにアクセスすれば、ログアウト状態となり、AppControllerで指定したログアウト後のリダイレクト先へリダイレクトされます。

以上で、ログイン/ログアウト機能の実装は終了です。
