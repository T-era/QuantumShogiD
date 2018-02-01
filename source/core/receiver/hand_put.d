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

bool listenReface(Tid from) {
	send(from, RefaceCallback());

	bool result;
	for (bool listening = true; listening;) {
		receive(
			(RefaceCallbackResp resp) {
				listening = false;
				result = resp.answer;
			},
			(Variant v) {
				send(from, ErrorResp("Listening REFACE!"));
			});
	}
	return result;
}
