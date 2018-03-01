/// QS用のWebSocketリスナ
module listeners.qss;

import core.thread;
import std.stdio;
import std.uuid;
import vibe.vibe;

import core.matching;
import listeners.state.entry;
import listeners.state.waiting;
import listeners.state.gaming;

enum LoopStatus {
	OnWaiting, Success, Failed
}

R onWsGoing(R, T...)(R function(scope WebSocket socket, T args) f, R delegate() disconnected, scope WebSocket socket, T args) {
	try {
		R resp;
		for (bool running = true; socket.connected && running; ) {
			resp = f(socket, args);
			running = (resp.status == LoopStatus.OnWaiting);
		}
		if (! socket.connected) {
			return disconnected();
		}
		return resp;
	} catch(Exception ex) {
		logError("Error %s", ex);
		socket.send(Json([
			"error": Json(ex.msg)
		]).to!string);
		throw ex;
	}
}
auto qssListener(Matcher waitingSrv) {
	return (scope WebSocket socket) {
		string uid = randomUUID().toString;

		EntryResp er = onWsGoing!(EntryResp, Matcher, string)
				(&entry, () { return entrySuspended(); }, socket, waitingSrv, uid);
		if (er.status == LoopStatus.Failed) {
			return;
		}
		WaitingResp wr = onWsGoing!(WaitingResp, Matcher, string, string)
				(&waiting, waitingDisconnected(waitingSrv, er.type, uid), socket, waitingSrv, er.type, uid);
		if (wr.status == LoopStatus.Failed) {
			return;
		}
		GResp gr = onWsGoing!(GResp, Tid, string, bool)
				(&gaming, gamingDisconnected(wr.gsTid), socket, wr.gsTid, uid, wr.side);
	};
}
