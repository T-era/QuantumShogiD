module listeners.state.gaming;

import std.algorithm;
import std.array;
import std.concurrency;
import std.format;
import vibe.vibe : WebSocket, logInfo, Json, parseJsonString, msecs, seconds;

import core.gs;
import listeners.qss;
import listeners.state.converter.showresp;
import listeners.state.converter.step_io;
import listeners.state.converter.reface_io;

struct GResp {
  LoopStatus status;
}

GResp gaming(scope WebSocket socket, Tid gTid, string uid) {
  bool finished = false;

  receiveTimeout(0.msecs,
    (GOver go) {
      socket.send(Json([
        "class": Json("result"),
        "win": Json(go.win)
      ]).to!string);
      finished = true;
    },
    (Turn t) {
      socket.send(Json([
        "class": Json("your_turn")
      ]).to!string);
    },
    (ErrorResp e) {
      socket.send(Json([
        "class": Json("error"),
        "message": Json(e.message)
      ]).to!string);
    },
    (ShowResp sr) {
      logInfo("Show response");

      socket.send(sr.fromShowResp().to!string);
    },
    (HandStepResp hsr) {
      logInfo("HandStep response");

      socket.send(hsr.fromHandStepResp().to!string);
    },
    (RefaceCallback rc) {
      logInfo("Reface callback");

      socket.send(rc.fromRefaceCallback().to!string);
    });

  if (finished) {
    import std.stdio;
    writeln("Finished");
    return GResp(LoopStatus.Success);
  }

  if (socket.waitForData(100.msecs)) {
    auto request = parseJsonString(socket.receiveText());
    switch (request["class"].to!string) {
      case "show":
        logInfo(format("Show request, %s %s", gTid, thisTid));
        send(gTid, thisTid, ShowReq());
        break;
      case "step":
        logInfo(format("Step request %s", request));
        send(gTid, thisTid, toHandStepReq(request));
        break;
      case "reface":
        logInfo(format("Reface response %s", request));
        send(gTid, toRefaceCallbackResp(request));
        break;
      default:
        throw new Exception(format("Unknown class: %s", request));
    }
    logInfo(request.to!string);
  }
  return GResp(LoopStatus.OnWaiting);
}
