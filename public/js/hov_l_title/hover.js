var hoverLikeTitle = (function() {
  // Hover
  function Hover(hoverDom, extinctionSec) {
      this._extinctionMsec = extinctionSec * 1000;
      this._hidden = true;
      console.log("HHH", hoverDom.style);
      this._dom = hoverDom;
  }
  Hover.prototype._show = function(e) {
      this._dom.style.display = (this._hidden ? "none" : "block");
      var now = new Date();
      if (! this._hidden) {
          console.log(e.x);
          this._currentShow = now;
          var text = e.target.title;
          this._dom.innerHTML = text;
          var len = text.length;
          this._dom.style.left = e.x + "px";
          this._dom.style.top = e.y + "px";
          this._dom.style.width = len + "em";
          setTimeout(this.off.bind(this, now), this._extinctionMsec);
      }
  }
  Hover.prototype.turn = function(e) {
      this._hidden = ! this._hidden;
      this._show(e);
  }
  Hover.prototype.off = function(arg) {
      if (this._currentShow == arg) {
          this._hidden = true;
          this._show();
      }
  }
  return Hover;
})();
