
import hunt.web.client.SimpleHttpClient;
import hunt.web.client.SimpleResponse;

import hunt.concurrency.Promise;
import hunt.concurrency.CompletableFuture;

import hunt.logging;

import std.conv;
import std.stdio;

void main(string[] args) {

	enum host = "127.0.0.1";
	enum port = "8080";

	SimpleHttpClient client = new SimpleHttpClient();

	trace("step 1.....");
	for (int i = 0; i < 1; i++) {
		client.post("http://" ~ host ~ ":" ~ port ~ "/postData")
				.put("RequestId", i.to!string ~ "_")
				.bodyContent("test post data, hello foo " ~ i.to!string)
				.submit( (SimpleResponse r) {
					writeln(r.getStringBody());
				});
	}

	// FIXME: Needing refactor or cleanup -@zxp at 7/23/2018, 10:40:57 AM
	// 
	// trace("step 2.....");
	// for (int i = 10; i < 11; i++) {
	// 	client.post("http://" ~ host ~ ":" ~ port ~ "/postData")
	// 			.put("RequestId", i.to!string ~ "_")
	// 			.bodyContent("test post data, hello foo " ~ i.to!string)
	// 			.submit()
	// 			.thenAccept( (SimpleResponse r) {
	// 				writeln(r.getStringBody());
	// 			});
	// }

	// trace("step 3.....");
	// for (int i = 30; i < 31; i++) {
	// 	CompletableFuture!SimpleResponse future = client
	// 			.post("http://" ~ host ~ ":" ~ port ~ "/postData")
	// 			.put("RequestId", i.to!string ~ "_")
	// 			.bodyContent("test post data, hello foo " ~ i.to!string)
	// 			.submit();
				
	// 	SimpleResponse r = future.get();
	// 	if( r is null)
	// 	{
	// 		warning("no response");
	// 	}
	// 	else
	// 		writeln(r.getStringBody());
	// }

	// getchar();
	client.stop();
}