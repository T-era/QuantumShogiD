module listeners.state.converter.reface_io;

import vibe.vibe;

import core.gs;

Json fromRefaceCallback(RefaceCallback rc) {
	return Json([
		"class": Json("reface")
	]);
}

RefaceCallbackResp toRefaceCallbackResp(Json json) {
	return RefaceCallbackResp(
		json["answer"].to!bool);
}
