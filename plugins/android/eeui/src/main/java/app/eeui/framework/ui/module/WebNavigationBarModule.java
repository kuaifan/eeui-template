package app.eeui.framework.ui.module;

import com.alibaba.fastjson.JSONArray;
import com.alibaba.fastjson.JSONObject;

import app.eeui.framework.activity.PageActivity;
import app.eeui.framework.extend.module.eeuiJson;
import app.eeui.framework.extend.view.ExtendWebView;
import app.eeui.framework.extend.view.webviewBridge.JsCallback;
import app.eeui.framework.ui.eeui;

public class WebNavigationBarModule {

    public static void setTitle(ExtendWebView webView, String object, JsCallback callback) {
        if (webView.getContext() instanceof PageActivity) {
            JSONObject json = eeuiJson.parseObject(object);
            if (json.size() == 0) {
                json.put("title", object);
            }
            PageActivity mPageActivity = ((PageActivity) webView.getContext());
            mPageActivity.setNavigationTitle(json, result -> {
                if (callback != null) {
                    eeui.MCallback(callback).invokeAndKeepAlive(result);
                }
            });
        }
    }

    public static void setLeftItem(ExtendWebView webView, String object, JsCallback callback) {
        if (webView.getContext() instanceof PageActivity) {
            Object items = null;
            JSONObject json = eeuiJson.parseObject(object);
            if (json.size() == 0) {
                JSONArray array = eeuiJson.parseArray(object);
                if (array.size() == 0) {
                    json.put("title", object);
                }else{
                    items = array;
                }
            }else{
                items = json;
            }
            PageActivity mPageActivity = ((PageActivity) webView.getContext());
            mPageActivity.setNavigationItems(items, "left", result -> {
                if (callback != null) {
                    eeui.MCallback(callback).invokeAndKeepAlive(result);
                }
            });
        }
    }

    public static void setRightItem(ExtendWebView webView, String object, JsCallback callback) {
        if (webView.getContext() instanceof PageActivity) {
            Object items = null;
            JSONObject json = eeuiJson.parseObject(object);
            if (json.size() == 0) {
                JSONArray array = eeuiJson.parseArray(object);
                if (array.size() == 0) {
                    json.put("title", object);
                }else{
                    items = array;
                }
            }else{
                items = json;
            }
            PageActivity mPageActivity = ((PageActivity) webView.getContext());
            mPageActivity.setNavigationItems(items, "right", result -> {
                if (callback != null) {
                    eeui.MCallback(callback).invokeAndKeepAlive(result);
                }
            });
        }
    }

    public static void show(ExtendWebView webView) {
        if (webView.getContext() instanceof PageActivity) {
            PageActivity mPageActivity = ((PageActivity) webView.getContext());
            mPageActivity.showNavigation();
        }
    }

    public static void hide(ExtendWebView webView) {
        if (webView.getContext() instanceof PageActivity) {
            PageActivity mPageActivity = ((PageActivity) webView.getContext());
            mPageActivity.hideNavigation();
        }
    }
}
