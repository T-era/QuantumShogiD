module core.receiver.hand_put;

import std.concurrency;
import std.format;

public import core.receiver.common;
import core.gs;
import qs.server;

struct HandPutReq {
	bool side;
	int indexInHand;
	Position to;
}
struct HandPutResp {}

HandPutResp handPut(Tid from, ServerInterface server, HandPutReq req) {
	Quantum q = server.getInHand(req.side, req.indexInHand);
	if (q is null) throw new Exception(format("No piece in hand at %d", req.indexInHand));

	server.aHandPut(
		req.side,
		q,
		req.to.toPos());
	return HandPutResp();
}
