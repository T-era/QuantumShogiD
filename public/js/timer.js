var timer = new (function() {
  var interval = 250;
  var stopped = false;
  var side = null;
  var myView;
  var rView;
  this.init = function() {
    myView = $('#my_remain');
    rView = $('#r_remain');
  };
  this.start = function(thisSide, myName, rName) {
    side = thisSide;
    stopped = false;
    function loop() {
      if (stopped) {
        return;
      } else {
        api.timer();
        setTimeout(loop, interval);
      }
    }
    loop();
    $('#my_name').text(myName);
    $('#r_name').text(rName);
    myView.removeClass('notime');
    rView.removeClass('notime');
  };
  this.callback = showTimer
  this.stop = function() {
    stopped = true;
  }

  function showTimer(json) {
    if (json.winner !== null) {
      stopped = true;
    } else {
      var my = side ? json.timeT : json.timeF;
      var r = side ? json.timeF : json.timeT;
      myView.text(toShow(my.remain));
      rView.text(toShow(r.remain));
      if (my.notime) {
        myView.addClass('notime');
      }
      if (r.notime) {
        rView.addClass('notime');
      }
    }
  }
  function toShow(totalSec) {
    var sec = totalSec % 60;
    var totalMin = Math.floor(totalSec / 60);
    var min = totalMin % 60;
    var hour = Math.floor(totalMin / 60);
    if (hour > 0) {
      return [hour, ':', min, ':', sec].join('');
    } else {
      return [min, ':', sec].join('');
    }
  }
})();
