var control = new (function() {
	var selected = null;
	var selectedFromHand = false;
	var side;
	var myName;
	var rName;

	this.entry = function(name, type) {
		api.initWs(function() {
			api.entry(name, type);
		});
	};
	this.entryCallback = function(thisSide, nameT, nameF) {
		side = thisSide;
		myName = side ? nameT : nameF;
		rName = side ? nameF : nameT;
		api.show();
		timer.start(side, myName, rName);
	};
	this.showCallback = function(json) {
		if (json['sideOn'] === side) {
			uitools.showMessage('Your turn');
		}
		board.show(side, json['board'], json['tInHand'], json['fInHand']);
		// TODO json['timer']
	};
	this.selectOnBoard = function(bx, by, boardCells, myHandCells) {
		if (selected) {
			api.step(side,
				ss.conv(side, selected.x),
				ss.conv(side, selected.y),
				ss.conv(side, bx),
				ss.conv(side, by));
			selected.cell.removeClass('selected');
			selected = null;
		} else if (selectedFromHand && ! boardCells[by][bx].text()) {
			api.put(side,
				selectedFromHand.index,
				ss.conv(side, bx),
				ss.conv(side, by));
			selectedFromHand.cell.removeClass('selected');
			selectedFromHand = null;
		} else {
			if (selectedFromHand) {
				selectedFromHand.cell.removeClass('selected');
				selectedFromHand = null;
			}
			var cell = boardCells[by][bx];
			if (cell.text()) {
				selected = {
					x: bx,
					y: by,
					cell: cell
				};
				cell.addClass('selected');
			}
		}
	}
	this.selectInHand = function(x, y, boardCells, myHandCells) {
		if (selected) {
			selected.cell.removeClass('selected');
			selected = null;
		}
		if (selectedFromHand) {
			selectedFromHand.cell.removeClass('selected');
		}
		var cell = myHandCells[y][x];
		if (cell.text()) {
			selectedFromHand = {
				index: y * 3 + x,
				cell: cell
			};
			cell.addClass('selected');
		}
	}

	this.closeConnection = function() {
		timer.stop();  // TODO ここだけ？
		api.closeConnection();
	};
})();
