module listeners.wrapper;

import vibe.vibe;
import storage.redis_client;
import jsonify;

auto wraps(T)(T f, string[] keys) {
	return (HTTPServerRequest req, HTTPServerResponse res) {
		string[] arg;
		foreach (key; keys) {
			arg ~= req.params[key];
		}
		auto resp = f(arg);
		res.writeBody(resp);
	};
}

class JsonResp(T) {
	int status;
	T responseBody;

	this(int status, T body) {
		this.status = status;
		this.responseBody = body;
	}
}
auto jsonWraps(T)(T f) {
	return (HTTPServerRequest req, HTTPServerResponse res) {
		Json arg = req.json;
		auto resp = f(arg);

		res.writeBody(jsonify.jsonify(resp.responseBody), resp.status);
	};
}
