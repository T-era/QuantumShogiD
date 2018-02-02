module qs.rule.piece_type;

import std.algorithm;
import std.math;
import std.algorithm.searching;

class PieceType {
	static PieceType fu;
	static PieceType kyo;
	static PieceType kei;
	static PieceType gin;
	static PieceType kin;
	static PieceType hi;
	static PieceType kk;
	static PieceType ou;
	static PieceType[] AllPiece;

	static this() {
		auto kinMove = [new Movation(MoveDirection.Forward, 1)
			, new Movation(MoveDirection.SideFront, 1)
			, new Movation(MoveDirection.Side, 1)
			, new Movation(MoveDirection.Backward, 1)];
		fu = new PieceType(9, [
			[new Movation(MoveDirection.Forward, 1)],
			kinMove], "fu");
		PieceType.kyo = new PieceType(2, [
			[new Movation(MoveDirection.Forward, 2)],
			kinMove], "kyo");
		PieceType.kei = new PieceType(2, [
			[new Movation(MoveDirection.KeiSpecial, 1)],
			kinMove], "kei");
		PieceType.gin = new PieceType(2, [
			[new Movation(MoveDirection.Forward, 1), new Movation(MoveDirection.SideFront, 1), new Movation(MoveDirection.SideBack, 1)],
			kinMove], "gin");
		PieceType.kin = new PieceType(2, [kinMove], "kin");
		PieceType.hi = new PieceType(1, [
			[new Movation(MoveDirection.Forward, 2)
				, new Movation(MoveDirection.Side, 2)
				, new Movation(MoveDirection.Backward, 2)],
			[new Movation(MoveDirection.Forward, 2)
				, new Movation(MoveDirection.Side, 2)
				, new Movation(MoveDirection.Backward, 2)
				, new Movation(MoveDirection.SideFront, 1)
				, new Movation(MoveDirection.SideBack, 1)]], "hi");
		PieceType.kk = new PieceType(1, [
			[new Movation(MoveDirection.SideFront, 2)
				, new Movation(MoveDirection.SideBack, 2)],
			[new Movation(MoveDirection.SideFront, 2)
				, new Movation(MoveDirection.SideBack, 2)
				, new Movation(MoveDirection.Forward, 1)
				, new Movation(MoveDirection.Side, 1)
				, new Movation(MoveDirection.Backward, 1)]], "kk");
		PieceType.ou = new PieceType(1, [[new Movation(MoveDirection.Forward, 1)
			, new Movation(MoveDirection.SideFront, 1), new Movation(MoveDirection.Side, 1)
			, new Movation(MoveDirection.SideBack, 1), new Movation(MoveDirection.Backward, 1)]], "ou");

		AllPiece = [fu, kyo, kei, gin, kin, hi, kk, ou];
	}


	Movation[][] movation;
	int countInSide;
	string _name;

	private this(int count, Movation[][] mov, string name) {
		this.movation = mov;
		this.countInSide = count;
		this._name = name;
	}

	bool canMoveTo(int face, int dx, int dy) {
		return any!((a) => a.isMatch(dx, dy))(this.movation[face]);
	}
	override string toString() {
		return _name;
	}
}
enum MoveDirection {
	NULL, Forward, Side, Backward, SideFront, SideBack, KeiSpecial
}
class Movation {
	MoveDirection direction;
	// 1: 固定1, 2: 無制限
	int size;

	this(MoveDirection direction, int size) {
		this.direction = direction;
		this.size = size;
	}

	bool isMatch(int dx, int dy) {
		MoveDirection direction() {
			if (dy == 2 && (dx == 1 || dx == -1)) {
				return MoveDirection.KeiSpecial;
			} else if (dx == 0) {
				return dy > 0 ? MoveDirection.Forward :
							dy < 0 ? MoveDirection.Backward :
							MoveDirection.NULL;
			} else if (dy == 0) {
				return dx != 0 ? MoveDirection.Side :
							MoveDirection.NULL;
			} else if (abs(dx) == abs(dy)) {
				return dy > 0 ? MoveDirection.SideFront :
					dy < 0 ? MoveDirection.SideBack :
					MoveDirection.NULL;
			}
			return MoveDirection.NULL;
		}

		auto dir = direction();
		if (dir is MoveDirection.NULL) {
			return false;
		} else if (dir == MoveDirection.KeiSpecial) {
			return this.direction == MoveDirection.KeiSpecial;
		} else if (dir == this.direction){
			if (abs(dx) <= 1 && abs(dy) <= 1) {
				return true;
			} else {
				return this.size == 2;
			}
		}
		return false;
	}
}
