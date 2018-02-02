var uitools = new (function() {
  this.init = function() {
    this.showMessage = (function() {
      var callbackThen;
      var messageDialog = $('#message_dialog')
        .dialog({
          autoOpen: false,
          modal: true,
          closeOnEscape: false,
          buttons: {
            'OK': function() {
              messageDialog.dialog('close');
              callbackThen();
            }
          }
        });
      $("#message_dialog").parent().find('.ui-dialog-titlebar-close').hide();
      var messageOutput = $('#message_output')
      return function (message, then) {
        messageOutput.text(message);
        messageDialog.dialog('open');
        callbackThen = then || function() {};
      }
    })();
    this.showConfirm = (function() {
      var callbackThen;
      var callbackElse;
      var dialog = $('#confirm_dialog')
        .dialog({
          autoOpen: false,
          modal: true,
          closeOnEscape: false,
          buttons: {
            'YES': function() {
              dialog.dialog('close');
              callbackThen();
            },
            'NO': function() {
              dialog.dialog('close');
              callbackElse();
            }
          }
        });
      $("#confirm_dialog").parent().find('.ui-dialog-titlebar-close').hide();
      var messageOut = $('#confirm_output')
      return function (message, thenF, elseF) {
        messageOut.text(message);
        dialog.dialog('open');
        callbackThen = thenF || function() {};
        callbackElse = elseF || function() {};
      }
    })();
  }.bind(this);
})();
