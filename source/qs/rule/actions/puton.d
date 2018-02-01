module qs.rule.actions.puton;

import std.algorithm;

import qs.pos;
import qs.rule.actions.action;
import qs.rule.quantum.quantum;
import qs.rule.piece_type;

class PutOn : Action!Pos {
	Quantum quantum;
	this(Quantum quantum) {
		this.quantum = quantum;
	}
	ActionCont prepare(Pos to) {
		if (this.quantum.pos !is null) {
			return ActionCont.FalseCont;
		}

		int[] edgeLine;
		if (this.quantum.side) {
			edgeLine = [0, 1];
		} else {
			edgeLine = [8, 7];
		}

		PieceType[] forbidden;
		if (to._y == edgeLine[0]) {
			forbidden = [PieceType.fu, PieceType.kyo, PieceType.kei];
		} else if (to._y == edgeLine[1]) {
			forbidden = [PieceType.kei];
		} else {
			forbidden = [];
		}

		return new PutOnCont(to, this.quantum, forbidden);
	}
}
class PutOnCont : ActionCont {
	Pos to;
	Quantum who;
	PieceType[] forbidden;

	this(Pos to, Quantum who, PieceType[] forbidden) {
		this.to = to;
		this.who = who;
		this.forbidden = forbidden;
	}

	bool can() {
		if (this.forbidden.length > 0) {
			return this.who.possibility.any!((PieceType poss) {
				return !canFind(this.forbidden, poss);
			});
		} else {
			return true;
		}
	}
	void doit() {
		if (! this.can()) throw new Exception("Illegal call");

		if (this.forbidden.length > 0) {
			PieceType[] newPossibility = [];
			PieceType[] removedPossibility = [];
			foreach(PieceType poss; this.who.possibility) {
				if (canFind(this.forbidden, poss)) {
					removedPossibility ~= poss;
				} else {
					newPossibility ~= poss;
				}
			}
			this.who.pos = this.to;
			if (removedPossibility.length > 0) {
				this.who.possibility = newPossibility;

				this.who.listener(this.who, removedPossibility);
			}
		} else {
			this.who.pos = this.to;
		}
	}
}
