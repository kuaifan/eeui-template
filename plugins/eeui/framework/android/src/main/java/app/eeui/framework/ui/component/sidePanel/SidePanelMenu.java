package app.eeui.framework.ui.component.sidePanel;

import android.content.Context;
import androidx.annotation.NonNull;

import com.taobao.weex.WXSDKInstance;
import com.taobao.weex.dom.WXAttr;
import com.taobao.weex.ui.action.BasicComponentData;
import com.taobao.weex.ui.component.WXVContainer;

import com.alibaba.fastjson.JSONObject;
import app.eeui.framework.extend.module.eeuiCommon;
import app.eeui.framework.extend.module.eeuiJson;
import app.eeui.framework.extend.module.eeuiParse;

public class SidePanelMenu extends WXVContainer<SidePanelMenuView> {

    public SidePanelMenu(WXSDKInstance instance, WXVContainer parent, BasicComponentData basicComponentData) {
        super(instance, parent, basicComponentData);
    }

    @Override
    protected SidePanelMenuView initComponentHostView(@NonNull Context context) {
        SidePanelMenuView view = new SidePanelMenuView(context);
        if (getParent() instanceof SidePanel) {
            SidePanel panel = (SidePanel) getParent();
            view.setName(getName(getAttrs()));
            view.setTag(panel.getMenuNum());
            view.setOnClickListener(panel.menuClick);
            view.setOnLongClickListener(panel.menuLongClick);
            panel.menuNumPlusOne();
            return view;
        }
        return null;
    }

    private String getName(WXAttr attr) {
        JSONObject json = eeuiJson.parseObject(attr.get("eeui"));
        return eeuiJson.getString(json, "name", eeuiParse.parseStr(attr.get("name"), eeuiCommon.randomString(6)));
    }
}
