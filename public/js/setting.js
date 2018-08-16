var setting = {
	init: function() {
		var intrPc = $('#mi_intr_mouse');
		var intrTp = $('#mi_intr_touch');
		this.interactAsPc = true;
		var intrDefault = isMobile() ? 1 : 0;
		gmi(intrDefault, intrPc, intrTp)
			.setCallback(function(selected) {
				this.interactAsPc = (selected == intrPc);
			}.bind(this));

		var sounds = initSound();
		var mnDialog = $('#mi_notify_dialog');
		var mnSound = $('#mi_notify_sound');
		var mnConsole = $('#mi_notify_console');

		var howNotify;
		gmi(0, mnDialog, mnSound, mnConsole)
			.setCallback(function(selected) {
				if (selected == mnConsole) {
					setting.notify = console.log;
				} else if (selected == mnSound) {
					sounds.notify();
					setting.notify = sounds.notify;
				} else {
					setting.notify = uitools.showMessage;
				}
			});

		var meDialog = $('#mi_error_dialog');
		var meSound = $('#mi_error_sound');
		var meConsole = $('#mi_error_console');
		gmi(0, meDialog, meSound, meConsole)
			.setCallback(function(selected) {
				if (selected == meConsole) {
					setting.error = console.log;
				} else if (selected == meSound) {
					sounds.error();
					setting.error = sounds.error;
				} else {
					setting.error = uitools.showMessage;
				}
			});

		if (! sounds) {
			mnSound.addClass('ui-state-disabled');
			meSound.addClass('ui-state-disabled');
		}
		setting.notify = uitools.showMessage;
		setting.error = uitools.showMessage;

		function initSound() {
			var AudioContext = window.AudioContext || window.webkitAudioContext;
			if (! AudioContext) {
				return null;
			}
			var that = {};
			var context = new AudioContext();

			// 2の12乗根: 音階一つ分
			var d = Math.pow(2, 1/12.0);

			var soundLen = 0.3;
			var rate = .000001 * context.sampleRate;
			var frameCount = context.sampleRate * soundLen;
			//
			var notbuffer = context.createBuffer(2, frameCount, context.sampleRate);
			var errbuffer = context.createBuffer(2, frameCount, context.sampleRate);
			var nb = notbuffer.getChannelData(0);
			var eb = errbuffer.getChannelData(0);

			for (var i = 0; i < frameCount; i ++) {
				var a = rate * Math.pow(d, 1);
				var b = rate * Math.pow(d, 5);
				var c = rate * Math.pow(d, 8);
				if (i < frameCount / 3) {
					nb[i] = Math.cos(i * a);
					eb[i] = Math.round(Math.cos(i * a));
				} else if (i < frameCount * 2 / 3) {
					nb[i] = Math.cos(i * b);
				} else {
					nb[i] = Math.cos(i * c);
					eb[i] = Math.round(Math.cos(i * a));
				}
			}
			that.notify = play(notbuffer);
			that.error = play(errbuffer);

			function play(buffer) {
				return function() {
					var source = context.createBufferSource();
					source.buffer = buffer;
					source.connect(context.destination);
					source.start();
				}
			}
			return that;
		}
		function isMobile() {
			var ua = navigator.userAgent;
			return ua
				&& (ua.indexOf('iPhone') > 0
				|| ua.indexOf('iPad') > 0
				|| ua.indexOf('Android') > 0);
		}
	}
};
