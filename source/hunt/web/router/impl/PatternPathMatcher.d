module hunt.web.router.impl.PatternPathMatcher;


import hunt.web.router.impl.AbstractPatternMatcher;
import hunt.web.router.Matcher;

alias MatchType = Matcher.MatchType;
alias MatchResult = Matcher.MatchResult;


/**
 * 
 */
class PatternPathMatcher : AbstractPatternMatcher {

    override
    MatchType getMatchType() {
        return MatchType.PATH;
    }

}
