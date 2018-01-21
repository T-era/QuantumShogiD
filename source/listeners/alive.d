module listeners.alive;

import vibe.vibe;
import std.stdio;

void alive(HTTPServerRequest req, HTTPServerResponse res) {
  writeln("aliving");
  res.writeBody("OK");
}
