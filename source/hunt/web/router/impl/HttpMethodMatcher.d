module hunt.web.router.impl.HttpMethodMatcher;

import hunt.web.router.impl.AbstractPreciseMatcher;
import hunt.web.router.Matcher;

import std.string;

alias MatchType = Matcher.MatchType;
alias MatchResult = Matcher.MatchResult;

/**
 * 
 */
class HttpMethodMatcher : AbstractPreciseMatcher {

    override
    MatchResult match(string value) {
        return super.match(value.toUpper());
    }

    override
    MatchType getMatchType() {
        return MatchType.METHOD;
    }
}
