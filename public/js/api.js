var api = new (function() {
	var socket;
	var gid;
	this.initWs = function() {
		var baseUrl = getBaseURL();
		socket = new WebSocket(baseUrl + "/qss");
		mystatus.asReadyState(socket);

		socket.onclose = function() {
			mystatus.asReadyState(socket);
			console.log("Connection closed.");
		};
		socket.onerror = function() {
			mystatus.asReadyState(socket);
			console.log("Error!");
		};
		socket.onmessage = handleError(function(msgJson) {
			var gid = msgJson['gid'];
			var thisSide = msgJson['side'];

			console.log(msgJson, thisSide, gid)
			control.entryCallback(thisSide);

			goonQs(gid, socket, thisSide);
		});
		socket.onopen = function() {
			mystatus.asReadyState(socket);
			console.log('Ready.')
		};
	};
	this.closeConnection = function() {
		socket.close();
	}
	this.entry = function(name, type) {
		socket.send(JSON.stringify({
				class: 'entry',
				type: '1hour/1min',
				name: name
			}));
	};

	this.show = function() {
		socket.send(JSON.stringify({
			gid: gid,
			class: 'show'
		}));
	}
	this.step = function(thisSide, x1, y1, x2, y2) {
		socket.send(JSON.stringify({
			class: 'step',
			side: thisSide,
			from: {
				x: x1,
				y: y1
			},
			to: {
				x: x2,
				y: y2
			}
		}));
	};
	this.put = function(thisSide, index, x, y) {
		socket.send(JSON.stringify({
			class: 'put',
			side: thisSide,
			indexInHand: index,
			to: {
				x: x,
				y: y
			}
		}));
	};


	function goonQs(gid, socket, thisSide) {
		console.log("started");
		socket.onmessage = handleError(function(msgJson) {
			var cls = msgJson['class'];
			if (cls === 'you_turn') {
				api.show();
			} else if (cls === 'reface') {
				var answer = confirm('Reface ??');
				socket.send(JSON.stringify({
					class: 'reface',
					answer: answer
				}));
			} else if (cls === 'result') {
				alert(msgJson.win ? 'You win' : 'You Lose');
			} else if (cls === 'error') {
				alert(msgJson['message']);
			} else if (cls === 'show'){
				control.showCallback(msgJson);
			} else {
				api.show();
				console.log(msgJson);
			}
		});
	}

	function handleError(f) {
		return function(message) {
			var msgJson = JSON.parse(message.data);
			if (msgJson['error']) {
				alert(msgJson['error']);
			} else {
				return f(msgJson);
			}
		}
	}

	function getBaseURL() {
		var url = window.location.href;
		var schemeLen = url.indexOf(":");
		var href = url.substring(schemeLen + 3); // strip "http://" or "https://"
		var idx = href.indexOf("/");
		return "ws://" + href.substring(0, idx);
	}
})();
