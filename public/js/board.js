var board = new (function() {
	var selectedCell;
	var boardCells = [];
	var myHandCells = [];
	var rHandCells = [];
	var hoverLT;
	$(function() {
		hoverLT = new hoverLikeTitle($("#hover_like_title")[0], 2);
	});

	function allInBoard(f, init) {
		for (var y = 0; y < 9; y ++) {
			if (init) boardCells[y] = [];
			for (var x = 0; x < 9; x ++) {
				f(x, y)
			}
		}
	}
	function allInHand(f, init) {
		for (var y = 0; y < 13; y ++) {
			if (init) myHandCells[y] = [];
			if (init) rHandCells[y] = [];
			for (var x = 0; x < 3; x ++) {
				f(x, y);
			}
		}
	}

	this.init = function() {
		var owner = $('#board');
		var myHand = $('#inHandMy');
		var rHand = $('#inHandR');
		boardCells = [];
		myHandCells = [];
		rHandCells = [];

		allInBoard(function(x, y) {
			boardCells[y][x] = $('<div>')
				.addClass('cell')
				.css({
					top: y * 11 + '%',
					left: x * 11 + '%'
				})
				.click(onclick(x, y))
				.dblclick(ondblclick(x, y))
				.appendTo(owner);
		}, true);
		allInHand(function(x, y) {
			myHandCells[y][x] = $('<div>')
				.addClass('cell')
				.css({
					top: y * 14 + '%',
					left: x * 33 + '%'
				})
				.click(onClickMy(x, y))
				.dblclick(ondblclick(x, y))
				.appendTo(myHand);
			rHandCells[y][x] = $('<div>')
				.addClass('cell')
				.css({
					top: y * 14 + '%',
					left: x * 33 + '%'
				})
				.click(onClickR(x, y))
				.dblclick(ondblclick(x, y))
				.appendTo(rHand);
		}, true);
	};

	function onclick(x, y) {
		return function(event) {
			var jqDom = boardCells[y][x];
			if (setting.interactAsPc) {
				control.selectOnBoard(x, y, boardCells, myHandCells);
			} else {
				hoverLT.turn(event.originalEvent);
				// TODO Show hint;
				console.log(event.originalEvent, jqDom.attr('title'));
			}
		};
	}
	function ondblclick(x, y) {
		return function() {
				var jqDom = boardCells[y][x];
				if (setting.interactAsPc) {
					// Do nothing
				} else {
					control.selectOnBoard(x, y, boardCells, myHandCells);
				}
		}
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

		showBoard(board, side);
		showMyHand(myInHand, side);
		showRHand(rInHand, side);
	}

	function showBoard(json, side) {
		 allInBoard(function(x, y) {
			var showX = ss.conv(side, x);
			var showY = ss.conv(side, y);
			var dom = boardCells[showY][showX];
			showCell(dom, json[y][x], side);
		});
	}
	function showMyHand(json, side) {
		allInHand(function(x, y) {
			var i = y * 3 + x;
			var dom = myHandCells[y][x];
			if (json.length > i) {
				showCell(dom, json[i], side);
			} else {
				showCell(dom, null, side);
			}
		});
	}
	function showRHand(json, side) {
		allInHand(function(x, y) {
			var i = y * 3 + x;
			var dom = rHandCells[y][x];
			if (json.length > i) {
				showCell(dom, json[i], side);
			} else {
				showCell(dom, null, side);
			}
		});
	}

	function showCell(jqDom, q, side) {
		simple_show.show(jqDom, q, side);
		if (q) {
			jqDom.attr('title', q.possibility.map(showPieceType(q.side)));
		} else {
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
