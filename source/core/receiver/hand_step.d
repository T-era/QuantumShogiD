module core.receiver.hand_step;

public import core.receiver.common;
import qs.server.server;

struct HandStepReq {
  bool side;
  Position from;
  Position to;
  bool reface;
}
struct HandStepResp {
  bool finished;
}

HandStepResp handStep(ServerInterface server, HandStepReq req) {
  import std.stdio;
  writeln("Step...", req);

  return HandStepResp(server.aHandStep(
    req.side,
    req.from.toPos(),
    req.to.toPos(),
    () { return req.reface; }));
}
