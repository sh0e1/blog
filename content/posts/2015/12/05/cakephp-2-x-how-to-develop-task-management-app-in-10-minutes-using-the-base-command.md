---
title: CakePHP 2.x – bakeコマンドを使って10分でタスク管理アプリを開発する方法
author: sh0e1
type: post
date: 2015-12-04T17:40:44+00:00
categories:
  - CakePHP 2.x
---
CakePHPのbakeコマンドを使って10分でタスク管理アプリを開発する方法です。  
データベースにテーブルを作成すれば、CakePHPのbakeコマンドで簡単にCRUD（クラッド）のWebアプリケーションを開発することができます。

今回作るタスク管理アプリは、ログイン、ログアウト、タスクのメール配信などの機能は一切ありません。  
単純にタスクを作成、参照、更新、削除だけできるアプリケーションです。
<!--more-->

### CRUDとは

> CRUD（クラッド）とは、ほとんど全てのコンピュータソフトウェアが持つ永続性[1]の4つの基本機能のイニシャルを並べた用語。その4つとは、Create（生成）、Read（読み取り）、Update（更新）、Delete（削除）である。ユーザインタフェースが備えるべき機能（情報の参照/検索/更新）を指す用語としても使われる。  
>
> [Wikipedia](https://ja.wikipedia.org/wiki/CRUD)より引用

### 前提条件

ローカルにCakePHPの開発環境が構築済であること。まだ環境を構築していない場合は、次のページを参照してください。  
[]()

### データベースにテーブルを作成

下記のSQLを実行して、taskテーブルを作成します。

```sql
-- create task table
CREATE TABLE cakephp.tasks (
  id int(11) NOT NULL AUTO_INCREMENT,
  name varchar(255) NOT NULL,
  complete_flg boolean NOT NULL,
  created datetime,
  modified datetime,
  PRIMARY KEY (id)
) DEFAULT CHARSET = utf8;
```

### bakeコマンド実行

bakeコマンドはテーブルを参照して、Model、Controller、Viewを自動生成してくれる機能です。  
Model、Controller、Viewをそれぞれ対話形式で細かく設定して生成することもできますが、今回は、Model、Controller、Viewを全て生成するallオプションを指定して実行します。

```bash
$ cd /path/to/cakephp/
$ php app/Console/cake.php bake all

Welcome to CakePHP v2.6.10 Console
---------------------------------------------------------------
App : app
Path: /path/to/cakephp/app/
---------------------------------------------------------------
Bake All
---------------------------------------------------------------
Possible Models based on your current database:
1. Task
Enter a number from the list above,
type in the name of another model, or 'q' to exit
[q] > 1 # bakeするテーブルを番号で指定

Baking model class for Task...

Creating file /path/to/cakephp/app/Model/Task.php
Wrote `/path/to/cakephp/app/Model/Task.php`

Baking controller class for Tasks...

Creating file /path/to/cakephp/app/Controller/TasksController.php
Wrote `/path/to/cakephp/app/Controller/TasksController.php`
PHPUnit is not installed. Do you want to bake unit test files anyway? (y/n)
[y] > y # PHPUnitがインストールされていないけど、テスト用のファイルを生成するかって聞かれたので、ひとまずYes

You can download PHPUnit from http://phpunit.de
Bake is detecting possible fixtures...

Baking test case for Tasks Controller ...

Creating file /path/to/cakephp/app/Test/Case/Controller/TasksControllerTest.php
Wrote `/path/to/cakephp/app/Test/Case/Controller/TasksControllerTest.php`

Baking `index` view file...

Creating file /path/to/workspace/cakephp/app/View/Tasks/index.ctp
Wrote `/path/to/cakephp/app/View/Tasks/index.ctp`

Baking `view` view file...

Creating file /path/to/cakephp/app/View/Tasks/view.ctp
Wrote `/path/to/cakephp/app/View/Tasks/view.ctp`

Baking `add` view file...

Creating file /path/to/cakephp/app/View/Tasks/add.ctp
Wrote `/path/to/cakephp/app/View/Tasks/add.ctp`

Baking `edit` view file...

Creating file /path/to/cakephp/app/View/Tasks/edit.ctp
Wrote `/path/to/cakephp/app/View/Tasks/edit.ctp`

Bake All complete
```

コマンド実行後、下記のファイルが自動生成されているはずです。

- app/Controller/TasksController.php
- app/Model/Task.php
- app/View/Tasks/add.ctp
- app/View/Tasks/edit.ctp
- app/View/Tasks/index.ctp
- app/View/Tasks/delete.ctp

※テスト用のファイルは記載していません。

### Session Componentを読み込む

AppControllerでSessionコンポーネントを読み込むようにコードを追加します。

```php
// app/Controller/AppController.php
public $components = array(
    'DebugKit.Toolbar',
    'Session' // 追記
);
```

### 確認

これでブラウザからタスクの一覧表示、新規登録、更新、参照、削除ができるようになっています。

#### 一覧画面

http://localhost/cakephp/tasks

#### 新規登録画面

http://localhost/cakephp/tasks/add

#### 更新画面

http://localhost/cakephp/tasks/edit/{id}

#### 詳細画面

http://localhost/cakephp/tasks/view/{id}

今回はこれで完成とします。  
次回はログイン、ログアウト機能を追加しようと思います。  
以上、CakePHP 2.xでbakeコマンドを使って10分でタスク管理アプリを開発する方法でした。
