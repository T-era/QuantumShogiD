module core.dto.time_remains;

import std.concurrency;

public import qs.server : Remains;
import qs.server : ServerInterface;

struct RemainsReq {}

Remains timeRemains(Tid from, ServerInterface server, RemainsReq req) {
	return server.getRemains();
}
