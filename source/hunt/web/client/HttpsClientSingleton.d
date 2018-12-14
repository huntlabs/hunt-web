module hunt.web.client.HttpsClientSingleton;

import hunt.web.client.SimpleHttpClient;
import hunt.web.client.SimpleHttpClientConfiguration;

// import hunt.http.utils.lang.AbstractLifecycle;

/**
 * 
 */
class HttpsClientSingleton { // : AbstractLifecycle 
    private __gshared HttpsClientSingleton ourInstance; // = new HttpsClientSingleton();

    shared static this()
    {
        ourInstance = new HttpsClientSingleton();        
    }

    static HttpsClientSingleton getInstance() {
        return ourInstance;
    }

    private SimpleHttpClient httpClient;

    private this() {
        // start();
    }

    SimpleHttpClient httpsClient() {
        return httpClient;
    }

    // override
    protected void init() {
        SimpleHttpClientConfiguration configuration = new SimpleHttpClientConfiguration();
        configuration.setSecureConnectionEnabled(true);
        httpClient = new SimpleHttpClient(configuration);
    }

    // override
    protected void destroy() {
        if (httpClient !is null) {
            // httpClient.stop();
            httpClient = null;
        }
    }
}
