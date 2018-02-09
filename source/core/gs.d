/// コアスレッド
module core.gs;

import core.time;
import vibe.vibe;
import std.algorithm;
import std.array;

public import core.receiver.show;
public import core.receiver.hand_step;
public import core.receiver.hand_put;
public import core.receiver.time_remains;
import qs.server;


struct Turn {}
struct GRetire{}
struct GOver {
	bool win;
}
struct GType {
	int minTime;
	int loadTime;
}
GType[string] types;

static this() {
	types = [
		"2min/1min": GType(60, 120),
		"1hour/1min": GType(60, 3600)
	];
}

qs.timer.Timer timerByType(string type) {
	auto gt = types[type];
	return newTimer(gt.minTime, gt.loadTime);
}

void gServer(string type, Tid tid1, Tid tid2) {
	auto timer = timerByType(type);
	ServerInterface server = new Server(timer);
	server.setCallbacks(
		(bool side) {
			Tid to = side ? tid1 : tid2;
			send(to, Turn());
		},
		(bool sideWin) {
			Tid win = sideWin ? tid1 : tid2;
			Tid lose = sideWin ? tid2 : tid1;
			send(tid1, GOver(sideWin));
			send(tid2, GOver(! sideWin));
		});

	server.start();

	void delegate(Tid, ShowReq) showF = asFunc!(ShowResp, ShowReq)(server, &show);
	void delegate(Tid, HandStepReq) handStepF = asFunc!(HandStepResp, HandStepReq)(server, &handStep);
	void delegate(Tid, HandPutReq) handPutF = asFunc!(HandPutResp, HandPutReq)(server, &handPut);
	void delegate(Tid, RemainsReq) remainsF = asFunc!(Remains, RemainsReq)(server, &timeRemains);
	for (bool running = true; running; ) {
		receive(
			(GRetire _, Tid from) {
				running = false;
				foreach (tid; [tid1, tid2]) {
					if (tid != from) {
						send(tid, GRetire());
					}
				}
			},
			showF,
			handStepF,
			handPutF,
			remainsF);
	}
}
struct ErrorResp {
	string message;
}
void delegate(Tid, T) asFunc(R, T)(ServerInterface server, R function(Tid, ServerInterface, T) f) {
	return (Tid from, T args) {
		try {
			R resp = f(from, server, args);
			send(from, resp);
		} catch (Exception ex) {
			logError("Error?", ex);
			send(from, ErrorResp(ex.msg));
		}
	};
}
