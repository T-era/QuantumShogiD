module qs.rule.quantum.decide;

import std.algorithm;
import std.range;

class QDecider(S, T) {
	T[] delegate(S a) howGetTypes;
	void delegate(S a, T[] b) howSetTypes;
	int delegate(T a) howGetTypeVolume;
	T[] typesAll;
	S[] members;

	this(S[] members, T[] types, T[] delegate(S a) getTypes, void delegate(S a, T[] b) setTypes, int delegate(T a) getTypeVolume) {
		this.members = members;
		this.typesAll = types;
		this.howGetTypes = getTypes;
		this.howSetTypes = setTypes;
		this.howGetTypeVolume = getTypeVolume;
	}

	void updateFilled() {
		auto checkTarget = this.typesAll;

		auto combination = fullCombination(checkTarget);
		foreach(T[] condition; combination) {
			S[] hitMember = [];
			foreach(S member; this.members) {
				if (containsAll(condition, this.howGetTypes(member))) {
					hitMember ~= member;
				}
			}

			auto sumVolume = condition.map!((a) { return this.howGetTypeVolume(a); }).reduce!((prev, current) {
				return prev + current;
			});
			if (hitMember.length == sumVolume) {
				// 全タイプを、関係者以外から除外
				foreach (T type; condition) {
					foreach(S member; this.members) {
						if (! contains(hitMember, member)) {
							auto newTypes = this.howGetTypes(member).dup.remove!((a) { return a is type;});
							this.howSetTypes(member, newTypes);
						}
					}
				}
			}
		}
	}
}

bool contains(T)(T[] mom, T child) {
	return mom.find(child).length > 0;
}

bool containsAll(T)(T[] mom, T[] children) {
	return children.all!((T child) {
		return mom.contains(child);
	});
}

T[][] fullCombination(T)(T[] seed) {
	T[] combination(size_t bitFlag) {
		T[] part = [];
		for (auto rank = 0; rank < seed.length; rank ++) {
			if ((bitFlag >> rank) % 2 != 0) {
				part ~= seed[rank];
			}
		}
		return part;
	}
	T[][] ret = [];
	for (auto i = 1; i < (1 << seed.length); i ++) {
		ret ~= combination(i);
	}

	return ret;
}


unittest {
	assert(fullCombination!int([1,2]).sort == [[1],[2],[1,2]].sort);
	assert(fullCombination!int([1,2,3]).sort == [[1],[2],[3],[1,2],[1,3],[2,3],[1,2,3]].sort);

	int[] l = [1,2,3];
	assert(contains(l, 2));
	assert(contains(l, 3));
	assert(! contains(l, 4));
	assert(containsAll([1,2,3], [3,2]));
	assert(containsAll([1,2,3], [3,2,1]));
	assert(! containsAll([1,2,3], [3,4]));
}

unittest {
	import qs.common.pos;
	import qs.rule.piece_type;
	import qs.rule.quantum.origin;
	import qs.rule.quantum.quantum;

	bool _moveTo(Quantum p, int dx, int dy, bool show=false) {
		auto cont = p.move.prepare(new Pos(p.pos._x + dx, p.pos._y + dy));
		auto ret = cont.can();
		if (ret) {
			cont.doit();
		}
		return ret;
	}

	{
		Origin origin = new Origin(false, (a, b, c) {});
		auto pieces = origin.pieces;
		auto pieceA = pieces[0];
		auto pieceB = pieces[1];

		assert(_moveTo(pieceA, +1, +2), "Prepare 1(move as kei) fail");
		assert(_moveTo(pieceB, +1, +2, true), "Prepare 2(move as key) fail");
		Quantum[] anotherPiece = pieces[2..$];
		bool apck = ! anotherPiece.all!((Quantum test) { return contains(test.possibility, PieceType.kei); });
		assert(apck, "Another piece can't kei");
	}
	{
		Origin origin = new Origin(false, (a, b, c) {});
		Quantum[] pieces = origin.pieces;

		int i = 0;
		assert(_moveTo(pieces[i ++], +1, +2)
				&& _moveTo(pieces[i ++], -1, +2)
				, "Prepare 1(move as kei)");
		assert(_moveTo(pieces[i ++], 0, +2)
				&& _moveTo(pieces[i ++], 0, +4)
				, "Prepare 2(move as kyo)");
		assert(_moveTo(pieces[i], 0, +1) && _moveTo(pieces[i ++], -1, -1)
				&& _moveTo(pieces[i], 0, +1) && _moveTo(pieces[i ++], +1, -1)
				&& _moveTo(pieces[i], 0, +1) && _moveTo(pieces[i ++], +1, -1)
				, "Prepare 3(move as gin or ou)");
		assert(_moveTo(pieces[i], +1, 0) && _moveTo(pieces[i ++], -1, +1)
				&& _moveTo(pieces[i], -1, 0) && _moveTo(pieces[i ++], +1, +1)
				, "Prepare 4(move as kin)");
		assert(_moveTo(pieces[i ++], -2, 0)
				, "Prepare 5(move as hi)");
		assert(_moveTo(pieces[i ++], -2, +2)
				, "Prepare 6(move as kk)");
		bool result = pieces.all!((Quantum test) {
			if ( test.possibility.length == 1
					|| (contains(test.possibility, PieceType.gin)
						&& contains(test.possibility, PieceType.ou))
			) {
				return true;
			} else {
				return false;
			}
		});
		assert(result
				, "All piece fixed (another piece will fu), or gin-ou combi");

		assert(pieces[4].reface.prepare(Void._).can()
				&& pieces[5].reface.prepare(Void._).can()
				&& pieces[6].reface.prepare(Void._).can()
				, "Gin can reface");
		pieces[4].reface.prepare(Void._).doit();
		pieces[6].reface.prepare(Void._).doit();
		assert(! pieces[5].reface.prepare(Void._).can()
				, "ou can't reface");

		assert(pieces.all!((test) {
			return test.possibility.length == 1;
		}), "All piece is fixed");
	}
}
