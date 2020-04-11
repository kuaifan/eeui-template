package app.eeui.framework.extend.module;

import android.content.Context;
import android.text.TextUtils;

import com.alibaba.fastjson.JSONObject;
import com.taobao.weex.bridge.JSCallback;

import java.util.HashMap;
import java.util.Map;

import app.eeui.framework.activity.PageActivity;
import app.eeui.framework.extend.module.http.HttpResponseParser;

public class eeuiAjax {

    /**
     * 跨域异步请求 AJAX
     * @param context
     * @param json
     * @param callback
     */
    public static void ajax(Context context, JSONObject json, JSCallback callback) {
        if (json == null || json.getString("url") == null) {
            return;
        }
        //
        String url = eeuiJson.getString(json, "url", "");
        String name = eeuiJson.getString(json, "name", "");
        String method = eeuiJson.getString(json, "method", "get").toLowerCase();
        String dataType = eeuiJson.getString(json, "dataType", "json").toLowerCase();
        int timeout = eeuiJson.getInt(json, "timeout", 15000);
        long cache = eeuiJson.getLong(json, "cache", 0);
        //
        JSONObject headers = eeuiJson.parseObject(json.getString("headers"));
        JSONObject data = eeuiJson.parseObject(json.getString("data"));
        JSONObject files = eeuiJson.parseObject(json.getString("files"));
        boolean isJson = false;
        //
        boolean beforeAfter = eeuiJson.getBoolean(json, "beforeAfter", false);
        boolean progressCall = eeuiJson.getBoolean(json, "progressCall", false) && files.size() > 0;
        //
        if (name.isEmpty()) {
            name = "ajax-" + eeuiCommon.randomString(8);
        }
        //
        Map<String, Object> mData = new HashMap<>();
        mData.put("setting:timeout", timeout);
        mData.put("setting:cache", cache);
        mData.put("setting:cacheLabel", "ajax");
        if (headers.size() > 0) {
            for (Map.Entry<String, Object> entry : headers.entrySet()) {
                mData.put("header:" + entry.getKey(), entry.getValue());
                if("Content-Type".equals(entry.getKey()) && "application/json".equals(entry.getValue().toString())) {
                    mData.put("datas:" + entry.getKey(), data);
                    isJson = true;
                }
            }
        }
        if (data.size() > 0 && !isJson) {
            for (Map.Entry<String, Object> entry : data.entrySet()) {
                mData.put(entry.getKey(), entry.getValue());
            }
        }
        if (files.size() > 0) {
            for (Map.Entry<String, Object> entry : files.entrySet()) {
                mData.put("file:" + entry.getKey(), entry.getValue());
            }
        }
        //
        String finalName = name;
        final long[] progressTotal = {0};
        eeuiIhttp.ResultCallback mResultCall = new eeuiIhttp.ResultCallback() {
            @Override
            public void progress(long total, long current, boolean isDownloading) {
                if (callback != null && progressCall) {
                    JSONObject progress = new JSONObject();
                    progress.put("fraction", (double) current / total);
                    progress.put("current", current);
                    progress.put("total", total);
                    Map<String, Object> ret = new HashMap<>();
                    ret.put("status", "progress");
                    ret.put("name", finalName);
                    ret.put("url", url);
                    ret.put("cache", false);
                    ret.put("code", 0);
                    ret.put("headers", new JSONObject());
                    ret.put("progress", progress);
                    ret.put("result", null);
                    callback.invokeAndKeepAlive(ret);
                    progressTotal[0] = total;
                }
            }

            @Override
            public void success(HttpResponseParser data, boolean isCache) {
                if (callback != null) {
                    Map<String, Object> ret;
                    if (progressCall) {
                        JSONObject progress = new JSONObject();
                        progress.put("fraction", 1);
                        progress.put("current", progressTotal[0]);
                        progress.put("total", progressTotal[0]);
                        ret = new HashMap<>();
                        ret.put("status", "progress");
                        ret.put("name", finalName);
                        ret.put("url", url);
                        ret.put("cache", false);
                        ret.put("code", 0);
                        ret.put("headers", new JSONObject());
                        ret.put("progress", progress);
                        ret.put("result", null);
                        callback.invokeAndKeepAlive(ret);
                    }
                    ret = new HashMap<>();
                    ret.put("status", "success");
                    ret.put("name", finalName);
                    ret.put("url", url);
                    ret.put("cache", isCache);
                    ret.put("code", data.getCode());
                    ret.put("headers", data.getHeaders());
                    ret.put("result", dataType.equals("json") ? eeuiJson.parseAjax(data.getBody()) : data.getBody());
                    callback.invokeAndKeepAlive(ret);
                }
            }

            @Override
            public void error(String error, int errCode) {
                if (callback != null) {
                    Map<String, Object> ret = new HashMap<>();
                    ret.put("status", "error");
                    ret.put("name", finalName);
                    ret.put("url", url);
                    ret.put("cache", false);
                    ret.put("code", errCode);
                    ret.put("headers", new JSONObject());
                    ret.put("result", error);
                    callback.invokeAndKeepAlive(ret);
                }
            }

            @Override
            public void complete() {
                if (callback != null && beforeAfter) {
                    Map<String, Object> ret = new HashMap<>();
                    ret.put("status", "complete");
                    ret.put("name", finalName);
                    ret.put("url", url);
                    ret.put("cache", false);
                    ret.put("code", 0);
                    ret.put("headers", new JSONObject());
                    ret.put("result", null);
                    callback.invoke(ret);
                }
            }
        };
        //
        if (callback != null && beforeAfter) {
            Map<String, Object> ret = new HashMap<>();
            ret.put("status", "ready");
            ret.put("name", name);
            ret.put("url", url);
            ret.put("cache", false);
            ret.put("code", 0);
            ret.put("headers", new JSONObject());
            ret.put("result", null);
            callback.invokeAndKeepAlive(ret);
        }
        //
        if (context instanceof PageActivity) {
            if (TextUtils.isEmpty(((PageActivity) context).identify)) {
                return;
            }
        }
        //
        if (method.equals("post")) {
            eeuiIhttp.post(name, url, mData, mResultCall);
        }else{
            eeuiIhttp.get(name, url, mData, mResultCall);
        }
    }

    /**
     * 取消跨域异步请求
     * @param name
     */
    public static void ajaxCancel(String name) {
        if (name == null || name.isEmpty()) {
            eeuiIhttp.cancel();
        }else{
            eeuiIhttp.cancel(name);
        }
    }

}
