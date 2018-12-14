module test.http;

import hunt.http.$;
import hunt.http.codec.http.model.HttpFields;
import hunt.http.codec.http.model.HttpHeader;
import hunt.web.server.HttpServerBuilder;

/**
 * 
 */
public class TrailerDemo {
    public static void main(string[] args) {
        HttpServerBuilder httpServer = $.httpsServer();
        httpServer.router().get("/trailer").handler(ctx -> {
            writeln("get request");
            ctx.put(HttpHeader.CONTENT_TYPE, "text/plain");
            ctx.getResponse().setTrailerSupplier(() -> {
                HttpFields trailer = new HttpFields();
                trailer.add("Foo", "s0");
                trailer.add("Bar", "s00");
                return trailer;
            });
            ctx.end("trailer test");
        }).listen("localhost", 3324);
    }
}
