module listeners.state.converter.step_io;

import vibe.vibe;

import core.gs;

HandStepReq toHandStepReq(bool side, Json json) {
	return HandStepReq(
		side,
		Position(
			json["from"]["x"].to!int,
			json["from"]["y"].to!int),
		Position(
			json["to"]["x"].to!int,
			json["to"]["y"].to!int));
}

Json fromHandStepResp(HandStepResp hsr) {
	return Json([
		"finished": Json(hsr.finished)
	]);
}
