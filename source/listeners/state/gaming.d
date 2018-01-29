module listeners.state.gaming;

import std.algorithm;
import std.array;
import std.concurrency;
import std.format;
import vibe.vibe : WebSocket, logInfo, Json, parseJsonString, msecs, seconds;

import core.gs;
import listeners.qss;
import listeners.state.converter.board;

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
    (ShowResp sr) {
      logInfo("Show response");

      socket.send(Json([
        "sideOn": Json(sr.sideOn),
        "board": fromBoard(sr.board)
      ]).to!string);
    }
    );

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
      default:
        throw new Exception(format("Unknown class: %s", request));
    }
    logInfo(request.to!string);
  }
  return GResp(LoopStatus.OnWaiting);
}
