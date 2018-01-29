
function initWs(baseUrl) {
  var ret = {};
  var socket = new WebSocket(baseUrl + "/qss");
  ret.socket = socket;
  socket.onclose = function() {
		console.log("Connection closed.");
	};
	socket.onerror = function() {
		console.log("Error!");
	};
  socket.onmessage = handleError(function(msgJson) {
    var gid = msgJson['gid'];
    console.log(msgJson, gid)

    goonQs(gid, socket);
  });
  socket.onopen = function() {
    console.log('Ready.')
  };

  return ret;
}

function goonQs(gid, socket) {
  console.log("started");
  socket.onmessage = handleError(function(msgJson) {
    console.log(msgJson);
  });
  socket.send(JSON.stringify({
    gid: gid,
    class: 'show'
  }))
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
