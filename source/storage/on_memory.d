module storage.on_memory;

import std.concurrency;
import std.uuid;

enum Keyword { Entry, Retire }
immutable struct Entry {
  string uid;
  Tid myTid;
}
const struct Retire {
  string uid;
}
const struct Pair {
  string gid;
}
class WaitingEntry {
  private Tid[string] byType;

  void entry(string type, string uid) {
    if (type !in byType) {
      byType[type] = spawn(&run, type);
    }
    send(byType[type], uid, thisTid);
  }
  void retire(string type, string uid) {
    send(byType[type], uid);
  }
  void stopAll() {
    foreach (Tid tid; byType) {
      send(tid, false);
    }
  }
}
void run(string type) {
  Tid[string] waiting;
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
          send(tid1, Pair(gid));
          send(tid2, Pair(gid));
        }
      },
      (string uid) {
        // retire
        waiting.remove(uid);
      },
      (bool r) { running = r; }
    );
  }
}
