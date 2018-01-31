module qs.pos;

class Pos {
	int _x;
	int _y;

	this(int x, int y) {
		this._x = x;
		this._y = y;
	}

	override bool opEquals(Object o) {
		Pos pos = cast(Pos)o;
		return this.equals(pos);
	}
	bool equals(Pos arg) {
		if (arg is null) return false;
		return (this._x == arg._x
				&& this._y == arg._y);
	}
}

unittest {
	Pos a = new Pos(13, 17);
	Pos b = new Pos(13, 17);
	Pos c = new Pos(13, 16);
	assert(a == a);
	assert(a == b);
	assert(a != c);
}
