/// コアスレッド: マッチング
module core.matching;

import std.concurrency;
import std.uuid;

import core.gs;

enum Keyword { Entry, Retire }
immutable struct Entry {
	string uid;
	Tid myTid;
}
const struct Retire {
	string uid;
}
struct Pair {
	string gid;
	bool sente;
}
class Matcher {
	private Tid[string] byType;

	void entry(string type, string uid) {
		if (type !in byType) {
			byType[type] = spawn(&run, type);
		}
		send(byType[type], uid, thisTid);
	}
	void retire(string type, string uid) {
		if (type in byType) {
			send(byType[type], uid);
		}
	}
	void stopAll() {
		foreach (Tid tid; byType) {
			send(tid, false);
		}
	}
}
void run(string type) {
	Tid[string] waiting;
	Tid[] gServerList;
	for (bool running = true; running;) {
		receive(
			(string uid, Tid tid) {
				// entry
				waiting[uid] = tid;
				while (waiting.length >= 2) {
					auto uid1 = waiting.keys[0];
					auto uid2 = waiting.keys[1];
					auto tid1 = waiting[uid1];
					auto tid2 = waiting[uid2];
					waiting.remove(uid1);
					waiting.remove(uid2);
					string gid = randomUUID().toString;
					Tid gsTid = spawn(&gServer, type, tid1, tid2);
					gServerList ~= gsTid;

					send(tid1, gsTid, Pair(gid, true), tid2);
					send(tid2, gsTid, Pair(gid, false), tid1);
				}
			},
			(string uid) {
				// retire
				waiting.remove(uid);
			},
			(bool r) {
				running = r;
				foreach (tid; gServerList) {
					send(tid, false);
				}
			}
		);
	}
}
