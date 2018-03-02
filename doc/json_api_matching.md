# ロビーでのAPI

## entry リクエスト
```JSON
{ "class": "entry", "type": "string", "name": "string" }
```
<dl>
  <dt>type</dt>
  <dd>持ち時間設定を指定します。選択肢は、[http(WebSocketではなく)で/typesをコールして取得](./json_api.md#持ち時間タイプの一覧)してください。</dd>
  <dt>name</dt>
  <dd>適当な名前を名乗ってください。対戦相手に見えます。</dd>
</dl>

## match 通知
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
