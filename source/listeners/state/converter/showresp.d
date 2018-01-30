module listeners.state.converter.showresp;

import vibe.vibe;

import core.gs;
import listeners.state.converter.board;
import listeners.state.converter.inhand;
import listeners.state.converter.remains;


Json fromShowResp(ShowResp sr) {
  return Json([
    "sideOn": Json(sr.sideOn),
    "board": fromBoard(sr.board),
    "tInHand": fromInHand(sr.tInHand),
    "fInHand": fromInHand(sr.fInHand),
    "timer": fromRemains(sr.remains)
  ]);
}
