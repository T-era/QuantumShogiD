module storage.redis_client;

import vibe.vibe;
import std.format;
import std.stdio;
import std.json;

const long Expire = 30;
enum DatabaseID :long {
	User = 1,
	Waiting = 2
}

auto getDatabase(DatabaseID id) {
	auto redis = new RedisClient();
	return redis.getDatabase(id);
}

void set(DatabaseID id, string key, string value, long expire) {
	auto database = getDatabase(id);
	database.setEX(key, expire, value);
}

string get(DatabaseID id, string key) {
	return getDatabase(id).get(key);
}

bool expire(DatabaseID id, string key, long seconds) {
	return getDatabase(id).expire(key, seconds);
}
