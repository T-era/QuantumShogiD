# 対局室のAPI

## show リクエスト
```JSON
{"class": "show"}
```

## show レスポンス
```JSON
{"class": "show", "sideOn": true, "board": [], "tInHand": [], "fInHand": [], "timer": {} }
```
<dl>
  <dt>sideOn</dt>
  <dd>現在の手番です。trueは先手番、falseは後手番を意味します。(あなたが手番であるかどうか、ではありません)</dd>
  <dt>board</dt>
  <dd>盤面上の駒の配置 9 * 9 の2次元配列。配列の各要素は[駒情報](./json_api_common.md#駒情報)</dd>
  <dt>[tf]InHand</dt>
  <dd>先手/後手それぞれの手駒の一覧。配列の各要素は[駒情報](./json_api_common.md#駒情報)</dd>
  <dt>timer</dt>
  <dd>先手/後手それぞれの残り時間("time"レスポンスを参照)</dd>
</dl>
* 手駒リストは仕様として、駒が増える際には常にリスト末尾に追加します。つまり、手駒リストは手駒に入った順を維持します。

## time リクエスト
```JSON
{"class": "time"}
```

## time レスポンス
```JSON
{"class": "time", "winner": true, "timeT": {}, "timeF": {} }
```
<dl>
  <dt>winner</dt>
  <dd>(もし勝敗がついた場合は)勝者。通常はnull</dd>
  <dt>time[TF]</dt>
  <dd>先手/後手それぞれの[残り時間状況](./json_api_common.md#残り時間状況)</dd>
</dl>

## step リクエスト
```JSON
{ "class": "step", "side": true, "from": {}, "to": {} }
```
<dl>
  <dt>from</dt>
  <dd>駒の移動元[座標](./josn_api_common.md#位置情報)</dd>
  <dt>to</dt>
  <dd>駒の移動先[座標](./josn_api_common.md#位置情報)</dd>
</dl>

## put リクエスト
```JSON
{ "class": "put", "side": true, "indexInHand": 1, "to": {} }
```
<dl>
  <dt>indexInHand</dt>
  <dd>手駒リストの中でのインデックス</dd>
  <dt>to</dt>
  <dd>駒の打ち先[座標](./josn_api_common.md#位置情報)</dd>
</dl>

## your_turn 通知
```JSON
{ "class": "your_turn" }
```

## reface レスポンス
```JSON
{ "class": "reface" }
```

## reface リクエスト
```JSON
{ "class": "your_turn", "answer": true }
```
<dl>
  <dt>answer</dt>
  <dd>成るかどうかを答えます</dd>
</dl>

## result 通知
```JSON
{ "class": "result", "win": true }
```
<dl>
  <dt>win</dt>
  <dd>あなたが、勝利したかどうか</dd>
</dl>

## error レスポンス
```JSON
{ "class": "error", "message": "string" }
```
<dl>
  <dt>message</dt>
  <dd>エラー内容を表す、人間向けメッセージ</dd>
</dl>

## retired 通知
```JSON
{ "class": "retired", "message": "string" }
```
<dl>
  <dt>message</dt>
  <dd>状況を説明する、人間向けメッセージ</dd>
</dl>
