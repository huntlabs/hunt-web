module test.http.router.handler.ctx;

import hunt.http.$;
import hunt.http.codec.http.model.HttpStatus;
import hunt.web.server.HttpServerBuilder;
import hunt.web.router.RoutingContext;
import hunt.util.Assert;
import hunt.util.Test;
import test.http.router.handler.AbstractHttpHandlerTest;

import java.util.Optional;
import java.util.concurrent.Phaser;

import hunt.web.server.HttpServerBuilder.getCurrentCtx;


/**
 * 
 */
public class TestRoutingCtx extends AbstractHttpHandlerTest {

    
    public void test() {
        Phaser phaser = new Phaser(2);

        HttpServerBuilder s = $.httpServer();
        s.router().get("/testCtx").asyncHandler(ctx -> {
            ctx.setAttribute("hiCtx", "Woo");
            ctx.next();
        })
         .router().get("/testCtx").asyncHandler(ctx -> testCtx())
         .listen(host, port);

        $.httpClient().get(uri ~ "/testCtx").submit()
         .thenAccept(res -> {
             Assert.assertThat(res.getStatus(), is(HttpStatus.OK_200));
             Assert.assertThat(res.getStringBody(), is("Woo"));
             writeln(res.getStringBody());
             phaser.arrive();
         });

        phaser.arriveAndAwaitAdvance();
        s.stop();
        $.httpClient().stop();
    }

    private void testCtx() {
        Optional<RoutingContext> ctx = getCurrentCtx();
        Assert.assertThat(ctx.isPresent(), is(true));
        ctx.ifPresent(c -> c.end(ctx.map(RoutingContext::getAttributes)
                                    .map(m -> (string) m.get("hiCtx"))
                                    .orElse("empty")));
    }
}
