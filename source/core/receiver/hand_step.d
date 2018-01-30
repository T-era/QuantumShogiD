module core.receiver.hand_step;

import std.concurrency;

public import core.receiver.common;
import core.gs;
import qs.server.server;

struct HandStepReq {
  bool side;
  Position from;
  Position to;
}
struct HandStepResp {
  bool finished;
}
struct RefaceCallback {}
struct RefaceCallbackResp {
  bool answer;
}

HandStepResp handStep(Tid from, ServerInterface server, HandStepReq req) {
  return HandStepResp(server.aHandStep(
    req.side,
    req.from.toPos(),
    req.to.toPos(),
    () { return listenReface(from); }));
}

bool listenReface(Tid from) {
  send(from, RefaceCallback());

  bool result;
  for (bool listening = true; listening;) {
    receive(
      (RefaceCallbackResp resp) {
        listening = false;
        result = resp.answer;
      },
      (Variant v) {
        send(from, ErrorResp("Listening REFACE!"));
      });
  }
  return result;
}
