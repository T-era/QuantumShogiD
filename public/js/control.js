var control = new (function() {
	var selected = null;
	var selectedFromHand = false;
	var side;

	this.entry = function(name, type) {
		api.entry(name, type);
	};
	this.entryCallback = function(thisSide) {
		side = thisSide;
		api.show();
	};
	this.showCallback = function(json) {
		if (json['sideOn'] === side) {
			alert('TODO Your');
		}
		var myInHand = side ? json['tInHand'] : json['fInHand'];
		var rInHand = side ? json['fInHand'] : json['tInHand'];
		board.show(side, json['board'], myInHand, rInHand);
		// TODO json['timer']
	}
})();
