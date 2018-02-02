module listeners.state.converter.show_inhand;

import std.algorithm;
import std.array;
import vibe.vibe;

import core.gs;
import listeners.state.converter.show_io;

Json fromInHand(InHand inHand) {
	PieceResp[] temp = inHand[];
	Json ret = Json(
		temp.filter!((PieceResp pr) {
			return pr != PieceResp.init;
		}).map!((PieceResp pr) {
			return pr.fromPieceResp();
		}).array);
	return ret;
}
unittest {
	PieceResp[40] inHand;
	assert(fromInHand(inHand).to!string == "[]");
	inHand[0] = PieceResp(["A","B","C","","","","","",""],0, true);
	assert(fromInHand(inHand) == parseJsonString(`[{"face":0,"possibility":["A","B","C"],"side":true}]`));
	inHand[39] = PieceResp(["a","b","","","","","","",""],1, false);
	assert(fromInHand(inHand) == parseJsonString(`[{"face":0,"possibility":["A","B","C"],"side":true},{"face":1,"possibility":["a","b"],"side":false}]`));
}
