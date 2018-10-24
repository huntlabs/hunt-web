
import hunt.web.client.SimpleWebSocketClient;
import hunt.web.helper;
import hunt.http.codec.websocket.stream.WebSocketConnection;
import hunt.util.concurrent.Promise;
import hunt.util.concurrent.CompletableFuture;

import hunt.logging;

import std.conv;
import std.stdio;

void main(string[] args) {

	enum host = "127.0.0.1";
	enum port = "8080";
	
	SimpleWebSocketClient client = createWebSocketClient();
	client.webSocket("ws://" ~ host ~ ":" ~ port ~ "/helloWebSocket")
			.onText((text, conn) { writeln("The client received: " ~ text); })
			.connect()
			.thenAccept((conn) { conn.sendText("Hello server."); } );
}