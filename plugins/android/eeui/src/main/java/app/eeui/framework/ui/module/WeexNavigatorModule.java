package app.eeui.framework.ui.module;

import android.app.Activity;

import com.alibaba.fastjson.JSONObject;
import com.taobao.weex.annotation.JSMethod;
import com.taobao.weex.bridge.JSCallback;
import com.taobao.weex.common.WXModule;

import app.eeui.framework.extend.module.eeuiJson;
import app.eeui.framework.extend.module.eeuiPage;
import app.eeui.framework.ui.eeui;

public class WeexNavigatorModule extends WXModule {

    private eeui __obj;

    private eeui myApp() {
        if (__obj == null) {
            __obj = new eeui();
        }
        return __obj;
    }

    /***************************************************************************************************/
    /***************************************************************************************************/
    /***************************************************************************************************/

    @JSMethod
    public void push(String object, JSCallback callback) {
        JSONObject json = eeuiJson.parseObject(object);
        if (json.size() == 0) {
            json.put("url", object);
        }
        String pageTitle = eeuiJson.getString(json, "pageTitle", "");
        json.put("pageTitle", json.containsKey("pageTitle") ? pageTitle : " ");
        myApp().openPage(mWXSDKInstance, json.toJSONString(), callback);
    }

    @JSMethod
    public void pop(String object, JSCallback callback) {
        JSONObject json = eeuiJson.parseObject(object);
        if (eeuiJson.getString(json, "pageName", null) == null) {
            json.put("pageName", eeuiPage.getPageName((Activity) mWXSDKInstance.getContext()));
        }
        if (callback != null) {
            json.put("listenerName", "__navigatorPop");
            myApp().setPageStatusListener(mWXSDKInstance.getContext(), json.toJSONString(), callback);
        }
        myApp().closePage(mWXSDKInstance.getContext(), json.toJSONString());
    }
}
