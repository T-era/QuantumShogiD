module core.dto.show;

import std.concurrency;

import qs.server;

struct PieceResp {
	string[9] possibility;
	int face;
	bool side;
}
alias PieceResp[9][9] Board;
alias PieceResp[40] InHand;

struct ShowReq {}
struct ShowResp {
	bool sideOn;
	Board board;
	InHand tInHand;
	InHand fInHand;
	Remains remains;
}
PieceResp fromQuantum(Quantum q) {
	string[9] poss;
	foreach (z, pt; q.possibility) {
		poss[z] = pt.toString();
	}
	return PieceResp(poss, q.face, q.side);
}
ShowResp show(Tid from, ServerInterface server, ShowReq req) {
	ShowResp resp;
	resp.sideOn = server.getInTern();
	server.show((Pos p, Quantum q) {
		if (q !is null) {
			resp.board[p._y][p._x] = fromQuantum(q);
		}
	});
	int i = 0;
	server.showInHand(true, (Quantum q) {
		resp.tInHand[i++] = fromQuantum(q);
	});
	i = 0;
	server.showInHand(false, (Quantum q) {
		resp.fInHand[i++] = fromQuantum(q);
	});
	resp.remains = server.getRemains();

	return resp;
}
