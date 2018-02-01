module qs.rule.actions.move;

import qs.pos;
import qs.rule.actions.action;
import qs.rule.quantum.quantum;
import qs.rule.piece_type;

class Move : Action!Pos {
	Quantum quantum;

	this(Quantum quantum) {
		this.quantum = quantum;
	}
	MoveCont prepare(Pos to) {
		int dty = to._y - this.quantum.pos._y;
		int dy = this.quantum.side ? -dty : dty;
		int dx = to._x - this.quantum.pos._x;

		PieceType[] newPossibility = [];
		PieceType[] removedPossibility = [];
		foreach (PieceType poss; this.quantum.possibility) {
			if (poss.canMoveTo(this.quantum.face, dx, dy)) {
				newPossibility ~= poss;
			} else {
				removedPossibility ~= poss;
			}
		}
		return new MoveCont(
			to,
			this.quantum,
			newPossibility,
			removedPossibility);
	}
}
class MoveCont : ActionCont {
	Pos to;
	Quantum who;
	PieceType[] newPossibility;
	PieceType[] removedPossibility;

	this(Pos to, Quantum who, PieceType[] newPossibility, PieceType[] removedPossibility) {
		this.to = to;
		this.who = who;
		this.newPossibility = newPossibility;
		this.removedPossibility = removedPossibility;
	}

	bool can() {
		return this.newPossibility.length > 0;
	}
	void doit() {
		if (! this.can()) throw new Exception("Illegal call");

		this.who.pos = this.to;
		this.who.possibility = this.newPossibility;
		if (this.removedPossibility.length > 0) {
			this.who.listener(this.who, this.removedPossibility);
		}
	}
}
