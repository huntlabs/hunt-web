module hunt.web.router.SessionStore;

import hunt.web.router.HttpSession;
import hunt.util.Lifecycle;


/**
 * 
 */
interface SessionStore : Lifecycle {

    bool remove(string key);

    bool put(string key, HttpSession value);

    HttpSession get(string key);

    int size();

}
