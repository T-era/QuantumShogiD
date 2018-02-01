var board = new (function() {
	var selectedCell;
	var boardCells = [];
	var myHandCells = [];
	var rHandCells = [];
	this.init = function() {
		var owner = $('#board');
		var myHand = $('#inHandMy');
		var rHand = $('#inHandR');
		boardCells = [];
		myHandCells = [];
		rHandCells = [];
		for (var y = 0; y < 9; y ++) {
			boardCells[y] = [];
			for (var x = 0; x < 9; x ++) {
				boardCells[y][x] = $('<div>')
					.addClass('cell')
					.css({
						top: y * 11 + '%',
						left: x * 11 + '%'
					})
					.click(onclick(x, y))
					.appendTo(owner);
			}
		}
		for (var y = 0; y < 13; y ++) {
			myHandCells[y] = [];
			rHandCells[y] = [];
			for (var x = 0; x < 3; x ++) {
				myHandCells[y][x] = $('<div>')
					.addClass('cell')
					.css({
						top: y * 14 + '%',
						left: x * 33 + '%'
					})
					.click(onClickMy(x, y))
					.appendTo(myHand);
				rHandCells[y][x] = $('<div>')
					.addClass('cell')
					.css({
						top: y * 14 + '%',
						left: x * 33 + '%'
					})
					.click(onClickR(x, y))
					.appendTo(rHand);
			}
		}
	};

	function onclick(x, y) {
		return function() {
			var jqDom = boardCells[y][x];
			control.selectOnBoard(x, y, boardCells, myHandCells);
		};
	}
	function onClickMy(x, y) {
		return function() {
			control.selectInHand(x, y, boardCells, myHandCells);
		}
	}
	function onClickR(x, y) {
		return function() {}
	}

	this.show = function(side, board, tInHand, fInHand) {
		var myInHand = side ? tInHand : fInHand;
		var rInHand = side ? fInHand : tInHand;

		showBoard(side, board);
		showMyHand(myInHand);
		showRHand(rInHand);
	}

	function showBoard(side, json) {
		for (var y = 0; y < 9; y ++) {
			for (var x = 0; x < 9; x ++) {
				var showX = ss.conv(side, x);
				var showY = ss.conv(side, y);
				var dom = boardCells[showY][showX];
				showCell(dom, json[y][x]);
			}
		}
	}
	function showMyHand(json) {
		for (var y = 0; y < 13; y ++) {
			for (var x = 0; x < 3; x ++) {
				var i = y * 3 + x;
				var dom = myHandCells[y][x];
				if (json.length > i) {
					showCell(dom, json[i]);
				} else {
					showCell(dom, null);
				}
			}
		}
	}
	function showRHand(json) {
		for (var y = 0; y < 13; y ++) {
			for (var x = 0; x < 3; x ++) {
				var i = y * 3 + x;
				var dom = rHandCells[y][x];
				if (json.length > i) {
					showCell(dom, json[i]);
				} else {
					showCell(dom, null);
				}
			}
		}
	}

	function showCell(jqDom, q) {
		if (q) {
			// TODO
			jqDom.text(q.possibility.length);
			jqDom.attr('title', q.possibility.map(showPieceType(q.side)));
		} else {
			jqDom.text('');
      jqDom.attr('title', null);
		}
	}
  var ptMapping = {
    fu: '歩',
    kyo: '香',
    kei: '桂',
    gin: '銀',
    kin: '金',
    ou: ['王', '玉'],
    kk: '角',
    hi: '飛',
  }
	function showPieceType(side) {
    return function(str) {
			var temp = ptMapping[str];
      if (temp.length == 2) {
        return temp[side ? 0 : 1];
      }
      return temp;
		}
	}
})();
