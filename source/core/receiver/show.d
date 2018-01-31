module core.receiver.show;

import std.concurrency;

import qs.server.server;
import qs.timer.timer;
import qs.common.pos;
import qs.rule.quantum.quantum;

alias string[9][9][9] Board;  // TODO Add Face
alias string[9][40] InHand;

struct ShowReq {}
struct ShowResp {
  bool sideOn;
  Board board;
  InHand tInHand;
  InHand fInHand;
  Remains remains;
}

ShowResp show(Tid from, ServerInterface server, ShowReq req) {
  ShowResp resp;
  resp.sideOn = server.getInTern();
  server.show((Pos p, Quantum q) {
    if (q !is null) {
      foreach (z, pt; q.possibility) {
        resp.board[p._y][p._x][z] = pt.toString();
      }
    }
  });
  int i = 0;
  server.showInHand(true, (Quantum q) {
    foreach (z, pt; q.possibility) {
      resp.tInHand[i][z] = pt.toString();
    }
    i++;
  });
  i = 0;
  server.showInHand(false, (Quantum q) {
    foreach (z, pt; q.possibility) {
      resp.fInHand[i][z] = pt.toString();
    }
    i++;
  });
  resp.remains = server.getRemains();

  return resp;
}
