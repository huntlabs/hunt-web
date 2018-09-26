module hunt.web.server.SimpleRequest;

import hunt.web.server.SimpleResponse;

import hunt.http.codec.http.model;
import hunt.http.codec.http.stream.HttpConnection;
import hunt.http.codec.http.stream.HttpOutputStream;
import hunt.http.server.WebSocketHandler;

import hunt.util.exception;
import hunt.string;
import hunt.util.functional;

import hunt.container;

import std.array;
import std.container.array;

class SimpleRequest {

    HttpRequest request;
    SimpleResponse response;
    HttpConnection connection;
    Action1!ByteBuffer content;
    Action1!SimpleRequest contentComplete;
    Action1!SimpleRequest messageComplete;
    List!(ByteBuffer) requestBody; 

    private Cookie[] cookies;
    string stringBody;

    string[string] attributes; // = new ConcurrentHashMap<>();

    this(HttpRequest request, HttpResponse response,
                         HttpOutputStream output,
                         HttpConnection connection) {
        requestBody = new ArrayList!(ByteBuffer)();
        this.request = request;
        response.setStatus(HttpStatus.OK_200);
        response.setHttpVersion(HttpVersion.HTTP_1_1);
        this.response = new SimpleResponse(response, output, request.getURI());
        this.connection = connection;
    }

    HttpVersion getHttpVersion() {
        return request.getHttpVersion();
    }

    HttpFields getFields() {
        return request.getFields();
    }

    long getContentLength() {
        return getFields().getLongField(HttpHeader.CONTENT_LENGTH.asString());
    }

    // Iterator<HttpField> iterator() {
    //     return request.iterator();
    // }

    string getMethod() {
        return request.getMethod();
    }

    HttpURI getURI() {
        return request.getURI();
    }

    string getURIString() {
        return request.getURIString();
    }

    Supplier!HttpFields getTrailerSupplier() {
        return request.getTrailerSupplier();
    }

    // void forEach(Consumer<? super HttpField> action) {
    //     request.forEach(action);
    // }

    // Spliterator<HttpField> spliterator() {
    //     return request.spliterator();
    // }

    string get(string key) {
        return attributes[key];
    }

    string put(string key, string value) {
        return attributes[key] = value;
    }

    string remove(string key) {
        auto r = attributes[key];
        attributes.remove(key);
        return r;
    }

    string[string] getAttributes() {
        return attributes;
    }

    override
    string toString() {
        return request.toString();
    }

    HttpRequest getRequest() {
        return request;
    }

    SimpleResponse getResponse() {
        return response;
    }

    SimpleResponse getAsyncResponse() {
        response.setAsynchronous(true);
        return response;
    }

    HttpConnection getConnection() {
        return connection;
    }

    List!(ByteBuffer) getRequestBody() {
        return requestBody;
    }

    SimpleRequest onContent(Action1!ByteBuffer c) {
        this.content = c;
        return this;
    }

    SimpleRequest onContentComplete(Action1!SimpleRequest c) {
        this.contentComplete = c;
        return this;
    }

    SimpleRequest onMessageComplete(Action1!SimpleRequest m) {
        this.messageComplete = m;
        return this;
    }

    string getStringBody(string charset) {
        if (stringBody is null) {
            Appender!string buffer;
            foreach(ByteBuffer b; requestBody) {
                buffer.put(cast(string)b.array);
            }
            stringBody = buffer.data; // BufferUtils.toString(requestBody, charset);
        } 
        return stringBody;
    }

    string getStringBody() {
        return getStringBody("UTF-8");
    }

    // <T> T getJsonBody(Class<T> clazz) {
    //     return Json.toObject(getStringBody(), clazz);
    // }

    // <T> T getJsonBody(GenericTypeReference<T> typeReference) {
    //     return Json.toObject(getStringBody(), typeReference);
    // }

    // JsonObject getJsonObjectBody() {
    //     return Json.toJsonObject(getStringBody());
    // }

    // JsonArray getJsonArrayBody() {
    //     return Json.toJsonArray(getStringBody());
    // }

    Cookie[] getCookies() {
        if (cookies is null) {
			Array!(Cookie) list;
			foreach(string v; getFields().getValuesList(HttpHeader.COOKIE)) {
				if(v.empty) continue;
				foreach(Cookie c; CookieParser.parseCookie(v))
					list.insertBack(c);
			}
			cookies = list.array();
        }
        return cookies;
    }
}
