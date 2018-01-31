/// 死活監視用のリスナ
module listeners.alive;

import vibe.vibe;
import std.stdio;

void alive(HTTPServerRequest req, HTTPServerResponse res) {
  logInfo("aliving");
  res.writeBody("OK");
}
