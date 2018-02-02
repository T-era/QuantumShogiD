/// コアスレッド: マッチング
module core.matching;

import std.concurrency;
import std.uuid;

import core.gs;

enum Keyword { Entry, Retire }

const struct Retire {
	string uid;
}
struct Pair {
	string gid;
	bool sente;
	string nameT;
	string nameF;
}
class Matcher {
	private Tid[string] byType;

	void entry(string name, string type, string uid) {
		if (type !in byType) {
			byType[type] = spawn(&run, type);
		}
		send(byType[type], thisTid, name, uid);
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
struct EntryItem {
	Tid tid;
	string name;
}
void run(string type) {
	EntryItem[string] waiting;
	Tid[] gServerList;
	for (bool running = true; running;) {
		receive(
			(Tid tid, string name, string uid) {
				// entry
				waiting[uid] = EntryItem(tid, name);
				while (waiting.length >= 2) {
					auto uid1 = waiting.keys[0];
					auto uid2 = waiting.keys[1];
					auto item1 = waiting[uid1];
					auto item2 = waiting[uid2];
					waiting.remove(uid1);
					waiting.remove(uid2);
					string gid = randomUUID().toString;
					Tid gsTid = spawn(&gServer, type, item1.tid, item2.tid);
					gServerList ~= gsTid;

					send(item1.tid, gsTid, Pair(gid, true, item1.name, item2.name), item2.tid);
					send(item2.tid, gsTid, Pair(gid, false, item1.name, item2.name), item1.tid);
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
