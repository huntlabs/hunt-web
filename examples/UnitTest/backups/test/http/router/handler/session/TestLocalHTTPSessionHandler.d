module test.http.router.handler.session;

import hunt.http.$;
import hunt.http.codec.http.model.Cookie;
import hunt.web.server.HttpServerBuilder;
import hunt.web.router.HttpSession;
import hunt.web.router.handler.session.HttpSessionConfiguration;
import hunt.web.router.handler.session.LocalHttpSessionHandler;
import hunt.util.Assert;
import hunt.util.Test;
import test.http.router.handler.AbstractHttpHandlerTest;

import hunt.collection.List;
import java.util.concurrent.Phaser;



/**
 * 
 */
public class TestLocalHttpSessionHandler extends AbstractHttpHandlerTest {

    
    public void test() {
        int maxGetSession = 3;
        Phaser phaser = new Phaser(1 + maxGetSession);
        HttpServerBuilder httpsServer = $.httpsServer();
        LocalHttpSessionHandler sessionHandler = new LocalHttpSessionHandler(new HttpSessionConfiguration());
        httpsServer.router().path("*").handler(sessionHandler)
                   .router().post("/session/:name")
                   .handler(ctx -> {
                       string name = ctx.getRouterParameter("name");
                       writeln("the path param -> " ~ name);
                       Assert.assertThat(name, is("foo"));
                       HttpSession session = ctx.getSessionNow();
                       session.getAttributes().put(name, "bar");
                       session.setMaxInactiveInterval(1);
                       ctx.updateSessionNow(session);
                       ctx.end("create session success");
                   })
                   .router().get("/session/:name")
                   .handler(ctx -> {
                       string name = ctx.getRouterParameter("name");
                       Assert.assertThat(name, is("foo"));
                       HttpSession session = ctx.getSessionNow();
                       if (session != null) {
                           Assert.assertThat(session.getAttributes().get("foo"), is("bar"));
                           ctx.end("session value is " ~ session.getAttributes().get("foo"));
                       } else {
                           ctx.end("session is invalid");
                       }
                   })
                   .listen(host, port);

        $.httpsClient().post(uri ~ "/session/foo").submit()
         .thenApply(res -> {
             List<Cookie> cookies = res.getCookies();
             writeln(res.getStatus());
             writeln(cookies);
             writeln(res.getStringBody());
             Assert.assertThat(res.getStringBody(), is("create session success"));
             return cookies;
         })
         .thenApply(cookies -> {
             for (int i = 0; i < maxGetSession; i++) {
                 $.httpsClient().get(uri ~ "/session/foo").cookies(cookies).submit()
                  .thenAccept(res2 -> {
                      string sessionFoo = res2.getStringBody();
                      writeln(sessionFoo);
                      Assert.assertThat(sessionFoo, is("session value is bar"));
                      phaser.arrive();
                  });
             }
             return cookies;
         });

        phaser.arriveAndAwaitAdvance();
        httpsServer.stop();
        $.httpsClient().stop();
        sessionHandler.stop();
    }
}
