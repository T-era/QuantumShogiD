# QuantumShogiD
====

量子将棋サーバ on Vibe.d

- ビルド: dub
- WebSocket クライアントに対して、JSON APIを提供します。
  - クライアントサイドの参照実装として、index.html があります。

# 進行
　WebSocket で `ws://<host_name>:<port>/qss`にアクセスします。プレイ終了まで、WebSocketは接続を続けてください。  
　最初、クライアントは<ロビー>にいます。参加するには、entry リクエストを送ってください。  
　指定したタイプ(持ち時間の設定です。`http://<host_name>:<port>/types`で選択可能なタイプ一覧を得られます。)で対戦相手が見つかると、match 通知がきます。対局の開始です。

　対局では、step/put リクエストで操作を指示してください。ああ、いや待って。まずは your_turn 通知が来るのを待ってください。  
　手番ではないのに駒を動かすのは反則です、error レスポンスが返ってきます。(初期実装ではペナルティはありません。)  
　your_turn 通知が来たら手番です。当然の話ですが、相手が一手進めたということなので、自分の手を考える前に show リクエストで状況を確認しましょう。



# JSON APIの一覧  
## 共通項

全てのリクエスト/レスポンスメッセージは、トップレベルに"class"プロパティを持ちます。

## 共通パーツ
#### 位置情報
```JSON
{ "x": 1, "y": 2 }
```
<dl>
  <dt>x</dt>
  <dd>盤面の横方向座標</dd>
  <dt>y</dt>
  <dd>盤面の縦方向座標</dd>
</dl>
* 先手/後手によらず、y座標は自陣が6-8で、0−2側に相手がいます。

#### 駒情報
```JSON
{ "face": 0, "side": true, "possibility": ["fu", "kyo"] }
```
<dl>
  <dt>face</dt>
  <dd>成り駒の状況。0: 不成, 1: 成り</dd>
  <dt>side</dt>
  <dd>先手の駒か後手の駒か</dd>
  <dt>possibility</dt>
  <dd>駒の重ね合わせ状態。</dd>
</dl>

#### 残り時間状況
```JSON
{ "notime": true, "remain": 123 }
```
<dl>
  <dt>notime</dt>
  <dd>持ち時間がなくなったかどうか。trueの場合は、持ち時間なしで、各手は minTime 以下で打つ必要があります。</dd>
  <dt>remain</dt>
  <dd>残り時間(単位は秒)</dd>
</dl>


## 詳細（ロビー)
| "class" | 種別 | 概要 |
|:-----|:-----:|:-----|
| entry | リクエスト | ゲームサーバに名前と持ち時間設定を登録し、対戦相手を探します。 |
| match | 通知 | サーバが対戦相手を見つけた場合の通知。 |

### entry リクエスト
```JSON
{ "class": "entry", "type": "string", "name": "string" }
```
<dl>
  <dt>type</dt>
  <dd>持ち時間設定を指定します。選択肢は、http(WebSocketではなく)で/typesをコールして取得してください。</dd>
  <dt>name</dt>
  <dd>適当な名前を名乗ってください。対戦相手に見えます。</dd>
</dl>

### match 通知
```JSON
{ "class": "match", "gid": "string", "side": true, "nameT": "string", "nameF": "string" }
```
<dl>
  <dt>gid</dt>
  <dd>デバッグ情報です。WebSocketクライアントがこれを使うことはありません。</dd>
  <dt>side</dt>
  <dd>真偽値。先手番には true が返されます。</dd>
  <dt>name[TF]</dt>
  <dd>先手/後手それぞれの名前</dd>
</dl>


## 詳細（プレイ中)
| "class" | 種別 | 概要 |
|:-----|:-----:|:-----|
| show | リクエスト/レスポンス | 盤面・手駒・残り時間の取得。手番ではなくてもリクエストできます。timeの方が情報量が少ないのでなるべくtimeを使ってください。 |
| time | リクエスト/レスポンス | 残り時間の取得。手番ではない時にもリクエストできます。 |
| step | リクエスト | |
| put  | リクエスト | |
| your_turn | 通知 | 手番になったタイミングの通知 |
| reface | (stepリクエストに対する)レスポンス/リクエスト | 成金するかどうかの問い合わせ/reface問い合わせに対する返答リクエスト |
| result | 通知 | 勝敗が決定したタイミングの通知 |
| error | レスポンス | エラー。不可能な挙動をリクエストしたり、手番ではない時にstepやputリクエストを送るとerrorレスポンスが返ります。 |
| retired | 通知 | 対戦相手のWebSocketが切断されたことの通知 |
* サーバからクライアントへの通信という意味で、レスポンスと通知は同じものです。ここではリクエストに対する応答をレスポンス、リクエストを伴わないものを通知と呼んでいます。

### show リクエスト
```JSON
{"class": "show"}
```

### show レスポンス
```JSON
{"class": "show", "sideOn": true, "board": [], "tInHand": [], "fInHand": [], "timer": {} }
```
<dl>
  <dt>sideOn</dt>
  <dd>現在の手番です。trueは先手番、falseは後手番を意味します。(あなたが手番であるかどうか、ではありません)</dd>
  <dt>board</dt>
  <dd>盤面上の駒の配置 9 * 9 の2次元配列。配列の各要素は[駒情報]</dd>
  <dt>[tf]InHand</dt>
  <dd>先手/後手それぞれの手駒の一覧。配列の各要素は[駒情報]</dd>
  <dt>timer</dt>
  <dd>先手/後手それぞれの残り時間("time"レスポンスを参照)</dd>
</dl>
* 手駒リストは仕様として、駒が増える際には常にリスト末尾に追加します。つまり、手駒リストは手駒に入った順を維持します。

### time リクエスト
```JSON
{"class": "time"}
```

### time レスポンス
```JSON
{"class": "time", "winner": true, "timeT": {}, "timeF": {} }
```
<dl>
  <dt>winner</dt>
  <dd>(もし勝敗がついた場合は)勝者。通常はnull</dd>
  <dt>time[TF]</dt>
  <dd>先手/後手それぞれの[残り時間状況]</dd>
</dl>

### step リクエスト
```JSON
{ "class": "step", "side": true, "from": {}, "to": {} }
```
<dl>
  <dt>from</dt>
  <dd>駒の移動元座標</dd>
  <dt>to</dt>
  <dd>駒の移動先座標</dd>
</dl>

### put リクエスト
```JSON
{ "class": "put", "side": true, "indexInHand": 1, "to": {} }
```
<dl>
  <dt>indexInHand</dt>
  <dd>手駒リストの中でのインデックス</dd>
  <dt>to</dt>
  <dd>駒の打ち先座標</dd>
</dl>

### your_turn 通知
```JSON
{ "class": "your_turn" }
```

### reface レスポンス
```JSON
{ "class": "reface" }
```

### reface リクエスト
```JSON
{ "class": "your_turn", "answer": true }
```
<dl>
  <dt>answer</dt>
  <dd>成るかどうかを答えます</dd>
</dl>

### result 通知
```JSON
{ "class": "result", "win": true }
```
<dl>
  <dt>win</dt>
  <dd>あなたが、勝利したかどうか</dd>
</dl>

### error レスポンス
```JSON
{ "class": "error", "message": "string" }
```
<dl>
  <dt>message</dt>
  <dd>エラー内容を表す、人間向けメッセージ</dd>
</dl>

### retired 通知
```JSON
{ "class": "retired", "message": "string" }
```
<dl>
  <dt>message</dt>
  <dd>状況を説明する、人間向けメッセージ</dd>
</dl>
