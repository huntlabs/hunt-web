module hunt.web.router.impl.ContentTypePatternMatcher;

import hunt.web.router.Matcher;

import hunt.web.router.impl.AbstractPatternMatcher;
import hunt.http.codec.http.model.MimeTypes;
import hunt.util.string;

import std.range;

alias MatchType = Matcher.MatchType;
alias MatchResult = Matcher.MatchResult;

/**
 * 
 */
class ContentTypePatternMatcher : AbstractPatternMatcher {

    override
    MatchType getMatchType() {
        return MatchType.CONTENT_TYPE;
    }

    override
    MatchResult match(string value) {
        string mimeType = MimeTypes.getContentTypeMIMEType(value);
        if (!mimeType.empty()) {
            return super.match(mimeType);
        } else {
            return null;
        }
    }
}
