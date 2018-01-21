
import vibe.vibe;
import std.stdio;
import std.format;

import listeners.alive;
import listeners.wrapper;
import listeners.init_listener;
import storage.on_memory;
import indigoprint;

const PORT = 8080;

void main() {
	auto settings = new HTTPServerSettings;
	settings.port = PORT;

	auto router = new URLRouter;
	router.get("/", &alive);
	router.get("/static/*", serveStaticFiles("./public/"));

	auto initRouter = new IndigoPrint(router, "/init");
	auto waiting = new WaitingEntry();
	scope(exit) waiting.stopAll();
	initRouter.post("/register", jsonWraps(&registerUser));
	initRouter.post("/matching", jsonWraps(initMatching(waiting)));


	router.get("/ws", handleWebSockets(&handleWebSocketConnection));

	listenHTTP(settings, router);

	logInfo(format("Please open http://127.0.0.1:%d/ in your browser.", PORT));
	runApplication();
}

void handleWebSocketConnection(scope WebSocket socket) {
	int counter = 0;
	writeln("Got new web socket connection.");
	for (;socket.connected; sleep(1.seconds)) {
		writeln(format("Sending '%s'.", counter ++));
		socket.send(counter.to!string);

		if (socket.waitForData(0.seconds)) {
			writeln(socket.receiveText());
			counter += 10;
		}
	}
	writeln("Client disconnected.");
}
