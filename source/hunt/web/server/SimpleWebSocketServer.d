module hunt.web.server.websocket.SimpleWebSocketServer;

import hunt.web.server.Http2ServerBuilder;
import hunt.web.server.SimpleHttpServerConfiguration;
import hunt.web.router.handler.HttpBodyHandler;
import hunt.util.LifeCycle;


class SimpleWebSocketServer : AbstractLifeCycle {

    private Http2ServerBuilder serverBuilder;

    this() {
        this(new SimpleHttpServerConfiguration());
    }

    this(SimpleHttpServerConfiguration serverConfiguration) {
        this(serverConfiguration, new HttpBodyConfiguration());
    }

    this(SimpleHttpServerConfiguration serverConfiguration,
                                 HttpBodyConfiguration httpBodyConfiguration) {
        this.serverBuilder = new Http2ServerBuilder().httpServer(serverConfiguration, httpBodyConfiguration);
        start();
    }

    Http2ServerBuilder.WebSocketBuilder webSocket(string path) {
        return serverBuilder.webSocket(path);
    }

    override
    protected void initilize() {

    }

    override
    protected void destroy() {
        serverBuilder.stop();
    }
}
