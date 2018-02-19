module core.dto.hand_step;

import std.concurrency;

public import core.dto.common;
import core.gs;
import qs.server;

struct HandStepReq {
	bool side;
	Position from;
	Position to;
}
struct HandStepResp {
	bool finished;
}
struct RefaceCallback {}
struct RefaceCallbackResp {
	bool answer;
}

HandStepResp handStep(Tid from, ServerInterface server, HandStepReq req) {
	return HandStepResp(server.aHandStep(
		req.side,
		req.from.toPos(),
		req.to.toPos(),
		() => listenReface(from, server)));
}

bool listenReface(Tid from, ServerInterface server) {
	send(from, RefaceCallback());

	bool result;
	for (bool listening = true; listening;) {
		receive(
			(RefaceCallbackResp resp) {
				listening = false;
				result = resp.answer;
			},
			(Tid from, RemainsReq rr) {
				send(from, server.getRemains());
			},
			(Variant v) {
				send(from, ErrorResp("Listening REFACE!"));
			});
	}
	return result;
}
