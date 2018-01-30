module listeners.state.converter.step_io;

import vibe.vibe;

import core.gs;

HandStepReq toHandStepReq(Json json) {
  return HandStepReq(
    json["side"].to!bool,
    Position(
      json["from"]["x"].to!int,
      json["from"]["y"].to!int),
    Position(
      json["to"]["x"].to!int,
      json["to"]["y"].to!int));
}

Json fromHandStepResp(HandStepResp hsr) {
  import std.stdio;
  writeln(hsr);
  return Json([
    "finished": Json(hsr.finished)
  ]);
}
