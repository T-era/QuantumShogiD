;(function() {
  if ($.prototype.myMenu) {
    console.log('Duplicated decralation "myMenu"');
  } else {
    $.prototype.myMenu = myMenu;
  }

  function myMenu() {
    console.log(this);
    this.hide();
  }
})();
