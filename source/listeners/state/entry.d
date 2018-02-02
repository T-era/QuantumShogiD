module listeners.state.entry;

import vibe.vibe;

import core.matching;
import listeners.qss;

struct EntryResp {
	LoopStatus status;
	string type;
	string uid;
}
EntryResp entry(scope WebSocket socket, Matcher matchingSrv, string uid) {
	if (socket.waitForData(100.msecs)) {
		auto request = parseJsonString(socket.receiveText());
		if (request["class"] == "entry") {
			string type = request["type"].to!string;
			string name = request["name"].to!string;

			matchingSrv.entry(name, type, uid);
			return EntryResp(LoopStatus.Success, type, uid);
		} else {
			throw new Exception(format("Unexpected request: %s", request));
		}
	}
	return EntryResp(LoopStatus.OnWaiting);
}

void entrySuspended() {}
