module hunt.web.client.SimpleWebSocketClient;

import hunt.web.client.SimpleHttpClientConfiguration;

import hunt.http.client.ClientHttpHandler;
import hunt.http.client.HttpClient;
import hunt.http.client.HttpClientConnection;

import hunt.http.codec.http.model;
import hunt.http.codec.http.stream.HttpConnection;
import hunt.http.codec.http.stream.HttpOutputStream;
import hunt.http.codec.websocket.frame.Frame;
import hunt.http.codec.websocket.model.IncomingFrames;
import hunt.http.codec.websocket.stream.AbstractWebSocketBuilder;
import hunt.http.codec.websocket.stream.WebSocketConnection;
import hunt.http.codec.websocket.stream.WebSocketPolicy;
// import hunt.http.codec.websocket.utils.WSURI;

import hunt.container.ByteBuffer;
import hunt.container.List;
import hunt.lang.common;
import hunt.lang.exception;
import hunt.logging;
import hunt.string;
import hunt.util.concurrent.CompletableFuture;
import hunt.util.concurrent.Promise;
import hunt.util.LifeCycle;

import std.string;

// import java.net.MalformedURLException;
// import java.nio.ByteBuffer;
// import java.util.List;
// import java.util.concurrent.CompletableFuture;

/**
 * 
 */
class SimpleWebSocketClient : AbstractLifeCycle {
    private HttpClient httpClient;

    this() {
        this(new SimpleHttpClientConfiguration());
    }

    this(SimpleHttpClientConfiguration httpConfiguration) {
        httpClient = new HttpClient(httpConfiguration);
        start();
    }

    HandshakeBuilder webSocket(string url) {
        try {
            return webSocket(new HttpURI(url));
        } catch (Exception e) {
            errorf("url exception", e);
            throw new IllegalArgumentException(e);
        }
    }

    HandshakeBuilder webSocket(HttpURI url) {
        try {
            if (!(url.getPath().strip().empty())) {
                url.setPath("/");
            }
            HttpRequest httpRequest = new HttpRequest(HttpMethod.GET.asString(), 
                url, HttpVersion.HTTP_1_1, new HttpFields());

            return new HandshakeBuilder(url.getHost(), url.getPort(), httpRequest);
        } catch (Exception e) {
            errorf("url exception", e);
            throw new IllegalArgumentException(e);
        }
    }

    class HandshakeBuilder : AbstractWebSocketBuilder {

        protected string host;
        protected int port;
        protected HttpRequest request;
        protected WebSocketPolicy webSocketPolicy;

        this(string host, int port, HttpRequest request) {
            this.host = host;
            this.port = port;
            this.request = request;
        }

        HandshakeBuilder addExtension(string extension) {
            request.getFields().add(HttpHeader.SEC_WEBSOCKET_EXTENSIONS, extension);
            return this;
        }

        HandshakeBuilder putExtension(List!string values) {
            request.getFields().put(HttpHeader.SEC_WEBSOCKET_EXTENSIONS.asString(), values);
            return this;
        }

        HandshakeBuilder putSubProtocol(List!string values) {
            request.getFields().put(HttpHeader.SEC_WEBSOCKET_SUBPROTOCOL.asString(), values);
            return this;
        }

        HandshakeBuilder policy(WebSocketPolicy webSocketPolicy) {
            this.webSocketPolicy = webSocketPolicy;
            return this;
        }

        override HandshakeBuilder onText(Action2!(string, WebSocketConnection) handler) {
            super.onText(handler);
            return this;
        }

        override HandshakeBuilder onData(Action2!(ByteBuffer, WebSocketConnection) handler) {
            super.onData(handler);
            return this;
        }

        override HandshakeBuilder onError(Action2!(Throwable, WebSocketConnection) handler) {
            super.onError(handler);
            return this;
        }

        alias onError = AbstractWebSocketBuilder.onError;

        WebSocketConnection connect() {
            Completable!(HttpClientConnection) c = httpClient.connect(host, port);
            HttpClientConnection conn = c.get();

            ClientIncomingFrames clientIncomingFrames = new class ClientIncomingFrames {
                // override
                void incomingError(Exception t) {
                    this.outer.onError(t, webSocketConnection);
                }

                // override
                void incomingFrame(Frame frame) {
                    this.outer.onFrame(frame, webSocketConnection);
                }
            };

            Completable!(WebSocketConnection) future = new Completable!(WebSocketConnection)();
            if (webSocketPolicy is null) {
                webSocketPolicy = WebSocketPolicy.newClientPolicy();
            }

            conn.upgradeWebSocket(request, webSocketPolicy, future, new class ClientHttpHandler.Adapter {
                override
                bool messageComplete(HttpRequest request, MetaData.Response response,
                                                HttpOutputStream output,
                                                HttpConnection connection) {
                    infof("Upgrade websocket success: %s, %s", response.getStatus(), response.getReason());
                    return true;
                }
            }, clientIncomingFrames);

            WebSocketConnection wsc = future.get();
            assert(wsc !is null);
            clientIncomingFrames.setWebSocketConnection(wsc);

            return wsc;
            // TODO: Tasks pending completion -@zxp at 10/23/2018, 3:53:34 PM
            // 
            // return httpClient.connect(host, port).thenCompose(conn -> {
            //     ClientIncomingFrames clientIncomingFrames = new ClientIncomingFrames() {

            //         override
            //         void incomingError(Throwable t) {
            //             HandshakeBuilder.this.onError(t, webSocketConnection);
            //         }

            //         override
            //         void incomingFrame(Frame frame) {
            //             HandshakeBuilder.this.onFrame(frame, webSocketConnection);
            //         }
            //     };
            //     Promise.Completable!(WebSocketConnection) future = new Promise.Completable<>();
            //     if (webSocketPolicy == null) {
            //         webSocketPolicy = WebSocketPolicy.newClientPolicy();
            //     }
            //     conn.upgradeWebSocket(request, webSocketPolicy, future, new ClientHttpHandler.Adapter() {
            //         override
            //         bool messageComplete(HttpRequest request, MetaData.Response response,
            //                                        HttpOutputStream output,
            //                                        HttpConnection connection) {
            //             log.info("Upgrade websocket success: %s, %s", response.getStatus(), response.getReason());
            //             return true;
            //         }
            //     }, clientIncomingFrames);
            //     return future.thenApply(webSocketConnection -> {
            //         clientIncomingFrames.setWebSocketConnection(webSocketConnection);
            //         return webSocketConnection;
            //     });
            // });
        }
    }

    override
    protected void initilize() {
    }

    override
    protected void destroy() {
        httpClient.stop();
    }
}



    abstract protected class ClientIncomingFrames : IncomingFrames {

        protected WebSocketConnection webSocketConnection;

        void setWebSocketConnection(WebSocketConnection webSocketConnection) {
            this.webSocketConnection = webSocketConnection;
        }

    }