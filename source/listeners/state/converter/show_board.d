module listeners.state.converter.show_board;

import vibe.vibe;

import core.gs;
import listeners.state.converter.showr_io;

Json fromBoard(Board board) {
	Json ret = Json.emptyArray;
	foreach (y; 0..9) {
		ret ~= [Json.emptyArray];
		foreach (x; 0..9) {
			ret[y] ~= [Json.emptyArray];
			ret[y][x] = fromPieceResp(board[y][x]);
		}
	}
	return ret;
}
