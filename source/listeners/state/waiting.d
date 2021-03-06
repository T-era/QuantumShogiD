module listeners.state.waiting;

import vibe.vibe;
import std.concurrency;

import core.gs;
import core.matching;
import listeners.qss;

struct WaitingResp {
	LoopStatus status;
	Tid gsTid;
	bool side;
}

WaitingResp waiting(scope WebSocket socket, Matcher waitingSrv, string type, string uid) {
	bool received = false;

	// listen paired
	Tid gsTid;
	bool side;
	receiveTimeout(0.msecs,
		(Tid tid, Pair p, Tid tid2) {
			socket.send(Json([
				"class": Json("match"),
				"gid": Json(p.gid),
				"side": Json(p.sente),
				"nameT": Json(p.nameT),
				"nameF": Json(p.nameF)
			]).to!string);
			gsTid = tid;
			received = true;
			side = p.sente;
		});
	if (received) {
		return WaitingResp(LoopStatus.Success, gsTid, side);
	}

	// listen retire-call
	if (socket.waitForData(100.msecs)) {
		auto request = parseJsonString(socket.receiveText());
		if (request["class"] == "retire") {
			waitingSrv.retire(type, uid);
			return WaitingResp(LoopStatus.Failed);
		} else {
			throw new Exception(format("Unexpected request: %s", request));
		}
	}
	return WaitingResp(LoopStatus.OnWaiting);
}

auto waitingDisconnected(Matcher waitingSrv, string type, string uid) {
	return () {
		waitingSrv.retire(type, uid);
		return WaitingResp(LoopStatus.Failed);
	};
}
