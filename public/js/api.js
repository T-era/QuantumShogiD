var api = new (function() {
	var socket;
	var gid;
	this.initWs = function(openThen) {
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
			var gid = msgJson.gid;
			var thisSide = msgJson.side;
			var nameT = msgJson.nameT;
			var nameF = msgJson.nameF;

			control.entryCallback(thisSide, nameT, nameF);

			goonQs(gid, socket, thisSide);
		});
		socket.onopen = function() {
			mystatus.asReadyState(socket);
			openThen();
		};
	};
	this.closeConnection = function() {
		socket.close();
	}
	this.entry = function(name, type) {
		socket.send(JSON.stringify({
				class: 'entry',
				type: type,
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
	this.timer = function() {
		socket.send(JSON.stringify({
			class: 'time'
		}));
	}


	function goonQs(gid, socket, thisSide) {
		console.log("started");
		socket.onmessage = handleError(function(msgJson) {
			var cls = msgJson['class'];
			if (cls === 'you_turn') {
				api.show();
			} else if (cls === 'reface') {
				var answer = uitools.showConfirm('Reface ?',
					refaceConfirmThen(true),
					refaceConfirmThen(false));
				function refaceConfirmThen(answer) {
					return function() {
						socket.send(JSON.stringify({
							class: 'reface',
							answer: answer
						}));
					}
				}
			} else if (cls === 'time') {
				timer.callback(msgJson);
			} else if (cls === 'result') {
				uitools.showMessage(msgJson.win ? 'You win!' : 'You Lose');
			} else if (cls === 'error') {
				control.errorCallback(msgJson['message']);
			} else if (cls === 'show'){
				control.showCallback(msgJson);
			} else if (cls === 'retired') {
				uitools.showMessage(msgJson['message']);
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
