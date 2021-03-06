module hunt.web.router.impl.AcceptHeaderMatcher;

import hunt.web.router.impl.AbstractPreciseMatcher;
import hunt.web.router.Matcher;
import hunt.web.router.Router;

import hunt.text;
import hunt.Exceptions;
import hunt.collection;

import hunt.util.MimeTypeUtils; 
import hunt.util.AcceptMimeType;

alias MatchType = Matcher.MatchType;
alias MatchResult = Matcher.MatchResult;

import std.algorithm;
import std.container.array;
import std.string; 

import hunt.logging;

/**
 * 
 */
class AcceptHeaderMatcher : AbstractPreciseMatcher {

    override MatchType getMatchType() {
        return MatchType.ACCEPT;
    }

    private bool checkKey(AcceptMimeType type, string key) {
        string[] t = StringUtils.split(key, "/");
        string p = t[0].strip();
        string c = t[1].strip();
        switch (type.getMatchType()) {
            case AcceptMimeMatchType.EXACT:
                return p.equals(type.getParentType()) && c.equals(type.getChildType());
            case AcceptMimeMatchType.CHILD:
                return c.equals(type.getChildType());
            case AcceptMimeMatchType.PARENT:
                return p.equals(type.getParentType());
            case AcceptMimeMatchType.ALL:
                return true;
            default:
                return false;
        }
    }

    override MatchResult match(string value) {
        if (_map is null) {
            return null;
        }

        Array!AcceptMimeType acceptMIMETypes = MimeTypeUtils.parseAcceptMIMETypes(value);
        Set!Router set = new HashSet!Router();

        foreach (AcceptMimeType type ; acceptMIMETypes) {
            foreach(string key, Set!(Router) value; _map) {
                if(checkKey(type, key)) {
                    set.addAll(value);
                }
            }

            if(!set.isEmpty())
                return new MatchResult(set, Collections.emptyMap!(Router, Map!(string, string))(), getMatchType());
        }

        return null;
    }
}
