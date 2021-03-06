module test.http.router.handler.template;

import hunt.http.$;
import hunt.http.codec.http.model.HttpHeader;
import hunt.http.codec.http.model.HttpStatus;
import hunt.web.server.HttpServerBuilder;
import hunt.util.Assert;
import hunt.util.Test;
import test.http.router.handler.AbstractHttpHandlerTest;

import java.util.concurrent.Phaser;




/**
 * 
 */
public class TestTemplate extends AbstractHttpHandlerTest {

    
    public void test() {
        Phaser phaser = new Phaser(2);

        HttpServerBuilder httpServer = $.httpServer();
        httpServer.router().get("/example").handler(ctx -> {
            ctx.put(HttpHeader.CONTENT_TYPE, "text/plain");
            ctx.renderTemplate("template/example.mustache", new Example());
        }).listen(host, port);

        $.httpClient().get(uri ~ "/example").submit()
         .thenAccept(res -> {
             Assert.assertThat(res.getStatus(), is(HttpStatus.OK_200));
             Assert.assertThat(res.getFields().get(HttpHeader.CONTENT_TYPE), is("text/plain"));
             Assert.assertThat(res.getStringBody().length, greaterThan(0));
             writeln(res.getStringBody());
             phaser.arrive();
         });

        phaser.arriveAndAwaitAdvance();
        httpServer.stop();
        $.httpClient().stop();
    }

}
