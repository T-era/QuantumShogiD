module qs.rule.quantum.quantum;

import qs.pos;
import qs.rule.piece_type;
import qs.rule.actions.action;

enum Void { _ };

alias void delegate(Quantum piece, PieceType[] dec) DecisionListener;


class Quantum {
	bool side;
	PieceType[] possibility;
	Pos pos;
	int face;

	Action!Void reface;
	Action!Pos putOn;
	Action!Pos move;

	DecisionListener _listener;

	this(bool side, DecisionListener listener, PieceType[] type, Pos pos) {
		this.side = side;
		this._listener = listener;
		this.possibility = type;
		this.pos = pos;
		this.face = 0;

		this.reface = new Reface(this);
		this.putOn = new PutOn(this);
		this.move = new Move(this);
	}
}

unittest {
	class ListenerMock {
		PieceType[][] calledBack = [];

		void decide(Quantum q, PieceType[] dec) {
			this.calledBack ~= dec;
		}
	}

	bool _move(Quantum p, Pos pos) {
		auto cont = p.move.prepare(pos);
		bool ret = cont.can();
		if (ret) {
			cont.doit();
		}
		return ret;
	}

	{
		auto listener = new ListenerMock();
		Quantum q = new Quantum(false, &listener.decide, PieceType.AllPiece, new Pos(0, 0));

		assert(_move(q, new Pos(1, 2)), "move as kei");
		assert(q.possibility.length == 1, "result");
		assert(q.possibility[0] == PieceType.kei, "result detail");
		assert(listener.calledBack[0].length == 7, "callback");
	}
	{
		auto listener = new ListenerMock();
		Quantum q = new Quantum(false, &listener.decide, PieceType.AllPiece, new Pos(0, 0));

		assert(_move(q, new Pos(2, 2)), "move as kk");
		assert(q.possibility.length == 1, "result");
		assert( q.possibility[0] == PieceType.kk, "result detail");
		assert(listener.calledBack[0].length == 7, "callback");
	}
	import std.algorithm;
	{
		auto listener = new ListenerMock();
		Quantum q = new Quantum(false, &listener.decide, PieceType.AllPiece, new Pos(0, 0));

		assert(_move(q, new Pos(1, 1)), "move to (1,1)");
		assert(q.possibility.length == 4, "result");
		assert(q.possibility.find(PieceType.kk).length > 0
				&& q.possibility.find(PieceType.kin).length > 0
				&& q.possibility.find(PieceType.gin).length > 0
				&& q.possibility.find(PieceType.ou).length > 0
			, "result detail");
		assert(listener.calledBack[0].length == 4, "callback");
	}
	{
		auto listener = new ListenerMock();
		Quantum q = new Quantum(false, &listener.decide, PieceType.AllPiece, new Pos(0, 0));

		assert(_move(q, new Pos(0, 1)), "move to front");
		assert(q.possibility.length == 6, "result");
		assert(q.possibility.find(PieceType.fu).length > 0
			&& q.possibility.find(PieceType.kyo).length > 0
			&& q.possibility.find(PieceType.gin).length > 0
			&& q.possibility.find(PieceType.kin).length > 0
			&& q.possibility.find(PieceType.hi).length > 0
			&& q.possibility.find(PieceType.ou).length > 0
			, "result detail");
		assert(listener.calledBack[0].length == 2, "callback");
		assert(! _move(q, new Pos(0+1, 1+2)), "can't move as kei");
		assert(! _move(q, new Pos(0+2, 1+2)), "can't move as kk");
		assert(_move(q, new Pos(0+0, 1+1)), "move to front, again");
		assert(q.possibility.length == 6, "(result)");
	}
}
