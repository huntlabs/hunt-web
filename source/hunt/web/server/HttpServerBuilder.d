module hunt.web.server.HttpServerBuilder;

import hunt.web.server.SimpleHttpServer;
import hunt.web.server.SimpleHttpServerConfiguration;

import hunt.http.codec.http.model.BadMessageException;
import hunt.http.codec.http.model.HttpMethod;
import hunt.http.codec.websocket.frame.Frame;
import hunt.http.codec.websocket.stream.AbstractWebSocketBuilder;
import hunt.http.codec.websocket.stream.WebSocketConnection;
import hunt.http.server.WebSocketHandler;

import hunt.net.secure.SecureSessionFactory;

import hunt.web.router.handler;
import hunt.web.router.Router;
import hunt.web.router.RouterManager;
import hunt.web.router.RoutingContext;
import hunt.web.router.impl.RoutingContextImpl;

import hunt.collection.ByteBuffer;
import hunt.collection.Collections;
import hunt.collection.LinkedList;
import hunt.collection.List;
import hunt.util.Common;
import hunt.Exceptions;
import hunt.logging;
import hunt.Functions;

/**
 * 
 */
class HttpServerBuilder {

    private static RoutingContext currentCtx; 

    private SimpleHttpServer server;
    private RouterManager routerManager;
    private Router currentRouter;
    private List!WebSocketBuilder webSocketBuilders; 

    this() {
        webSocketBuilders = new LinkedList!WebSocketBuilder();
    }

    HttpServerBuilder httpsServer() {
        SimpleHttpServerConfiguration configuration = new SimpleHttpServerConfiguration();
        configuration.setSecureConnectionEnabled(true);
        return httpServer(configuration, new HttpBodyConfiguration());
    }

    HttpServerBuilder httpsServer(SecureSessionFactory secureSessionFactory) {
        SimpleHttpServerConfiguration configuration = new SimpleHttpServerConfiguration();
        configuration.setSecureConnectionEnabled(true);
        configuration.setSecureSessionFactory(secureSessionFactory);
        return httpServer(configuration, new HttpBodyConfiguration());
    }

    HttpServerBuilder httpServer() {
        return httpServer(new SimpleHttpServerConfiguration(), new HttpBodyConfiguration());
    }

    HttpServerBuilder httpServer(SimpleHttpServerConfiguration serverConfiguration,
                                         HttpBodyConfiguration httpBodyConfiguration) {
        AbstractErrorResponseHandler handler = DefaultErrorResponseHandlerLoader.getInstance().getHandler();
        server = new SimpleHttpServer(serverConfiguration);
        server.badMessage((status, reason, request) {
            RoutingContext ctx = new RoutingContextImpl(request, Collections.emptyNavigableSet!(RouterMatchResult)());
            handler.render(ctx, status, new BadMessageException(reason));
        });
        routerManager = RouterManager.create(httpBodyConfiguration);
        return this;
    }

    SimpleHttpServer getServer() {
        return server;
    }

    /**
     * register a new router
     *
     * @return HttpServerBuilder
     */
    HttpServerBuilder router() {
        currentRouter = routerManager.register();
        return this;
    }

    HttpServerBuilder router(int id) {
        currentRouter = routerManager.register(id);
        return this;
    }

    private void check() {
        if (server is null) {
            throw new IllegalStateException("the http server has not been created, please call httpServer() first");
        }
    }


    HttpServerBuilder useCertificateFile(string certificate, string privateKey ) {
        check();
        SimpleHttpServerConfiguration config = server.getConfiguration();

version(WITH_HUNT_SECURITY) {
        import hunt.net.secure.conscrypt.AbstractConscryptSSLContextFactory;
        FileCredentialConscryptSSLContextFactory fc = 
            new FileCredentialConscryptSSLContextFactory(certificate, privateKey, "hunt2018", "hunt2018");
        config.getSecureSessionFactory.setServerSSLContextFactory = fc; 
}
        return this;
    }

    HttpServerBuilder listen(string host, int port) {
        check();
        foreach(WebSocketBuilder b; webSocketBuilders) {
            b.listenWebSocket();
        }

        server.headerComplete( (req) { routerManager.accept(req); }).listen(host, port);

        return this;
    }

    HttpServerBuilder listen() {
        check();
        foreach(WebSocketBuilder b; webSocketBuilders) {
            b.listenWebSocket();
        }
        server.headerComplete( (req) { routerManager.accept(req); }).listen();
        return this;
    }

    HttpServerBuilder stop() {
        check();
        server.stop();
        return this;
    }

    // delegated Router methods
    HttpServerBuilder path(string url) {
        currentRouter.path(url);
        return this;
    }

    HttpServerBuilder paths(string[] paths) {
        currentRouter.paths(paths);
        return this;
    }

    HttpServerBuilder pathRegex(string regex) {
        currentRouter.pathRegex(regex);
        return this;
    }

    HttpServerBuilder method(string method) {
        currentRouter.method(method);
        return this;
    }

    HttpServerBuilder methods(string[] methods) {
        foreach(string m; methods)
            this.method(m);
        return this;
    }

    HttpServerBuilder method(HttpMethod httpMethod) {
        currentRouter.method(httpMethod);
        return this;
    }

    HttpServerBuilder methods(HttpMethod[] methods) {
        foreach(HttpMethod m; methods)
            this.method(m);
        return this;
    }

    HttpServerBuilder get(string url) {
        currentRouter.get(url);
        return this;
    }

    HttpServerBuilder post(string url) {
        currentRouter.post(url);
        return this;
    }

    HttpServerBuilder put(string url) {
        currentRouter.put(url);
        return this;
    }

    HttpServerBuilder del(string url) {
        currentRouter.del(url);
        return this;
    }

    HttpServerBuilder consumes(string contentType) {
        currentRouter.consumes(contentType);
        return this;
    }

    HttpServerBuilder produces(string accept) {
        currentRouter.produces(accept);
        return this;
    }

    HttpServerBuilder handler(RoutingHandler handler) {
        currentRouter.handler( (RoutingContext ctx) { handlerWrap(handler, ctx); });
        // currentRouter.handler( new class Handler {
        //      void handle(RoutingContext ctx) { handlerWrap(handler, ctx); }
        // });
        return this;
    }

    protected void handlerWrap(RoutingHandler handler, RoutingContext ctx) {
        try {
            currentCtx = ctx;
            handler(ctx);
        } catch (Exception e) {
            ctx.fail(e);
            errorf("http server handler exception: ", e);
        } finally {
            currentCtx = null;
        }
    }

    // TODO: Tasks pending completion -@zxp at 10/23/2018, 4:10:54 PM
    // 
    // HttpServerBuilder asyncHandler(Handler handler) {
    //     currentRouter.handler( (RoutingContext ctx) {
    //         ctx.getResponse().setAsynchronous(true);
    //         server.getHandlerExecutorService().execute(() -> handlerWrap(handler, ctx));
    //     });
    //     return this;
    // }

    WebSocketBuilder webSocket(string path) {
        WebSocketBuilder webSocketBuilder = new WebSocketBuilder(path);
        webSocketBuilders.add(webSocketBuilder);
        return webSocketBuilder;
    }

    /**
    */
    class WebSocketBuilder : AbstractWebSocketBuilder {
        protected string path;
        protected Action1!(WebSocketConnection) _connectHandler;

        this(string path) {
            this.path = path;
        }

        WebSocketBuilder onConnect(Action1!(WebSocketConnection) handler) {
            this._connectHandler = handler;
            return this;
        }

        override WebSocketBuilder onText(Action2!(string, WebSocketConnection) handler) {
            super.onText(handler);
            return this;
        }

        override WebSocketBuilder onData(Action2!(ByteBuffer, WebSocketConnection) handler) {
            super.onData(handler);
            return this;
        }

        override WebSocketBuilder onError(Action2!(Throwable, WebSocketConnection) handler) {
            super.onError(handler);
            return this;
        }

        alias onError = AbstractWebSocketBuilder.onError;

        HttpServerBuilder listen(string host, int port) {
            return this.outer.listen(host, port);
        }

        HttpServerBuilder listen() {
            return this.outer.listen();
        }

        private HttpServerBuilder listenWebSocket() {
            server.registerWebSocket(path, new class WebSocketHandler {

                override
                void onConnect(WebSocketConnection webSocketConnection) {
                    if(_connectHandler !is null) 
                        _connectHandler(webSocketConnection);
                }

                override
                void onFrame(Frame frame, WebSocketConnection connection) {
                    this.outer.onFrame(frame, connection);
                }

                override
                void onError(Exception t, WebSocketConnection connection) {
                    this.outer.onError(t, connection);
                }
            });

            router().path(path).handler( (ctx) { 
                version(HUNT_DEBUG) info("Do nothing");
            });
            return this.outer;
        }

    }

    static RoutingContext getCurrentCtx() {
        return currentCtx;
    }
}
