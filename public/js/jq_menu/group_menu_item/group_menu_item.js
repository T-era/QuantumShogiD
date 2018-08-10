var gmi = function() {
	var defaultIndex = arguments[0];
	var choices = [].slice.call(arguments, 1);
	var headers = [];
	var selectedCallback = function() {};

	for (var i = 0, max = choices.length; i < max; i ++) {
		var item = choices[i];
		set(item);
		var header = $("<div>").addClass("ui-icon");
		item.prepend(header);
		headers.push(header);
	}

	setSelected(choices[defaultIndex]);

	return {
		setCallback: function(callback) {
			selectedCallback = callback;
		}
	};
	function set(item) {
		$(item).click(function() {
			setSelected(item);
			selectedCallback(item);
		}).addClass('group_menu_item');
	}
	function setSelected(item) {
		for (var i = 0, max = choices.length; i < max ; i ++) {
			var temp = choices[i];
			var header = headers[i];
			if (item == temp) {
				header.addClass("ui-icon-check");
				header.removeClass("ui-icon-blank");
			} else {
				header.removeClass("ui-icon-check");
				header.addClass("ui-icon-blank");
			}
		}
	}
};
