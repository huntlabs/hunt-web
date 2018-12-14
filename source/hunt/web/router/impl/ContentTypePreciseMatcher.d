module hunt.web.router.impl.ContentTypePreciseMatcher;

import hunt.web.router.impl.AbstractPreciseMatcher;
import hunt.util.MimeTypeUtils;
import hunt.string;


import hunt.web.router.Matcher;
import std.range;

alias MatchType = Matcher.MatchType;
alias MatchResult = Matcher.MatchResult;

/**
 * 
 */
class ContentTypePreciseMatcher : AbstractPreciseMatcher {

    override
    MatchType getMatchType() {
        return MatchType.CONTENT_TYPE;
    }

    override
    MatchResult match(string value) {
        string mimeType = MimeTypeUtils.getContentTypeMIMEType(value);
        if (!mimeType.empty()) {
            return super.match(mimeType);
        } else {
            return null;
        }
    }
}
