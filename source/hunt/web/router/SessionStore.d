module hunt.web.router.SessionStore;

import hunt.web.router.HttpSession;
import hunt.util.LifeCycle;


/**
 * 
 */
interface SessionStore : LifeCycle {

    bool remove(string key);

    bool put(string key, HttpSession value);

    HttpSession get(string key);

    int size();

}
