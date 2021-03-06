module hunt.web.server.SimpleHttpServer;

import hunt.http.server;
import hunt.web.server.SimpleHttpServerConfiguration;
import hunt.web.server.SimpleRequest;

import hunt.http.codec.http.model.HttpStatus;
import hunt.http.codec.http.model.MetaData;

import hunt.http.codec.http.stream.HttpConnection;
import hunt.http.codec.http.stream.HttpOutputStream;

import hunt.http.codec.websocket.frame.Frame;
import hunt.http.codec.websocket.stream.WebSocketConnection;
import hunt.http.codec.websocket.stream.WebSocketPolicy;

import hunt.logging;

import hunt.Char;
import hunt.Exceptions;
import hunt.Functions;
import hunt.io;
import hunt.util.Common;
import hunt.util.Lifecycle;

/**
*/
class SimpleHttpServer : AbstractLifecycle { 

    private static  int defaultPoolSize = 10; 

    private HttpServer httpServer;
    private SimpleHttpServerConfiguration configuration;
    private WebSocketPolicy _webSocketPolicy;

    private Action1!SimpleRequest _headerComplete;
    private Action3!(int, string, SimpleRequest) _badMessage;
    private Action1!SimpleRequest _earlyEof;
    private Action1!HttpConnection _acceptConnection;
    private Action2!(SimpleRequest, HttpServerConnection) tunnel;

    // private Meter requestMeter;
    // private ExecutorService handlerExecutorService;

    private WebSocketHandler[string] webSocketHandlerMap;

    this() {
        this(new SimpleHttpServerConfiguration());
    }

    this(SimpleHttpServerConfiguration configuration) {
        this.configuration = configuration;
        // TODO: Tasks pending completion -@zxp at 7/5/2018, 2:59:11 PM
        // 
        // requestMeter = this.configuration.getTcpConfiguration()
        //                                  .getMetricReporterFactory()
        //                                  .getMetricRegistry()
        //                                  .meter("http2.SimpleHttpServer.request.count");
        // handlerExecutorService = new ForkJoinPool(defaultPoolSize, (pool) {
        //     ForkJoinWorkerThread workerThread = ForkJoinPool.defaultForkJoinWorkerThreadFactory.newThread(pool);
        //     workerThread.setName("hunt-http-server-handler-pool-" ~ workerThread.getPoolIndex());
        //     return workerThread;
        // }, null, true);
    }

    SimpleHttpServer acceptHttpTunnelConnection(Action2!(SimpleRequest, HttpServerConnection) tunnel) {
        this.tunnel = tunnel;
        return this;
    }

    SimpleHttpServer headerComplete(Action1!SimpleRequest h) {
        this._headerComplete = h;
        return this;
    }

    SimpleHttpServer earlyEof(Action1!SimpleRequest e) {
        this._earlyEof = e;
        return this;
    }

    SimpleHttpServer badMessage(Action3!(int, string, SimpleRequest) b) {
        this._badMessage = b;
        return this;
    }

    SimpleHttpServer acceptConnection(Action1!HttpConnection a) {
        this._acceptConnection = a;
        return this;
    }

    SimpleHttpServer registerWebSocket(string uri, WebSocketHandler webSocketHandler) {
        webSocketHandlerMap[uri] = webSocketHandler;
        return this;
    }

    SimpleHttpServer webSocketPolicy(WebSocketPolicy w) {
        this._webSocketPolicy = w;
        return this;
    }

    // ExecutorService getNetExecutorService() {
    //     return httpServer.getNetExecutorService();
    // }

    // ExecutorService getHandlerExecutorService() {
    //     return handlerExecutorService;
    // }

    SimpleHttpServerConfiguration getConfiguration() {
        return configuration;
    }

    void listen(string host, int port) {
        configuration.setHost(host);
        configuration.setPort(port);
        listen();
    }

    void listen() {
        start();
    }

    override
    protected void initialize() {
        SimpleWebSocketHandler webSocketHandler = new SimpleWebSocketHandler();
        webSocketHandler.setWebSocketPolicy(_webSocketPolicy);

        httpServer = new HttpServer(configuration.getHost(), configuration.getPort(), 
            configuration, buildAdapter(), webSocketHandler); // 

        httpServer.start();
    }

    private ServerHttpHandlerAdapter buildAdapter() {
        ServerHttpHandlerAdapter adapter = new ServerHttpHandlerAdapter();

        adapter.acceptConnection(_acceptConnection)
            .acceptHttpTunnelConnection((request, response, ot, connection) {
                SimpleRequest r = new SimpleRequest(request, response, ot, cast(HttpConnection)connection);
                request.setAttachment(r);
                if (tunnel !is null) {
                    tunnel(r, connection);
                }
                return true;
            }).headerComplete((request, response, ot, connection) {
                SimpleRequest r = new SimpleRequest(request, response, ot, connection);
                request.setAttachment(r);
                if (_headerComplete != null) {
                    _headerComplete(r);
                }
                // requestMeter.mark();
                return false;
            }).content((buffer, request, response, ot, connection) {
                SimpleRequest r = cast(SimpleRequest) request.getAttachment();
                if (r.content !is null) {
                    r.content(buffer);
                } else {
                    r.requestBody.add(buffer);
                }
                return false;
            }).contentComplete((request, response, ot, connection)  {
                SimpleRequest r = cast(SimpleRequest) request.getAttachment();
                if (r.contentComplete !is null) {
                    r.contentComplete(r);
                }
                return false;
            }).messageComplete((request, response, ot, connection)  {
                SimpleRequest r = cast(SimpleRequest) request.getAttachment();
                if (r.messageComplete != null) {
                    r.messageComplete(r);
                }
                if (!r.getResponse().isAsynchronous()) {
                    IOUtils.close(r.getResponse());
                }
                return true;
            }).badMessage((status, reason, request, response, ot, connection)  {
                if (_badMessage !is null) {
                    if (request.getAttachment() !is null) {
                        SimpleRequest r = cast(SimpleRequest) request.getAttachment();
                        _badMessage(status, reason, r);
                    } else {
                        SimpleRequest r = new SimpleRequest(request, response, ot, connection);
                        request.setAttachment(r);
                        _badMessage(status, reason, r);
                    }
                }
            }).earlyEOF((request, response, ot, connection)  {
                if (_earlyEof != null) {
                    if (request.getAttachment() !is null) {
                        SimpleRequest r = cast(SimpleRequest) request.getAttachment();
                        _earlyEof(r);
                    } else {
                        SimpleRequest r = new SimpleRequest(request, response, ot, connection);
                        request.setAttachment(r);
                        _earlyEof(r);
                    }
                }
            });

        return adapter;
    }

    override protected void destroy() {
        try {
            // handlerExecutorService.shutdown();
        } catch (Exception e) {
            warningf("simple http server handler pool shutdown exception", e);
        } finally {
        // TODO: Tasks pending completion -@zxp at 7/5/2018, 3:47:12 PM            
        // 
            httpServer.stop();
        }
    }

    class SimpleWebSocketHandler : WebSocketHandler {

        override
        bool acceptUpgrade(HttpRequest request, HttpResponse response, 
            HttpOutputStream output, HttpConnection connection) {
            version(HUNT_DEBUG) {
                info("The connection %s will upgrade to WebSocket connection",
                    connection.getSessionId());
            }
            string path = request.getURI().getPath();
            WebSocketHandler handler = webSocketHandlerMap.get(path, null);
            if (handler is null) {
                response.setStatus(HttpStatus.BAD_REQUEST_400);
                try {
                    output.write(cast(byte[])("The " ~ path 
                        ~ " can not upgrade to WebSocket"));
                }catch (IOException e) {
                    errorf("Write http message exception", e);
                }
                return false;
            } else {
                return handler.acceptUpgrade(request, response, output, connection);
            }
        }

        override
        void onConnect(WebSocketConnection connection) {
            string path = connection.getUpgradeRequest().getURI().getPath();
            WebSocketHandler handler = webSocketHandlerMap.get(path, null);
            if(handler !is null)
                handler.onConnect(connection);
        }

        override
        void onFrame(Frame frame, WebSocketConnection connection) {
            string path = connection.getUpgradeRequest().getURI().getPath();
            WebSocketHandler handler = webSocketHandlerMap.get(path, null);
            if(handler !is null)
                handler.onFrame(frame, connection);
        }

        override
        void onError(Exception t, WebSocketConnection connection) {
            string path = connection.getUpgradeRequest().getURI().getPath();
            WebSocketHandler handler = webSocketHandlerMap.get(path, null);
            if(handler !is null)
                handler.onError(t, connection);
        }
    }

}


