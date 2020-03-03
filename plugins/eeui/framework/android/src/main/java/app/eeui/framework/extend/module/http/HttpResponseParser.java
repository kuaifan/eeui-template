package app.eeui.framework.extend.module.http;

import androidx.annotation.NonNull;

import java.util.HashMap;
import java.util.Map;

import app.eeui.framework.extend.integration.xutils.http.annotation.HttpResponse;

@HttpResponse(parser = HttpBaseResponseParser.class)
public class HttpResponseParser {

    private String body;

    private int code;

    private Map<String, String> headers = new HashMap<>();

    public String getBody() {
        return body;
    }

    public void setBody(String body) {
        this.body = body;
    }

    public int getCode() {
        return code;
    }

    public void setCode(int code) {
        this.code = code;
    }

    public Map<String, String> getHeaders() {
        return headers;
    }

    public void setHeaders(Map<String, String> headers) {
        this.headers = headers;
    }

    @NonNull
    @Override
    public String toString() {
        return body;
    }
}