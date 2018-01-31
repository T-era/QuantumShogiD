var board = new (function() {
  var selectedCell;
  var cellList = [];
  this.init = function() {
    var owner = $('#board');
    cellList = [];
    for (var y = 0; y < 9; y ++) {
      cellList[y] = [];
      for (var x = 0; x < 9; x ++) {
        cellList[y][x] = $('<div>')
          .addClass('cell')
          .css({
            top: y * 11 + '%',
            left: x * 11 + '%'
          })
          .click(onclick(x, y))
          .appendTo(owner);
      }
    }
  };

  function onclick(x, y) {
    return function() {
      alert(x + ',' + y + ':' + this);
    };
  }

  this.show = function(side, json) {
    // TODO side 次第で反転させたい
    for (var y = 0; y < 9; y ++) {
      for (var x = 0; x < 9; x ++) {
        var showX = side ? 8 - x : x;
        var showY = side ? 8 - y : y;
        if (json[y][x]) {
          cellList[showY][showX].text(json[y][x]);
        } else {
          cellList[showY][showX].text('');
        }
      }
    }
  }
})();
