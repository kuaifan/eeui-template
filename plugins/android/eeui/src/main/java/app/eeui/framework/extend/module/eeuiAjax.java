package app.eeui.framework.extend.module;

import android.content.Context;

import com.alibaba.fastjson.JSONObject;
import com.taobao.weex.bridge.JSCallback;

import java.util.HashMap;
import java.util.Map;

import app.eeui.framework.activity.PageActivity;

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
        //
        if (name.isEmpty()) {
            if (context instanceof PageActivity) {
                name = ((PageActivity) context).getPageInfo().getPageName();
            }else{
                name = eeuiCommon.randomString(8);
            }
        }
        //
        Map<String, Object> mData = new HashMap<>();
        mData.put("setting:timeout", timeout);
        mData.put("setting:cache", cache);
        mData.put("setting:cacheLabel", "ajax");
        if (headers.size() > 0) {
            for (Map.Entry<String, Object> entry : headers.entrySet()) {
                mData.put("header:" + entry.getKey(), entry.getValue());
            }
        }
        if (data.size() > 0) {
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
        eeuiIhttp.ResultCallback mResultCall = new eeuiIhttp.ResultCallback() {
            @Override
            public void success(String data, boolean isCache) {
                if (callback != null) {
                    Map<String, Object> ret = new HashMap<>();
                    ret.put("status", "success");
                    ret.put("name", finalName);
                    ret.put("url", url);
                    ret.put("cache", isCache);
                    ret.put("result", dataType.equals("json") ? eeuiJson.parseObject(data) : data);
                    callback.invokeAndKeepAlive(ret);
                }
            }

            @Override
            public void error(String error) {
                if (callback != null) {
                    Map<String, Object> ret = new HashMap<>();
                    ret.put("status", "error");
                    ret.put("name", finalName);
                    ret.put("url", url);
                    ret.put("cache", false);
                    ret.put("result", error);
                    callback.invokeAndKeepAlive(ret);
                }
            }

            @Override
            public void complete() {
                if (callback != null) {
                    Map<String, Object> ret = new HashMap<>();
                    ret.put("status", "complete");
                    ret.put("name", finalName);
                    ret.put("url", url);
                    ret.put("cache", false);
                    ret.put("result", null);
                    callback.invoke(ret);
                }
            }
        };
        //
        if (callback != null) {
            Map<String, Object> ret = new HashMap<>();
            ret.put("status", "ready");
            ret.put("name", name);
            ret.put("url", url);
            ret.put("cache", false);
            ret.put("result", null);
            callback.invokeAndKeepAlive(ret);
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
