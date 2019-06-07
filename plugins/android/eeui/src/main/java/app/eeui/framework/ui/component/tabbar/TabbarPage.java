package app.eeui.framework.ui.component.tabbar;

import android.content.Context;
import android.support.annotation.NonNull;

import com.alibaba.fastjson.JSONObject;

import com.taobao.weex.WXSDKInstance;
import com.taobao.weex.ui.action.BasicComponentData;
import com.taobao.weex.ui.component.WXVContainer;

import java.util.HashMap;
import java.util.Map;

import app.eeui.framework.extend.module.eeuiCommon;
import app.eeui.framework.extend.module.eeuiJson;
import app.eeui.framework.extend.module.eeuiParse;
import app.eeui.framework.ui.component.tabbar.bean.TabbarBean;


/**
 * Created by WDM on 2018/3/9.
 */

public class TabbarPage extends WXVContainer<TabbarPageView> {

    private TabbarPageView mView;

    public TabbarPage(WXSDKInstance instance, WXVContainer parent, BasicComponentData basicComponentData) {
        super(instance, parent, basicComponentData);
    }

    @Override
    protected TabbarPageView initComponentHostView(@NonNull Context context) {
        if (getParent() instanceof Tabbar) {
            mView = new TabbarPageView(context);
            formatAttrs(getAttrs());
            return mView;
        }
        return null;
    }

    private void formatAttrs(Map<String, Object> attr) {
        if (attr != null) {
            TabbarBean barBean = mView.getBarBean();
            for (String key : attr.keySet()) {
                Object value = attr.get(key);
                switch (key) {
                    case "eeui":
                        JSONObject json = eeuiJson.parseObject(eeuiParse.parseStr(value, null));
                        if (json.size() > 0) {
                            Map<String, Object> data = new HashMap<>();
                            for (Map.Entry<String, Object> entry : json.entrySet()) {
                                data.put(entry.getKey(), entry.getValue());
                            }
                            formatAttrs(data);
                        }
                        break;
                }
                barBean = setBarAttr(barBean, key, value);
            }
            mView.setBarBean(barBean);
        }
    }

    public static TabbarBean setBarAttr(TabbarBean barBean, String key, Object value) {
        if (barBean == null) {
            barBean = new TabbarBean();
        }
        switch (eeuiCommon.camelCaseName(key)) {
            case "tabName":
                barBean.setTabName(eeuiParse.parseStr(value, barBean.getTabName()));
                break;

            case "title":
                barBean.setTitle(eeuiParse.parseStr(value, barBean.getTitle()));
                break;

            case "url":
                barBean.setUrl(eeuiParse.parseStr(value, ""));
                break;

            case "unSelectedIcon":
                barBean.setUnSelectedIcon(eeuiParse.parseStr(value, ""));
                break;

            case "selectedIcon":
                barBean.setSelectedIcon(eeuiParse.parseStr(value, ""));
                break;

            case "cache":
                barBean.setCache(eeuiParse.parseLong(value, 0));
                break;

            case "params":
                barBean.setParams(value);
                break;

            case "message":
                barBean.setMessage(eeuiParse.parseInt(value, 0));
                break;

            case "dot":
                barBean.setDot(eeuiParse.parseBool(value, false));
                break;

            case "statusBarColor":
                barBean.setStatusBarColor(eeuiParse.parseStr(value, "#00000000"));
                break;
        }
        return barBean;
    }
}
