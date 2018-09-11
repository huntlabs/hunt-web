module hunt.web.router.RequestAcceptor;

import hunt.web.server.SimpleRequest;

/**
 * 
 */
interface RequestAcceptor {

    void accept(SimpleRequest request);

}
