
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
    thisSide = msgJson['side'];

    console.log(msgJson, thisSide, gid)

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
    } else {
      console.log(msgJson, gid)
    }
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
