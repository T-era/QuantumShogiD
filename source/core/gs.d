/// コアスレッド
module core.gs;

import core.time;
import vibe.vibe;
import std.algorithm;
import std.array;

public import core.dto.show;
public import core.dto.hand_step;
public import core.dto.hand_put;
public import core.dto.time_remains;
import qs.server;


struct Turn {}
struct ErrorResp {
	string message;
}
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

void gServer(string type, Tid tid1, Tid tid2, Tid owner) {
	logInfo("Server thread started.", tid1, tid2, type);

	auto timer = timerByType(type);
	ServerInterface server = new Server(timer);
	bool running = true;
	void finished() {
		running = false;
		send(owner, Finished(), thisTid());
	}
	server.setCallbacks(
		(bool side) {
			Tid to = side ? tid1 : tid2;
			send(to, Turn());
		},
		(bool sideWin) {
			send(tid1, GOver(sideWin));
			send(tid2, GOver(! sideWin));
			running = false;
		});

	server.start();

	for (; running; ) {
		receive(
			(ShuttingDown _) {
				running = false;
			},
			(Tid from, GRetire r) {
				running = false;
				foreach (tid; [tid1, tid2]) {
					if (tid != from) {
						send(tid, GRetire());
					}
				}
				send(owner, r);
			},
			(Tid from, HandStepReq req) {
				try {
					bool finished = server.aHandStep(
						req.side,
						req.from.toPos(),
						req.to.toPos(),
						() => listenReface(from, server));
					running = ! finished;
					send(from, HandStepResp(finished));
				} catch (Exception ex) {
					logError("Error", ex);
					send(from, ErrorResp(ex.msg));
				}
			},
			asFunc!(ShowResp, ShowReq)(server, &show),
			asFunc!(HandPutResp, HandPutReq)(server, &handPut),
			asFunc!(Remains, RemainsReq)(server, &timeRemains));
	}
	logInfo("Server thread finished normally.");
}

// 関数のIN/OUTを、スレッド間の応答に置き換えます。
// 関数の戻り値は、コール元のスレッドに送り返します。
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
