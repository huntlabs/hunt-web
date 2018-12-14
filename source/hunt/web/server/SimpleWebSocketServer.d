module hunt.web.server.SimpleWebSocketServer;

import hunt.web.server.HttpServerBuilder;
import hunt.web.server.SimpleHttpServerConfiguration;
import hunt.web.router.handler.HttpBodyHandler;
import hunt.util.Lifecycle;


class SimpleWebSocketServer : AbstractLifecycle {

    private HttpServerBuilder serverBuilder;

    this() {
        this(new SimpleHttpServerConfiguration());
    }

    this(SimpleHttpServerConfiguration serverConfiguration) {
        this(serverConfiguration, new HttpBodyConfiguration());
    }

    this(SimpleHttpServerConfiguration serverConfiguration,
                                 HttpBodyConfiguration httpBodyConfiguration) {
        this.serverBuilder = new HttpServerBuilder().httpServer(serverConfiguration, httpBodyConfiguration);
        start();
    }

    HttpServerBuilder.WebSocketBuilder webSocket(string path) {
        return serverBuilder.webSocket(path);
    }

    override
    protected void initialize() {

    }

    override
    protected void destroy() {
        serverBuilder.stop();
    }
}
