module listeners.state.converter.inhand;

import std.algorithm;
import std.array;
import vibe.vibe;

import core.gs;

Json fromInHand(InHand inHand) {
  string[9][] temp = inHand[];
  Json ret = Json(
    temp.map!((string[] line) {
        return Json(
          line.map!((string item) {
            return Json(item);
          }).filter!((item) {
            return item.length > 0;
          }).array);
    }).filter!((item) {
      return item.length > 0;
    }).array);
  import std.stdio;
  writeln(inHand, ret);
  return ret;
}
unittest {
  import std.stdio;

  string[9][40] inHand;
  assert(fromInHand(inHand).to!string == "[]");
  inHand[0][0] = "A";
  inHand[0][1] = "B";
  inHand[0][2] = "C";
  assert(fromInHand(inHand).to!string == `[["A","B","C"]]`);
  inHand[39][0] = "a";
  inHand[39][1] = "b";
  assert(fromInHand(inHand).to!string == `[["A","B","C"],["a","b"]]`);
}
