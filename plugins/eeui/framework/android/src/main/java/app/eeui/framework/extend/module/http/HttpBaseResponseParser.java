package app.eeui.framework.extend.module.http;


import android.text.TextUtils;

import java.lang.reflect.Type;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import app.eeui.framework.extend.integration.xutils.http.app.ResponseParser;
import app.eeui.framework.extend.integration.xutils.http.request.UriRequest;

public class HttpBaseResponseParser implements ResponseParser<String> {

    private int resCode = 0;

    private Map<String, String> resHeaders = new HashMap<>();

    @Override
    public void beforeRequest(UriRequest request) throws Throwable {
        //LogUtil.d(request.getParams().toString());
    }

    @Override
    public void afterRequest(UriRequest request) throws Throwable {
        resCode = request.getResponseCode();
        resHeaders = new HashMap<>();
        for (Map.Entry<String, List<String>> entry : request.getResponseHeaders().entrySet()) {
            if (!TextUtils.isEmpty(entry.getKey())) {
                StringBuilder value = new StringBuilder();
                for (String tmp : entry.getValue()) {
                    if (!TextUtils.isEmpty(value)) {
                        value.append(", ");
                    }
                    value.append(tmp);
                }
                resHeaders.put(entry.getKey(), value.toString());
            }
        }
        //LogUtil.d("response resCode:" + request.getResponseCode());
    }

    /**
     * 转换result为resultType类型的对象
     *
     * @param resultType  返回值类型(可能带有泛型信息)
     * @param resultClass 返回值类型
     * @param result      网络返回数据(支持String, byte[], JSONObject, JSONArray, InputStream)
     * @return 请求结果, 类型为resultType
     */
    @Override
    public Object parse(Type resultType, Class<?> resultClass, String result) throws Throwable {
        if (resultClass == List.class) {
            List<HttpResponseParser> lists = new ArrayList<>();
            HttpResponseParser baiduResponse = new HttpResponseParser();
            baiduResponse.setBody(result);
            baiduResponse.setCode(resCode);
            baiduResponse.setHeaders(resHeaders);
            lists.add(baiduResponse);
            return lists;
        } else {
            HttpResponseParser baiduResponse = new HttpResponseParser();
            baiduResponse.setBody(result);
            baiduResponse.setCode(resCode);
            baiduResponse.setHeaders(resHeaders);
            return baiduResponse;
        }
    }
}
