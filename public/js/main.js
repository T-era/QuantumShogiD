var main = new (function() {
	this.init = function() {
		var initDialog;

		$('#menu').myMenu();
		$.getJSON('/types',
			function(l) {
				l.forEach(function(item) {
					$('#select_type').append(
						$('<option>', { value: item }).text(item)
					);
				});
			});

		initDialog = $('#init_dialog').dialog({
			autoOpen: true,
			modal: true,
			buttons: {
				'Entry': function() {
					control.entry(
						$('#input_name').val(),
						$('#select_type').val());
					menuDisconnect.removeClass('ui-state-disabled');
					menuStart.addClass('ui-state-disabled');
					initDialog.dialog('close');
				}
			}
		});
		var menuStart = $('#mi_start').click(function() {
			initDialog.dialog('open');
		});
		var menuDisconnect = $('#mi_disconnect').click(function() {
			control.closeConnection();

			menuDisconnect.addClass('ui-state-disabled');
			menuStart.removeClass('ui-state-disabled');
		}).addClass('ui-state-disabled');
	}
})();
