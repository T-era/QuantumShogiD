module listeners.state.converter.board;

import vibe.vibe;

import core.gs;

Json fromBoard(Board board) {
  Json ret = Json.emptyArray;
  for (int y = 0; y < 9; y ++) {
    ret ~= [Json.emptyArray];
    for (int x = 0; x < 9; x ++) {
      ret[y] ~= [Json.emptyArray];
      if (board[y][x].length == 0) {
        ret[y][x] = Json(null);
      } else {
        Json[] l;
        foreach (str; board[y][x]) {
          if (str !is null && str.length > 0) {
            l ~= Json(str);
          }
        }
        ret[y][x] = Json(l);
      }
    }
  }
  return ret;
}
