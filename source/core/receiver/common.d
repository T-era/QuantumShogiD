module core.receiver.common;

import qs.server;

struct Position {
  int x;
  int y;

  bool opEquals(Position arg) {
    return this.x == arg.x
        && this.y == arg.y;
  }
  static Position fromPos(Pos p)
  in {
    assert(p !is null, "NULL!!!");
  }
  body {
    return Position(p._x, p._y);
  }
}

Pos toPos(Position p) {
  return new Pos(p.x, p.y);
}
