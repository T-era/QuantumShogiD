module listeners.state.gaming;

import std.algorithm;
import std.array;
import std.concurrency;
import std.format;
import vibe.vibe : WebSocket, logInfo, logError, Json, parseJsonString, msecs, seconds;

import core.gs;
import listeners.qss;
import listeners.state.converter.show_io;
import listeners.state.converter.step_io;
import listeners.state.converter.reface_io;
import listeners.state.converter.put_io;
import listeners.state.converter.show_remains;

struct GResp {
	LoopStatus status;
}

GResp gaming(scope WebSocket socket, Tid gTid, string uid, bool side) {
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
		(GRetire r) {
			logError("Ritire");
			socket.send(Json([
				"class": Json("retired"),
				"message": Json("Partner is gone away..."),
			]).to!string);
			finished = true;
		},
		(ErrorResp e) {
			logError("Error %s", e);
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
		},
		(HandPutResp hpr) {
			logInfo("HandPut response");

			socket.send(hpr.fromHandPutResp().to!string);
		},
		(Remains r) {
			Json jsonR = r.fromRemains();
			jsonR["class"] = Json("time");
			socket.send(jsonR.to!string);
		});

	if (finished) {
		logInfo("Finished:", gTid);
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
				send(gTid, thisTid, toHandStepReq(side, request));
				break;
			case "reface":
				logInfo(format("Reface response %s", request));
				send(gTid, toRefaceCallbackResp(request));
				break;
			case "put":
				logInfo(format("Put request %s", request));
				send(gTid, thisTid, toHandPutReq(side, request));
				break;
			case "time":
				send(gTid, thisTid, RemainsReq());
				break;
			default:
				throw new Exception(format("Unknown class: %s", request));
		}
	}
	return GResp(LoopStatus.OnWaiting);
}

auto gamingDisconnected(Tid gTid) {
	return () {
		send(gTid, thisTid, GRetire());
		return GResp(LoopStatus.Failed);
	};
}
