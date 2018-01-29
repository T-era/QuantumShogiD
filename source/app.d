
import vibe.vibe;
import std.stdio;
import std.format;

import core.matching;
import listeners.alive;
import listeners.qss;

const PORT = 8080;

void main() {
	auto settings = new HTTPServerSettings;
	settings.port = PORT;

	auto router = new URLRouter;
	router.get("/", &alive);
	router.get("/static/*", serveStaticFiles("./public/"));

	auto waiting = new Matcher();
	scope(exit) waiting.stopAll();
	router.get("/qss", handleWebSockets(qssListener(waiting)));

	listenHTTP(settings, router);

	logInfo(format("Please open http://127.0.0.1:%d/ in your browser.", PORT));
	runApplication();
	logInfo("Shutting down...");
}
