package app.eeui.framework.ui.module;

import android.app.Activity;

import com.alibaba.fastjson.JSONObject;

import app.eeui.framework.extend.module.eeuiJson;
import app.eeui.framework.extend.module.eeuiPage;
import app.eeui.framework.extend.view.ExtendWebView;
import app.eeui.framework.extend.view.webviewBridge.JsCallback;
import app.eeui.framework.ui.eeui;

public class WebNavigatorModule {

    private static eeui __obj;

    private static eeui myApp() {
        if (__obj == null) {
            __obj = new eeui();
        }
        return __obj;
    }

    /***************************************************************************************************/
    /***************************************************************************************************/
    /***************************************************************************************************/

    public static void push(ExtendWebView webView, String object, JsCallback callback) {
        JSONObject json = eeuiJson.parseObject(object);
        if (json.size() == 0) {
            json.put("url", object);
        }
        json.put("pageTitle", eeuiJson.getString(json, "pageTitle", " "));
        myApp().openPage(webView, json.toJSONString(), eeui.MCallback(callback));
    }

    public static void pop(ExtendWebView webView, String object, JsCallback callback) {
        JSONObject json = eeuiJson.parseObject(object);
        if (eeuiJson.getString(json, "pageName", null) == null) {
            json.put("pageName", eeuiPage.getPageName((Activity) webView.getContext()));
        }
        if (callback != null) {
            json.put("listenerName", "__navigatorPop");
            myApp().setPageStatusListener(webView.getContext(), json.toJSONString(), eeui.MCallback(callback));
        }
        myApp().closePage(webView.getContext(), json.toJSONString());
    }
}
