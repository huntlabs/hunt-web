module hunt.web.server.Http2ServerBuilder;

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

import hunt.container.ByteBuffer;
import hunt.container.Collections;
import hunt.container.LinkedList;
import hunt.container.List;
import hunt.lang.common;
import hunt.lang.exception;
import hunt.logging;
import hunt.util.functional;

/**
 * 
 */
class Http2ServerBuilder {

    private static RoutingContext currentCtx; 

    private SimpleHttpServer server;
    private RouterManager routerManager;
    private Router currentRouter;
    private List!WebSocketBuilder webSocketBuilders; 

    this()
    {
        webSocketBuilders = new LinkedList!WebSocketBuilder();
    }

    Http2ServerBuilder httpsServer() {
        SimpleHttpServerConfiguration configuration = new SimpleHttpServerConfiguration();
        configuration.setSecureConnectionEnabled(true);
        return httpServer(configuration, new HttpBodyConfiguration());
    }

    Http2ServerBuilder httpsServer(SecureSessionFactory secureSessionFactory) {
        SimpleHttpServerConfiguration configuration = new SimpleHttpServerConfiguration();
        configuration.setSecureConnectionEnabled(true);
        configuration.setSecureSessionFactory(secureSessionFactory);
        return httpServer(configuration, new HttpBodyConfiguration());
    }

    Http2ServerBuilder httpServer() {
        return httpServer(new SimpleHttpServerConfiguration(), new HttpBodyConfiguration());
    }

    Http2ServerBuilder httpServer(SimpleHttpServerConfiguration serverConfiguration,
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
     * @return Http2ServerBuilder
     */
    Http2ServerBuilder router() {
        currentRouter = routerManager.register();
        return this;
    }

    Http2ServerBuilder router(int id) {
        currentRouter = routerManager.register(id);
        return this;
    }

    private void check() {
        if (server is null) {
            throw new IllegalStateException("the http server has not been created, please call httpServer() first");
        }
    }


    Http2ServerBuilder useCertificateFile(string certificate, string privateKey ) {
        check();
        SimpleHttpServerConfiguration config = server.getConfiguration();

version(WithTLS) {
        import hunt.net.secure.conscrypt.AbstractConscryptSSLContextFactory;
        FileCredentialConscryptSSLContextFactory fc = 
            new FileCredentialConscryptSSLContextFactory(certificate, privateKey, "hunt2018", "hunt2018");
        config.getSecureSessionFactory.setServerSSLContextFactory = fc; 
}
        return this;
    }

    Http2ServerBuilder listen(string host, int port) {
        check();
        server.headerComplete( (req) { routerManager.accept(req); }).listen(host, port);
        return this;
    }

    Http2ServerBuilder listen() {
        check();
        server.headerComplete( (req) { routerManager.accept(req); }).listen();
        return this;
    }

    Http2ServerBuilder stop() {
        check();
        server.stop();
        return this;
    }

    // delegated Router methods
    Http2ServerBuilder path(string url) {
        currentRouter.path(url);
        return this;
    }

    Http2ServerBuilder paths(string[] paths) {
        currentRouter.paths(paths);
        return this;
    }

    Http2ServerBuilder pathRegex(string regex) {
        currentRouter.pathRegex(regex);
        return this;
    }

    Http2ServerBuilder method(string method) {
        currentRouter.method(method);
        return this;
    }

    Http2ServerBuilder methods(string[] methods) {
        foreach(string m; methods)
            this.method(m);
        return this;
    }

    Http2ServerBuilder method(HttpMethod httpMethod) {
        currentRouter.method(httpMethod);
        return this;
    }

    Http2ServerBuilder methods(HttpMethod[] methods) {
        foreach(HttpMethod m; methods)
            this.method(m);
        return this;
    }

    Http2ServerBuilder get(string url) {
        currentRouter.get(url);
        return this;
    }

    Http2ServerBuilder post(string url) {
        currentRouter.post(url);
        return this;
    }

    Http2ServerBuilder put(string url) {
        currentRouter.put(url);
        return this;
    }

    Http2ServerBuilder del(string url) {
        currentRouter.del(url);
        return this;
    }

    Http2ServerBuilder consumes(string contentType) {
        currentRouter.consumes(contentType);
        return this;
    }

    Http2ServerBuilder produces(string accept) {
        currentRouter.produces(accept);
        return this;
    }

    Http2ServerBuilder handler(RoutingHandler handler) {
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
            errorf("http server handler exception", e);
        } finally {
            currentCtx = null;
        }
    }

    // TODO: Tasks pending completion -@zxp at 10/23/2018, 4:10:54 PM
    // 
    // Http2ServerBuilder asyncHandler(Handler handler) {
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

        Http2ServerBuilder listen(string host, int port) {
            return this.outer.listen(host, port);
        }

        Http2ServerBuilder listen() {
            return this.outer.listen();
        }

        private Http2ServerBuilder listenWebSocket() {
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

            router().path(path).handler( (ctx) { });
            return this.outer;
        }

    }

    static RoutingContext getCurrentCtx() {
        return currentCtx;
    }
}
