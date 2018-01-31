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

	function goonQs(gid, socket, thisSide) {
		console.log("started");
		socket.onmessage = handleError(function(msgJson) {
			var cls = msgJson['class'];
			if (cls === 'reface') {
				var answer = confirm('Reface ??');
				socket.send(JSON.stringify({
					class: 'reface',
					answer: answer
				}));
			} else if (cls === 'result') {
				alert(msgJson);
			} else if (cls === 'error') {
				alert(msgJson['message']);
			} else if (cls === 'show'){
				control.showCallback(msgJson);
				console.log(msgJson, gid)
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
