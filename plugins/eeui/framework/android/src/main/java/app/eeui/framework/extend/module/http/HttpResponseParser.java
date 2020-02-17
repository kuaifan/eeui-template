package app.eeui.framework.extend.module.http;

import androidx.annotation.NonNull;

import java.util.HashMap;
import java.util.Map;

import app.eeui.framework.extend.integration.xutils.http.annotation.HttpResponse;

@HttpResponse(parser = HttpBaseResponseParser.class)
public class HttpResponseParser {

    private String body;

    private int code;

    private Map<String, String> header = new HashMap<>();

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

    public Map<String, String> getHeader() {
        return header;
    }

    public void setHeader(Map<String, String> header) {
        this.header = header;
    }

    @NonNull
    @Override
    public String toString() {
        return body;
    }
}