---
title: MacでTensorFlowのインストールとチュートリアル
author: sh0e1
type: post
date: 2017-01-11T10:26:13+00:00
categories:
  - Python
  - TensorFlow
---
先日TensorFlowを試してみようと思い、Macにインストールしてチュートリアル「[MNIST For ML Beginners](https://www.tensorflow.org/versions/master/tutorials/mnist/beginners/)」をやってみました。  
Pythonは未経験なので、Pythonの環境構築からやったのでご紹介します。
<!--more-->

### Pythonの環境構築

Macでは予めPython2がインストールされていますが、せっかくなのでPython3の環境を構築したく、簡単に環境を切り替えられるpyenv-virtualenvで環境構築を行いました。

#### pyenv-virtualenvとは

[http://dackdive.hateblo.jp/entry/2015/12/12/163400](http://dackdive.hateblo.jp/entry/2015/12/12/163400)  
上記のサイトがpyenv、virtualenv、pyenv-virtualenvの違いをわかりやすく説明してくださっています。

#### pyenv-virtualenvのインストール

Homebrewでインストールしました。Homebrewについては[こちら]()こちら。

```bash
$ brew install pyenv-virtualenv
```

#### Python3のインストール

Pythonのバージョン一覧を確認。

```bash
$ pyenv install -l
```

今回は3.5.2をインストールしました。

```bash
$ pyenv install 3.5.2
$ pyenv rehash
```

#### TensorFlow用の環境を作成

```bash
$ pyenv virtualenv 3.5.2 TensorFlow
$ pyenv rehash
```

#### 環境の切り替え

```bash
$ pyenv global TensorFlow
$ python -V
Python 2.7.10
```

環境を切り替えてもPythonのバージョンが2のままだったので、~/.bash_profileに下記を追記しました。

```bash
$ vi ~/.bash_profile
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
```

```bash
$ source ~/.bash_profile
$ python -V
Python 3.5.2
```

再度確認すると、無事Pythonのバージョンが3に切り替わりました。

#### pipのインストール

Pythonのパッケージ管理ツールであるpipをインストールし、最新にアップグレードします。

```bash
$ easy_install pip
$ pip install --upgrade pip
```

### TensorFlowのインストール

今回はCPU版をインストールしました。GPU版は後で試してみたいと思います。

```bsh
$ pip install --upgrade https://storage.googleapis.com/tensorflow/mac/cpu/tensorflow-0.12.1-py3-none-any.whl
```

これで環境は整ったので、いざチュートリアル!!

### MNIST For ML Beginners

プログラミングのHello Worldのように機械学習にはMNISTがあるそうです。  
https://www.tensorflow.org/tutorials/mnist/beginners/に掲載されているコードをほぼコピペし一応動かしてみました。  
内容としては、手書きの数字の画像と、その画像が実際どの数字かを示すラベルを用いて、画像が何の数字かを予測するモデルをトレーニングしています。最後に出力されるのはテストデータでの精度です。

```python
# tutorial.py
from tensorflow.examples.tutorials.mnist import input_data
import tensorflow as tf

mnist = input_data.read_data_sets("tutorial/MNIST_data/", one_hot=True)

x = tf.placeholder("float", [None, 784])

W = tf.Variable(tf.zeros([784, 10]))
b = tf.Variable(tf.zeros([10]))

y = tf.nn.softmax(tf.matmul(x, W) + b)

y_ = tf.placeholder("float", [None, 10])

cross_entropy = -tf.reduce_sum(y_ * tf.log(y))

train_step = tf.train.GradientDescentOptimizer(0.01).minimize(cross_entropy)

init = tf.global_variables_initializer()

sess = tf.Session()
sess.run(init)

for i in range(1000):
    batch_xs, batch_ys = mnist.train.next_batch(100)
    sess.run(train_step, feed_dict={x: batch_xs, y_: batch_ys})

correct_prediction = tf.equal(tf.argmax(y, 1), tf.argmax(y_, 1))

accuracy = tf.reduce_mean(tf.cast(correct_prediction, "float"))

print(sess.run(accuracy, feed_dict={x: mnist.test.images, y_: mnist.test.labels}))
```

```bash
$ python toutorial.py
Extracting tutorial/MNIST_data/train-images-idx3-ubyte.gz
Extracting tutorial/MNIST_data/train-labels-idx1-ubyte.gz
Extracting tutorial/MNIST_data/t10k-images-idx3-ubyte.gz
Extracting tutorial/MNIST_data/t10k-labels-idx1-ubyte.gz
0.9121
```

ソースは[Github](https://github.com/sh0e1/tensorflow/tree/master/tutorial)にも上げてます。

### まとめ

正直チュートリアルのコードでも、何をやっているか把握できていません。  
勉強しなければと痛感しつつ、理解できれば面白い分野であると思うので、マイペースに少しずつ理解していきたいと思います。おすすめの本とかあったら紹介していただけると嬉しいです。

### 参考サイト

下記サイトを参考にさせていただきました。

- [Python未経験エンジニアがMacでTensorFlowの実行環境+快適なコーディング環境を構築するまで](http://qiita.com/KazaKago/items/587ac1224afc2c9350f1)
- [TensorFlow チュートリアルMNIST For Beginnersを試してみる](http://www.trifields.jp/try-tutorial-mnist-for-ml-beginners-of-tensorflow-1713)
- [[Python]pyenvとvirtualenvとpyenv-virtualenv](http://dackdive.hateblo.jp/entry/2015/12/12/163400)
