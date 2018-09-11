module hunt.web.router.handler.Handler;

import hunt.web.router.RoutingContext;

/**
 * 
 */
interface Handler {

    void handle(RoutingContext routingContext);

}



alias RoutingHandler =  void delegate(RoutingContext routingContext);