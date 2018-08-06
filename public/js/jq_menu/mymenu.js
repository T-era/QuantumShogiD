;(function() {
  if ($.prototype.myMenu) {
    console.log('Duplicated decralation "myMenu"');
  } else {
    $.prototype.myMenu = myMenu;
  }

  function myMenu() {
    this.addClass('mymenu');
    this.menu();
  }
})();
