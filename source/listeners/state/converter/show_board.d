module listeners.state.converter.show_board;

import vibe.vibe;

import core.gs;
import listeners.state.converter.showr_io;

Json fromBoard(Board board) {
  Json ret = Json.emptyArray;
  for (int y = 0; y < 9; y ++) {
    ret ~= [Json.emptyArray];
    for (int x = 0; x < 9; x ++) {
      ret[y] ~= [Json.emptyArray];
      ret[y][x] = fromPieceResp(board[y][x]);
    }
  }
  return ret;
}
