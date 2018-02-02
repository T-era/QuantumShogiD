module listeners.type_get;

import vibe.vibe;

import core.gs : types;

void getTypes(HTTPServerRequest req, HTTPServerResponse res) {
	Json resp = Json.emptyArray;
	foreach (key, _; types) {
		resp ~= Json(key);
	}
	res.writeBody(resp.to!string);
}
