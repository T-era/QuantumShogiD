module jsonify;

import std.stdio;
import std.json;
import std.range.primitives;

string jsonify(T)(T obj) {
	JSONValue jsonVal(T1)(T1 obj1) {
		static if (
				is(T1 : string)
		 || is(T1 : long)
		 || is(T1 : ulong)
		 || is(T1 : double)
		 ) {
			return obj1.JSONValue;
		} else static if (isInputRange!T1) {
			JSONValue[] l = [];
			foreach (item; obj1) {
				l ~= jsonVal(item);
			}
			return l.JSONValue;
		} else {
			JSONValue jv;
			foreach (key, val; obj1) {
				jv[key] = jsonVal(val);
			}
			return jv;
		}
	}
	JSONValue jvl = jsonVal!(T)(obj);
	return jvl.toJSON();
}

unittest {
	// primitive values.
	JSONValue a = "A";
	assert(jsonify("A") == toJSON(a));

	JSONValue n = 123;
	assert(jsonify(123) == toJSON(n));

	JSONValue d = 123.45;
	assert(jsonify(123.45) == toJSON(d));

	JSONValue b = true;
	assert(jsonify(true) == toJSON(b));

	JSONValue l = null;
	assert(jsonify(null) == toJSON(l));
}
unittest {
	// complexed types
	JSONValue jvl = ["A": [["B1":"C1"].JSONValue, ["B2":"C2"].JSONValue]];
	assert(jsonify(["A": [["B1":"C1"], ["B2":"C2"]]]) == toJSON(jvl));
}
