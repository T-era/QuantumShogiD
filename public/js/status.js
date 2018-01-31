var mystatus = new (function() {
  var statusShow;
  this.init = function() {
    statusShow = $('#status_show');
  };
  this.asReadyState = function(socket) {
    if (socket.readyState == socket.CONNECTING) {
      statusShow.text('-');
    } else if (socket.readyState == socket.OPEN) {
      statusShow.text('=');
    } else if (socket.readyState == socket.CLOSED) {
      statusShow.text('X');
    } else {
      statusShow.text('?');
    }
    return socket.readyState;
  };
})();
