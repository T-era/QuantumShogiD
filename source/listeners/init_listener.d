module listeners.init_listener;

import jsonify;
import std.uuid;
import vibe.vibe;

import std.stdio;

import storage.redis_client;
import storage.on_memory;
import listeners.wrapper;

auto registerUser(Json userInfo) {
	string name = userInfo["name"].to!string;
	string uuid = randomUUID().toString;
	string infoJson = jsonify.jsonify([
		"name": name
	]);
	storage.redis_client.set(DatabaseID.User, uuid, infoJson, storage.redis_client.Expire);
	return new JsonResp!(string[string])(200, ["id": uuid]);
}

auto initMatching(WaitingEntry waiting) {
	return (Json req) {
		writeln(req);
		string type = req["type"].to!string;
		string id = req["id"].to!string;

		bool received = false;
		string gid = null;
		waiting.entry(type, id);
		receiveTimeout(15.seconds,
			(Pair pair) {
				received = true;
				gid = pair.gid;
			});
		if (received) {
			return new JsonResp!(string[string])(200, ["gid": gid]);
		} else {
			return new JsonResp!(string[string])(404, ["error": "noone wait for."]);
		}
	};
}
