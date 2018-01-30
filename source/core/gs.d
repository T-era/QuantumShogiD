module core.gs;

import core.time;
import vibe.vibe;
import std.algorithm;
import std.array;

public import core.receiver.show;
public import core.receiver.hand_step;
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
  auto timer = newTimer(3600, 60);  // TODO by type.
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
  void delegate(Tid, HandStepReq) handStepF = asFunc!(HandStepResp, HandStepReq)(server, &handStep);
  for (bool running = true; running; ) {
    writeln("gs on running");
    receive(
      (bool b) {
        running = b;
      },
      showF,
      handStepF);
  }
}
struct ErrorResp {
  string message;
}
void delegate(Tid, T) asFunc(R, T)(ServerInterface server, R function(ServerInterface, T) f) {
  return (Tid from, T args) {
    try {
      R resp = f(server, args);
      send(from, resp);
    } catch (Exception ex) {
      send(from, ErrorResp(ex.msg));
    }
  };
}