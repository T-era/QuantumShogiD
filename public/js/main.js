var main = new (function() {
	var initDialog;
  var menuStart;
	this.init = function() {
		$('#menu').menu({
			position: {
				my: 'left top',
				at: 'left bottom'
			}
		});

		initDialog = $('#init_dialog').dialog({
			autoOpen: true,
			modal: true,
			buttons: {
				'Entry': function() {
					api.entry(
						$('#input_name').val(),
						$('#select_type').val());
					menuDisconnect.removeClass('ui-state-disabled');
					menuStart.addClass('ui-state-disabled');
					initDialog.dialog('close');
				}
			}
		});
		menuStart = $('#mi_start').click(function() {
			initDialog.dialog('open');
		});
		menuDisconnect = $('#mi_disconnect').click(function() {
			api.closeConnection();

			menuDisconnect.addClass('ui-state-disabled');
			menuStart.removeClass('ui-state-disabled');
		}).addClass('ui-state-disabled');
	}
})();
