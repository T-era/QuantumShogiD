module listeners.state.converter.show_remains;

import vibe.vibe;

import qs.server;

Json fromRemains(Remains remains) {
	Json ret = Json.emptyArray;
	return Json([
		"winner": fromSide(remains.winner),
		"timeT": fromRemainsEach(remains.timeT),
		"timeF": fromRemainsEach(remains.timeF)
	]);
}

Json fromRemainsEach(RemainsEach re) {
	return Json([
		"notime": Json(re.notime),
		"remain": Json(re.remain.total!"seconds")
	]);
}

Json fromSide(Side side) {
	final switch(side) {
	case Side.None:
		return Json(null);
	case Side.True:
		return Json(true);
	case Side.False:
		return Json(false);
	}
}
