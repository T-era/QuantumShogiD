module core.gs;

import core.time;
import vibe.vibe;
import std.algorithm;
import std.array;

import qs.common.pos;
import qs.rule.quantum.quantum;
import qs.timer.timer;
import qs.server.server;
import std.stdio;

struct Turn {}
struct GOver {
  bool win;
}

void gServer(string type, Tid tid1, Tid tid2) {
  auto timer = newTimer(10, 10);  // TODO by type.
  ServerInterface server = new Server(timer);
  server.setCallbacks(
    (bool side) {
      Tid to = side ? tid1 : tid2;
      send(to, Turn());
    },
    (bool sideWin) {
      Tid win = sideWin ? tid1 : tid2;
      Tid lose = sideWin ? tid2 : tid1;
      send(tid1, GOver(sideWin));
      send(tid2, GOver(! sideWin));
    });

  server.start();

  void delegate(Tid, ShowReq) showF = asFunc!(ShowResp, ShowReq)(server, &show);
  for (bool running = true; running; ) {
    writeln("gs on running");
    receive(
      (bool b) {
        writeln("Bool:", b);
        running = b;
      },
      showF);
  }
}

void delegate(Tid, T) asFunc(R, T)(ServerInterface server, R function(ServerInterface, T) f) {
  return (Tid from, T args) {
    R resp = f(server, args);
    send(from, resp);
  };
}

alias string[9][9][9] Board;
struct ShowReq {}
struct ShowResp {
  bool sideOn;
  Board board;
}
ShowResp show(ServerInterface server, ShowReq req) {
  import std.stdio;
  writeln("Called show");

  ShowResp resp;
  resp.sideOn = server.getInTern();
  server.show((Pos p, Quantum q) {
    if (q !is null) {
      foreach (z, pt; q.possibility) {
        resp.board[p._y][p._x][z] = pt.toString();
      }
    }
  });

  return resp;
}
