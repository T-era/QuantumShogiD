# APIで使うJSONパーツ

## 位置情報
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

## 駒情報
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

## 残り時間状況
```JSON
{ "notime": true, "remain": 123 }
```
<dl>
  <dt>notime</dt>
  <dd>持ち時間がなくなったかどうか。trueの場合は、持ち時間なしで、各手は minTime 以下で打つ必要があります。</dd>
  <dt>remain</dt>
  <dd>残り時間(単位は秒)</dd>
</dl>
