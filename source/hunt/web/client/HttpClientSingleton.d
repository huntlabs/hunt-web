module hunt.web.client.HttpClientSingleton;

import hunt.web.client.SimpleHttpClient;

// import hunt.http.utils.lang.AbstractLifecycle;

/**
 * 
 */
class HttpClientSingleton  { // : AbstractLifecycle

    private __gshared HttpClientSingleton ourInstance; // = new HttpClientSingleton();

    shared static this()
    {
        ourInstance = new HttpClientSingleton();
    }

    static HttpClientSingleton getInstance() {
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
        _httpClient = new SimpleHttpClient();
    }

    protected void destroy() {
        if (_httpClient !is null) {
            // _httpClient.stop();
            _httpClient = null;
        }
    }
}
