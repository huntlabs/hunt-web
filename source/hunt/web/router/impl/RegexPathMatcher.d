module hunt.web.router.impl.RegexPathMatcher;



import hunt.web.router.impl.AbstractRegexMatcher;
import hunt.web.router.Matcher;

alias MatchType = Matcher.MatchType;

/**
 * 
 */
class RegexPathMatcher : AbstractRegexMatcher {
    
    override
    MatchType getMatchType() {
        return MatchType.PATH;
    }

}
