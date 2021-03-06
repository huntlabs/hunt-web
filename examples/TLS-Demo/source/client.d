
import hunt.http.codec.http.model;

import hunt.web.client.SimpleHttpClient;
import hunt.web.client.SimpleResponse;

import hunt.concurrency.Promise;
import hunt.concurrency.CompletableFuture;

import hunt.net.secure.SecureSessionFactory;
import hunt.net.secure.conscrypt;

import hunt.web.helper;
import hunt.util.DateTime;
import hunt.logging;

import std.datetime;
import std.conv;
import std.stdio;

void main(string[] args) {
	SimpleHttpClient simpleHttpClient = test(new ConscryptSecureSessionFactory());
	// simpleHttpClient = test(new JdkSecureSessionFactory());
	simpleHttpClient.stop();
}


// string[] urlList = ["https://www.putao.com/",
//             "https://segmentfault.com"];

string[] urlList = ["https://10.1.222.120:444/"];
// string[] urlList = ["https://127.0.0.1:8081/"];

long getMillisecond(long v)
{
    return convert!(TimeUnit.HectoNanosecond, TimeUnit.Millisecond)(v);
}

SimpleHttpClient test(SecureSessionFactory secureSessionFactory) {
    long testStart = Clock.currStdTime;
    tracef("The secure session factory is " ~ typeid(secureSessionFactory).name);
    SimpleHttpClient client = createHttpsClient(secureSessionFactory);
    // for (int i = 0; i < 5; i++) {
    //     CountDownLatch latch = new CountDownLatch(urlList.size());
    foreach(string url; urlList)
    {
        long start = Clock.currStdTime;
        client.get(url).submit().thenAccept((SimpleResponse resp) {
            long end = Clock.currStdTime;
            if (resp.getStatus() == HttpStatus.OK_200) {
                tracef("The " ~ url ~ " is OK. " ~
                        "Size: " ~ resp.getStringBody().length.to!string() ~ ". " ~
                        "Time: " ~ getMillisecond(end - start).to!string() ~ ". " ~
                        "Version: " ~ resp.getHttpVersion().toString());
            } else {
                tracef("The " ~ url ~ " is failed. " ~
                        "Status: " ~ resp.getStatus().to!string() ~ ". " ~
                        "Time: " ~ getMillisecond(end - start).to!string() ~ ". " ~
                        "Version: " ~ resp.getHttpVersion().toString());
            }
                // latch.countDown();
        });
    }
			
    //     latch.await();
    //     tracef("test " ~ i.to!string() ~ " completion. ");
    // }
    // long testEnd = Clock.currStdTime;
    // tracef("The secure session factory " ~ typeid(secureSessionFactory).name ~ " test completed. " ~ 
    //     getMillisecond(testEnd - testStart).to!string());
    return client;
}