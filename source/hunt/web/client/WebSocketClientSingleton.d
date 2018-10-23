module hunt.web.client.WebSocketClientSingleton;

import hunt.web.client.SimpleWebSocketClient;
import hunt.util.LifeCycle;

/**
 * 
 */
public class WebSocketClientSingleton : AbstractLifeCycle {

    private __gshared WebSocketClientSingleton ourInstance;

    shared static this() {
        ourInstance = new WebSocketClientSingleton();
    }

    public static WebSocketClientSingleton getInstance() {
        return ourInstance;
    }

    private SimpleWebSocketClient _client;

    private this() {
        start();
    }

    public SimpleWebSocketClient webSocketClient() {
        return _client;
    }

    override
    protected void initilize() {
        _client = new SimpleWebSocketClient();
    }

    override
    protected void destroy() {
        _client.stop();
    }
}
