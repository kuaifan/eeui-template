package app.eeui.framework.ui.component.a;

import android.content.Context;

import androidx.annotation.NonNull;

import com.alibaba.fastjson.JSONObject;
import com.taobao.weex.WXSDKInstance;
import com.taobao.weex.dom.WXAttr;
import com.taobao.weex.ui.action.BasicComponentData;
import com.taobao.weex.ui.component.WXDiv;
import com.taobao.weex.ui.component.WXVContainer;
import com.taobao.weex.ui.view.WXFrameLayout;

import java.util.Map;

import app.eeui.framework.extend.module.eeuiCommon;
import app.eeui.framework.extend.module.eeuiConstants;
import app.eeui.framework.extend.module.eeuiJson;
import app.eeui.framework.extend.module.eeuiParse;
import app.eeui.framework.ui.eeui;


public class A extends WXDiv {

    private JSONObject params = new JSONObject();

    private eeui __obj;

    private eeui myApp() {
        if (__obj == null) {
            __obj = new eeui();
        }
        return __obj;
    }

    public A(WXSDKInstance instance, WXVContainer parent, BasicComponentData basicComponentData) {
        super(instance, parent, basicComponentData);
    }

    @Override
    protected WXFrameLayout initComponentHostView(@NonNull Context context) {
        if (getEvents().contains(eeuiConstants.Event.READY)) {
            fireEvent(eeuiConstants.Event.READY, null);
        }
        return super.initComponentHostView(context);
    }

    @Override
    protected void onHostViewInitialized(WXFrameLayout host) {
        addClickListener(() -> {
            WXAttr attr = getAttrs();
            for (Map.Entry<String, Object> entry : attr.entrySet()) {
                initProperty(entry.getKey(), entry.getValue());
            }
            String url = eeuiJson.getString(params, "url");
            if (url.equals("-1")) {
                myApp().closePage(getContext(), null);
            }else if (!url.equals("")) {
                myApp().openPage(getInstance(), params.toJSONString(), null);
            }
        });
        super.onHostViewInitialized(host);
    }

    private void initProperty(String key, Object val) {
        String nkey = eeuiCommon.camelCaseName(key);
        switch (nkey) {
            case "eeui":
                JSONObject json = eeuiJson.parseObject(eeuiParse.parseStr(val, ""));
                if (json.size() > 0) {
                    for (Map.Entry<String, Object> entry : json.entrySet()) {
                        initProperty(entry.getKey(), entry.getValue());
                    }
                }
                return;

            case "href":
                params.put("url", eeuiParse.parseStr(val, null));
                return;

            default:
                if (nkey.startsWith("@")) {
                    return;
                }
                params.put(nkey, val);
        }
    }
}
