package app.eeui.framework.ui.module;

import com.alibaba.fastjson.JSONObject;
import com.taobao.weex.annotation.JSMethod;
import com.taobao.weex.common.WXModule;

import app.eeui.framework.ui.eeui;

public class WeexEventModule extends WXModule {

    private eeui __obj;

    private eeui myApp() {
        if (__obj == null) {
            __obj = new eeui();
        }
        return __obj;
    }

    @JSMethod
    public void openURL(String url) {
        JSONObject params = new JSONObject();
        params.put("url", url);
        myApp().openPage(mWXSDKInstance, params.toJSONString(), null);
    }
}
