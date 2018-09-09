# QuantumShogiD

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

# APIの詳細
  [APIの詳細](/doc/json_api.md)

# イベント
  [イベントフロー図(SVG)](/doc/event_matrix.svg)

# 実行環境

　GCP無料環境で試験運用中:
- View http://35.233.226.68/index.html
- API http://35.233.226.68/qss
