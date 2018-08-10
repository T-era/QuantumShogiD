var control = new (function() {
	var hovering = null; // for mobile. A cell under hover-window.
	var selected = null;
	var selectedFromHand = false;
	var side;
	var myName;
	var rName;
	var hoverLT;
	$(function() {
		hoverLT = new hoverLikeTitle($("#hover_like_title")[0], 2);
	});

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
			setting.notify('Your turn');
		}
		board.show(side, json['board'], json['tInHand'], json['fInHand']);
		timer.callback(json['timer']);
	};
	this.errorCallback = function(errorMessage) {
		setting.error(errorMessage);
	}
	this.selectOnBoard = function(bx, by, boardCells, myHandCells, eve) {
		var temp = boardCells[by][bx];
		if (setting.interactAsPc) {
			if (hovering !== null) {
				hovering = null;
				hoverLT.off();
			}
		} else {
			// when mobile, first time is to hover.
			if (hovering == null || hovering !== temp) {
				hovering = temp;
				hoverLT.onn(eve);
				return;
			}
		}
		if (selected) {
			api.step(side,
				ss.conv(side, selected.x),
				ss.conv(side, selected.y),
				ss.conv(side, bx),
				ss.conv(side, by));
			selected.cell.removeClass('selected');
			selected = null;
			if (hovering !== null) {
				hovering = null;
				hoverLT.off();
			}
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
	this.selectInHand = function(x, y, boardCells, myHandCells, eve) {
		var temp = myHandCells[y][x];
		if (setting.interactAsPc) {
			if (hovering !== null) {
				hovering = null;
				hoverLT.off();
			}
		} else {
			// when mobile, first time is to hover.
			if (hovering == null || hovering !== temp) {
				hovering = temp;
				hoverLT.onn(eve);
				return;
			}
		}
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
	this.selectInRHand = function(x, y, boardCells, rHandCells, eve) {
		var temp = rHandCells[y][x];
		if (setting.interactAsPc) {
			if (hovering !== null) {
				hovering = null;
				hoverLT.off();
			}
		} else {
			// when mobile, first time is to hover.
			if (hovering == null || hovering !== temp) {
				hovering = temp;
				hoverLT.onn(eve);
				return;
			} else {
				hovering = null;
				hoverLT.off();
				return;
			}
		}
	}

	this.closeConnection = function() {
		timer.stop();
		api.closeConnection();
	};
})();
