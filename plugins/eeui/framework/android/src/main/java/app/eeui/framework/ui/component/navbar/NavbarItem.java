package app.eeui.framework.ui.component.navbar;

import android.content.Context;
import androidx.annotation.NonNull;

import com.taobao.weex.WXSDKInstance;
import com.taobao.weex.common.Constants;
import com.taobao.weex.dom.WXAttr;
import com.taobao.weex.ui.action.BasicComponentData;
import com.taobao.weex.ui.component.WXVContainer;

import com.alibaba.fastjson.JSONObject;
import app.eeui.framework.extend.module.eeuiJson;
import app.eeui.framework.extend.module.eeuiParse;

/**
 * Created by WDM on 2018/3/6.
 */

public class NavbarItem extends WXVContainer<NavbarItemView> {

    private static final String TAG = "NavbarItem";

    public NavbarItem(WXSDKInstance instance, WXVContainer parent, BasicComponentData basicComponentData) {
        super(instance, parent, basicComponentData);
        updateNativeStyle(Constants.Name.JUSTIFY_CONTENT, "center");
    }

    @Override
    protected NavbarItemView initComponentHostView(@NonNull Context context) {
        if (getParent() instanceof Navbar) {
            NavbarItemView mNavbarItemView = new NavbarItemView(context);
            String type = getType(getAttrs());
            mNavbarItemView.setType(type);
            if (!type.equals("title")) {
                mNavbarItemView.selectableItemBackground();
            }
            return mNavbarItemView;
        }
        return null;
    }

    private String getType(WXAttr attr) {
        JSONObject json = eeuiJson.parseObject(attr.get("eeui"));
        return eeuiJson.getString(json, "type", eeuiParse.parseStr(attr.get("type"), "title"));
    }
}
