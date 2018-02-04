var simple_show = new (function() {
  function imageName(q, mySide) {
    var sideStr = (q.side == mySide ? '_t_' : '_f_');
    if (q.possibility.length === 1) {
      var ptStr = q.possibility[0];
      if (ptStr == 'ou') ptStr += ((q.side == mySide) ^ mySide ? '2' : '1');
      return ['img/', ptStr, sideStr, q.face + 1, '.png'].join('');
    } else {
      return ['img/uk', q.possibility.length, sideStr, q.face + 1, '.png'].join('');
    }
  }
  this.show = function(jqDom, q, mySide) {
    if (q) {
      var fileName = imageName(q, mySide)
      jqDom.css({
        'background-image': 'url("' + fileName + '")',
        'background-size': 'contain',
        'background-repeat': 'no-repeat',
        'background-position': 'center'

      });
      jqDom.text(' ');
    } else {
      jqDom.css({
        'background-image': 'none'
      });
      jqDom.text('');
    }
  }
})();
