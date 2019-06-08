module hunt.web.client.SecureWebSocketClientSingleton;

version(WITH_HUNT_SECURITY) :

import hunt.web.client.SimpleWebSocketClient;
import hunt.web.client.SimpleHttpClientConfiguration;
import hunt.util.Lifecycle;

import hunt.collection.Collections;

/**
 * 
 */
class SecureWebSocketClientSingleton : AbstractLifecycle {
    private __gshared SecureWebSocketClientSingleton ourInstance;

    shared static this() {
        ourInstance = new SecureWebSocketClientSingleton();
    }

    static SecureWebSocketClientSingleton getInstance() {
        return ourInstance;
    }

    private SimpleWebSocketClient webSocketClient;

    private this() {
        start();
    }

    SimpleWebSocketClient secureWebSocketClient() {
        return webSocketClient;
    }

    override
    protected void initialize() {
        SimpleHttpClientConfiguration http2Configuration = new SimpleHttpClientConfiguration();
        http2Configuration.setSecureConnectionEnabled(true);
        http2Configuration.getSecureSessionFactory().setSupportedProtocols(["http/1.1"]);
        webSocketClient = new SimpleWebSocketClient(http2Configuration);
    }

    override
    protected void destroy() {
        webSocketClient.stop();
    }
}
