
import hunt.web.helper;
import hunt.web.server.SimpleHttpServer;
import hunt.web.server.SimpleWebSocketServer;

import hunt.container;
import hunt.string;

import hunt.logging;

import std.conv;
import std.datetime;
import std.stdio;


void main(string[] args)
{
    SimpleWebSocketServer server = createWebSocketServer();
    server.webSocket("/helloWebSocket")
            .onConnect( (conn) {conn.sendText("OK."); })
            .onText((text, conn) { 
                writeln("The server received: " ~ text);
                conn.sendText(Clock.currTime.toString() ~ ": " ~ text); 
            })
            .listen("0.0.0.0", 8080);

    // httpServer()
    // // .router().get("/static/*").handler(new StaticFileHandler(path.toAbsolutePath().toString()))
    // // .router().get("/").handler(ctx -> ctx.renderTemplate("template/websocket/index.mustache"))
    // .webSocket("/helloWebSocket")
    // .onConnect((conn) {
    //     conn.sendText("Current time: " ~ Clock.currTime.toString());
    // })
    // .onText((text, conn) { 
    //     writeln("The server received: " ~ text); 
    //     conn.sendText(Clock.currTime.toString() ~ ": " ~ text);
    // })
    // .listen("0.0.0.0", 8080);
}
