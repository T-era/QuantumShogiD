var gmi = function() {
  var defaultIndex = arguments[0];
  var choices = [].slice.call(arguments, 1);
  var selectedCallback = function() {};

  for (var i = 0, max = choices.length; i < max; i ++) {
    var item = choices[i];
    set(item);
  }

  //setChoices(choices);
  //setSelected(defaultIndex);

  return {
    setCallback: function(callback) {
      selectedCallback = callback;
      console.log(arguments.length);
      console.log(arguments);
    }
  };
  function set(item) {
    $(item).click(function() {
      selectedCallback(item);
    });
  }
};
