module hunt.web.router.impl.PrecisePathMatcher;

import hunt.web.router.impl.AbstractPreciseMatcher;

import hunt.web.router.Matcher;
import hunt.text;

alias MatchType = Matcher.MatchType;
alias MatchResult = Matcher.MatchResult;

/**
 * 
 */
class PrecisePathMatcher : AbstractPreciseMatcher {


    override
    MatchResult match(string value) {
        if (value[$-1] != '/') {
            value ~= "/";
        }

        return super.match(value);
    }

    override
    MatchType getMatchType() {
        return MatchType.PATH;
    }
}
