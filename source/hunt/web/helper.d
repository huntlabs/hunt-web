module hunt.web.helper;

import hunt.web.client.SecureWebSocketClientSingleton;
import hunt.web.client.SimpleHttpClient;
import hunt.web.client.SimpleHttpClientConfiguration;
import hunt.web.client.SimpleResponse;
import hunt.web.client.SimpleWebSocketClient;
import hunt.web.client.WebSocketClientSingleton;

import hunt.web.server.Http2ServerBuilder;
import hunt.web.server.SimpleHttpServer;
import hunt.web.server.SimpleHttpServerConfiguration;
import hunt.web.server.SimpleWebSocketServer;

import hunt.web.router.handler.HttpBodyHandler;

import hunt.http.codec.http.model.HttpVersion;

import hunt.util.concurrent.Promise;
import hunt.util.concurrent.CompletableFuture;

private __gshared SimpleHttpClient _httpClient;
private __gshared SimpleHttpClient _httpsClient;
private __gshared SimpleHttpClient _plaintextHttp2Client;

// shared this() {
//     _httpClient = new SimpleHttpClient();
// }

/**
 * The singleton HTTP client to send all requests.
 * The HTTP client manages HTTP connection in the BoundedAsynchronousPool automatically.
 * The default protocol is HTTP 1.1.
 *
 * @return HTTP client singleton instance.
 */
SimpleHttpClient httpClient() { 
    synchronized {
        if(_httpClient is null)
            _httpClient = new SimpleHttpClient();
    }
    return _httpClient;
}


/**
 * The singleton HTTP client to send all requests.
 * The HTTP client manages HTTP connection in the BoundedAsynchronousPool automatically.
 * The protocol is plaintext HTTP 2.0.
 *
 * @return HTTP client singleton instance.
 */
SimpleHttpClient plaintextHttp2Client() {
    synchronized {
        if(_plaintextHttp2Client is null) {
            SimpleHttpClientConfiguration configuration = new SimpleHttpClientConfiguration();
            configuration.setProtocol(HttpVersion.HTTP_2.asString());
            _plaintextHttp2Client = new SimpleHttpClient(configuration);
        }
    }
    return _plaintextHttp2Client;
}

/**
 * The singleton HTTPs client to send all requests.
 * The HTTPs client manages HTTP connection in the BoundedAsynchronousPool automatically.
 * It uses ALPN to determine HTTP 1.1 or HTTP 2.0 protocol.
 *
 * @return HTTPs client singleton instance.
 */
SimpleHttpClient httpsClient() {
    synchronized {
        if(_httpsClient is null) {
            SimpleHttpClientConfiguration configuration = new SimpleHttpClientConfiguration();
            configuration.setSecureConnectionEnabled(true);
            _httpsClient = new SimpleHttpClient(configuration);
        }
    }
    return _httpsClient;
}

/**
 * Create a new HTTP client instance.
 *
 * @return A new HTTP client instance.
 */
SimpleHttpClient createHttpClient() {
    return new SimpleHttpClient();
}

/**
 * Create a new HTTP client instance.
 *
 * @param configuration HTTP client configuration.
 * @return A new HTTP client instance.
 */
SimpleHttpClient createHttpClient(SimpleHttpClientConfiguration configuration) {
    return new SimpleHttpClient(configuration);
}

/**
 * Use fluent API to create an new HTTP server instance.
 *
 * @return HTTP server builder.
 */
Http2ServerBuilder httpServer() {
    return new Http2ServerBuilder().httpServer();
}

/**
 * Create a new HTTP2 server. It uses the plaintext HTTP2 protocol.
 *
 * @return HTTP server builder.
 */
Http2ServerBuilder plaintextHttp2Server() {
    SimpleHttpServerConfiguration configuration = new SimpleHttpServerConfiguration();
    configuration.setProtocol(HttpVersion.HTTP_2.asString());
    return httpServer(configuration);
}

/**
 * Create a new HTTP server.
 *
 * @param serverConfiguration The server configuration.
 * @return HTTP server builder
 */
Http2ServerBuilder httpServer(SimpleHttpServerConfiguration serverConfiguration) {
    return httpServer(serverConfiguration, new HttpBodyConfiguration());
}

/**
 * Create a new HTTP server.
 *
 * @param serverConfiguration   HTTP server configuration.
 * @param httpBodyConfiguration HTTP body process configuration.
 * @return HTTP server builder.
 */
Http2ServerBuilder httpServer(SimpleHttpServerConfiguration serverConfiguration,
                                     HttpBodyConfiguration httpBodyConfiguration) {
    return new Http2ServerBuilder().httpServer(serverConfiguration, httpBodyConfiguration);
}


/**
 * Create a new HTTPs server.
 *
 * @return HTTP server builder.
 */
Http2ServerBuilder httpsServer() {
    return new Http2ServerBuilder().httpsServer();
}

/**
 * Create a new HTTP server instance
 *
 * @return A new HTTP server instance
 */
SimpleHttpServer createHttpServer() {
    return new SimpleHttpServer();
}

/**
 * Create a new HTTP server instance
 *
 * @param configuration HTTP server configuration
 * @return A new HTTP server instance
 */
SimpleHttpServer createHttpServer(SimpleHttpServerConfiguration configuration) {
    return new SimpleHttpServer(configuration);
}


/**
 * Create a new WebSocket server.
 *
 * @return A new WebSocket server.
 */
static SimpleWebSocketServer createWebSocketServer() {
    return new SimpleWebSocketServer();
}

/**
 * Create a new WebSocket server.
 *
 * @param serverConfiguration The WebSocket server configuration.
 * @return A new WebSocket server.
 */
static SimpleWebSocketServer createWebSocketServer(SimpleHttpServerConfiguration serverConfiguration) {
    return new SimpleWebSocketServer(serverConfiguration);
}

/**
 * Get the WebSocket client singleton.
 *
 * @return The websocket client singleton.
 */
static SimpleWebSocketClient webSocketClient() {
    return WebSocketClientSingleton.getInstance().webSocketClient();
}

/**
 * Create a new WebSocket client.
 *
 * @return A new WebSocket client.
 */
static SimpleWebSocketClient createWebSocketClient() {
    return new SimpleWebSocketClient();
}

/**
 * Create a new WebSocket client.
 *
 * @param config The WebSocket client configuration.
 * @return A new WebSocket client.
 */
static SimpleWebSocketClient createWebSocketClient(SimpleHttpClientConfiguration config) {
    return new SimpleWebSocketClient(config);
}


version(WithTLS) {

import hunt.net.secure.SecureSessionFactory;

/**
 * Create a new HTTPs server.
 *
 * @param secureSessionFactory The secure session factory. We provide JDK or OpenSSL secure session factory.
 * @return HTTP server builder.
 */
Http2ServerBuilder httpsServer(SecureSessionFactory secureSessionFactory) {
    return new Http2ServerBuilder().httpsServer(secureSessionFactory);
}

/**
* Create a new HTTPs client.
*
* @param secureSessionFactory The secure session factory. We provide JDK or OpenSSL secure session factory.
* @return A new HTTPs client.
*/
SimpleHttpClient createHttpsClient(SecureSessionFactory secureSessionFactory) {
    SimpleHttpClientConfiguration configuration = new SimpleHttpClientConfiguration();
    configuration.setSecureSessionFactory(secureSessionFactory);
    configuration.setSecureConnectionEnabled(true);
    return new SimpleHttpClient(configuration);
}


/**
 * Create a new secure WebSocket server.
 *
 * @return A new secure WebSocket server.
 */
static SimpleWebSocketServer createSecureWebSocketServer() {
    SimpleHttpServerConfiguration serverConfiguration = new SimpleHttpServerConfiguration();
    serverConfiguration.setSecureConnectionEnabled(true);
    serverConfiguration.getSecureSessionFactory().setSupportedProtocols(["http/1.1"]);
    return new SimpleWebSocketServer(serverConfiguration);
}

/**
 * Create a new secure WebSocket client.
 *
 * @return A new secure WebSocket client.
 */
static SimpleWebSocketClient createSecureWebSocketClient() {
    SimpleHttpClientConfiguration http2Configuration = new SimpleHttpClientConfiguration();
    http2Configuration.setSecureConnectionEnabled(true);
    http2Configuration.getSecureSessionFactory().setSupportedProtocols(["http/1.1"]);
    return new SimpleWebSocketClient(http2Configuration);
}


/**
 * Get the secure WebSocket client singleton.
 *
 * @return The secure WebSocket client singleton.
 */
static SimpleWebSocketClient secureWebSocketClient() {
    return SecureWebSocketClientSingleton.getInstance().secureWebSocketClient();
}

}