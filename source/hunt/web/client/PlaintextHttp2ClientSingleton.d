module hunt.web.client.PlaintextHttp2ClientSingleton;

import hunt.web.client.SimpleHttpClient;
import hunt.web.client.SimpleHttpClientConfiguration;

import hunt.http.codec.http.model.HttpVersion;
// import hunt.http.utils.lang.AbstractLifecycle;

/**
 * 
 */
class PlaintextHttp2ClientSingleton { // : AbstractLifecycle 

    private __gshared PlaintextHttp2ClientSingleton ourInstance; //  = new PlaintextHttp2ClientSingleton();

    shared static this()
    {
        ourInstance = new PlaintextHttp2ClientSingleton();
    }

    static PlaintextHttp2ClientSingleton getInstance() {
        return ourInstance;
    }

    private SimpleHttpClient _httpClient;

    private this() {
        // start();
    }

    SimpleHttpClient httpClient() {
        return _httpClient;
    }

    protected void init() {
        SimpleHttpClientConfiguration configuration = new SimpleHttpClientConfiguration();
        configuration.setProtocol(HttpVersion.HTTP_2.asString());
        _httpClient = new SimpleHttpClient(configuration);
    }

    protected void destroy() {
        if (_httpClient !is null) {
            // _httpClient.stop();
            _httpClient = null;
        }
    }
}
