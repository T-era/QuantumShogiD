module qs.rule.actions.action;

public import qs.rule.actions.move;
public import qs.rule.actions.puton;
public import qs.rule.actions.reface;

interface Action(T) {
	ActionCont prepare(T arg);
}
interface ActionCont {
	static ActionCont FalseCont;

	static this() {
		FalseCont = new _FalseCont();
	}

	bool can();
	void doit();
}
private class _FalseCont : ActionCont {
	bool can() { return false; }
	void doit() { throw new Exception("Illegal call"); }
}
