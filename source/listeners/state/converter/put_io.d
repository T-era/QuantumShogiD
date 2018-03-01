module listeners.state.converter.put_io;

import vibe.vibe;

import core.gs;

HandPutReq toHandPutReq(bool side, Json json) {
	return HandPutReq(
		side,
		json["indexInHand"].to!int,
		Position(
			json["to"]["x"].to!int,
			json["to"]["y"].to!int));
}

Json fromHandPutResp(HandPutResp hsr) {
	return Json(["put": Json("OK")]);
}
