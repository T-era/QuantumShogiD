module qs.timer;

import std.datetime;

alias void delegate(bool side, bool reslut) TimeoutCallback;

enum Side {
	None, True, False
}

struct RemainsEach {
	bool notime;
	Duration remain;
}
struct Remains {
	Side winner;
	RemainsEach timeT;
	RemainsEach timeF;
}

interface Timer {
	void addCallback(TimeoutCallback callback);
	void start();
	void switchOff();
	void switchOn();
	Remains showRemains();
}
/// loadTime :min.
Timer newTimer(int minTime, int loadTime) {
	return new TimerImpl(minTime, loadTime);
}
private class SideTimer {
	bool side;
	Duration minTime;
	Duration rest;
	bool noRest;
	SysTime workOn;
	bool isWork;
	TimeoutCallback[] callbackList;

	this(bool side, Duration minTime, Duration loadTime) {
		this.side = side;
		this.minTime = minTime;
		this.rest = loadTime;
		this.isWork = false;
		this.noRest = false;
		this.callbackList = [];
	}

	Duration _duration() {
		auto duration = Clock.currTime() - this.workOn;
		return duration;
	}
	void switchOff() {
		Duration duration = this._duration();
		this.isWork = false;
		if (this.noRest) {
			if (this.minTime < duration) {
				foreach(callback; this.callbackList) {
					callback(this.side, true);
				}
			}
		} else {
			this.rest -= duration;
			if (this.rest < 0.msecs) {
				foreach (callback; this.callbackList) {
					callback(this.side, true);
				}
				return;
			} else if (this.rest <= this.minTime) {
				foreach (callback; this.callbackList) {
					callback(this.side, false);
				}
				this.noRest = true;
			}
		}
	}
	void switchOn() {
		this.isWork = true;
		this.workOn = Clock.currTime();
	}

	RemainsEach showRemains() {
		Duration currentMax = this.noRest ? this.minTime : this.rest;
		Duration d = this.isWork ? (currentMax - this._duration()) : currentMax;

		return RemainsEach(this.noRest, d);
	}
}

private class TimerImpl : Timer {
	Side winner;
	Side sideOn;
	SideTimer timerT;
	SideTimer timerF;

	this(int minTime, int loadTime) {
		Duration minTimeDur = minTime.seconds;
		Duration loadTimeDur = loadTime.seconds;
		this.timerT = new SideTimer(true, minTimeDur, loadTimeDur);
		this.timerF = new SideTimer(false, minTimeDur, loadTimeDur);
		this.timerT.callbackList ~= &_listenFinished;
		this.timerF.callbackList ~= &_listenFinished;
		this.winner = Side.None;
		this.sideOn = Side.None;
	}

	void _listenFinished(bool side, bool result) {
		if (result) {
			this.sideOn = Side.None;
			this.winner = side ? Side.False : Side.True;
		}
	}

	void addCallback(TimeoutCallback callback) {
		this.timerT.callbackList ~= callback;
		this.timerF.callbackList ~= callback;
	}

	void start() {
		this.sideOn = Side.True;
		this.timerT.switchOn();
	}

	void switchOff() {
		if (this.sideOn is Side.True) {
			this.sideOn = Side.False;
			this.timerT.switchOff();
		} else if (this.sideOn is Side.False) {
			this.sideOn = Side.True;
			this.timerF.switchOff();
		} else {
			// 'Not running';
		}
	}
	void switchOn() {
		if (this.sideOn is Side.True) {
			this.timerT.switchOn();
		} else if (this.sideOn is Side.False) {
			this.timerF.switchOn();
		} else {
			// 'Not running';
		}
	}

	Remains showRemains() {
		return Remains(
			this.winner,
			this.timerT.showRemains(),
			this.timerF.showRemains());
	}
}
