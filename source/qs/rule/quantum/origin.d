module qs.rule.quantum.origin;

import qs.rule.init_layout;
import qs.rule.piece_type;
import qs.rule.quantum.decide;
import qs.rule.quantum.quantum;
import qs.pos;

alias void delegate(int x, int y, Quantum q) InitCallback;

class Origin {
    bool _side;
    Quantum[] pieces;

    this(bool side, InitCallback initCallback) {
      this._side = side;

      Quantum[] temp = [];
      foreach(int dy, bool[] line; Layout) {
        foreach(int x, bool is_; line) {
          if (is_) {
            int y;
            if (side) {
              y = 9 - 1 - dy;
            } else {
              y = dy;
            }
            auto q = new Quantum(side, &this.Decide, PieceType.AllPiece, new Pos(x, y));
            temp ~= q;
            initCallback(x, y, q);
          }
        }
      }
      this.pieces = temp;
    }

    void Decide(Quantum q, PieceType[] dec) {
      //bool ret;
      auto unfixedAll = PieceType.AllPiece;
      auto pd = new QDecider!(Quantum, PieceType)(
        this.pieces,
        unfixedAll,
        (Quantum q) { return q.possibility; },
        (Quantum q, PieceType[] p) {
          q.possibility = p;
        },
        (PieceType p) { return p.countInSide; });

      pd.updateFilled();
      //return ret;
    }
  }


unittest {
	bool _reface(Quantum q) {
		auto cont = q.reface.prepare(Void._);
		bool ret = cont.can();
		if (ret) {
			cont.doit();
		}
		return ret;
	}

	// reface test
	Origin origin = new Origin(false, (a, b, c) {});
	auto pieces = origin.pieces;

	foreach(i, Quantum q; pieces) {
		if (i < pieces.length - 3) {
			assert(_reface(q), "should be able to reface");
		} else {
			assert(! _reface(q), "can't reface");
			assert(q.possibility.length == 2
					&& containsAll(q.possibility, [PieceType.kin, PieceType.ou])
					, "can't reface because ou or kin");
		}
	}
}
