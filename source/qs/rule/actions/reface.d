module qs.rule.actions.reface;

import std.algorithm;
import std.algorithm.searching;

import qs.common.pos;
import qs.rule.actions.action;
import qs.rule.quantum.quantum;
import qs.rule.piece_type;

class Reface : Action!Void {
  Quantum quantum;

  this(Quantum quantum) {
    this.quantum = quantum;
  }
  RefaceCont prepare(Void _) {
    return new RefaceCont(this.quantum);
  }
}
class RefaceCont : ActionCont {
  Quantum quantum;

  this(Quantum quantum) {
    this.quantum = quantum;
  }

  bool can() {
    auto q = this.quantum;
    return q.possibility.find!((PieceType poss) {
      return poss.movation.length > q.face + 1;
    }).length > 0;
  }
  void doit() {
    if (! this.can()) throw new Exception("Illegal call");

    PieceType[] canRefacePossibility = [];
    PieceType[] removingPossibility = [];
    auto q = this.quantum;
    foreach (PieceType poss; q.possibility) {
      if (poss.movation.length > q.face + 1) {
        canRefacePossibility ~= poss;
      } else {
        removingPossibility ~= poss;
      }
    }

    if (canRefacePossibility.length > 0) {
      q.face ++;
      q.possibility = canRefacePossibility;

      // refaceできないpossibilityは消滅する
      if (removingPossibility.length > 0) {
        q._listener(q, removingPossibility);
      }
    } else {
      throw new Exception("???");
    }
  }
}
