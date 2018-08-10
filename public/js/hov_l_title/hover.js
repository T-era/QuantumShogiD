var hoverLikeTitle = (function() {
  // Hover
  function Hover(hoverDom) {
      this._hidden = true;
      this._dom = hoverDom;
  }
  Hover.prototype._show = function(e) {
      this._dom.style.display = (this._hidden ? "none" : "block");
      if (! this._hidden) {
          var text = e.target.title || '  ';
          this._dom.innerHTML = text;
          var len = text.length;
          this._dom.style.left = e.x + "px";
          this._dom.style.top = e.y + "px";
          this._dom.style.width = len + "em";
      }
  }
  Hover.prototype.turn = function(e) {
    this._hidden = ! this._hidden;
    this._show(e);
  }
  Hover.prototype.onn = function(e) {
    this._hidden = false;
    this._show(e);
  }
  Hover.prototype.off = function() {
    this._hidden = true;
    this._show();
  }
  return Hover;
})();
