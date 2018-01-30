module listeners.state.converter.inhand;

import vibe.vibe;

import core.gs;

Json fromInHand(InHand inHand) {
  Json ret = Json.emptyArray;
  foreach (hand; inHand) {
    Json[] l;
    foreach (str; hand) {
      if (str !is null && str.length > 0) {
        l ~= Json(str);
      }
    }
    if (l.length > 0) {
      ret ~= Json(l);
    }
  }
  return ret;
}
