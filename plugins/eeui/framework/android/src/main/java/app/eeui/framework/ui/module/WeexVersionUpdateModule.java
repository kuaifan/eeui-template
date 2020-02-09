package app.eeui.framework.ui.module;

import com.taobao.weex.annotation.JSMethod;
import com.taobao.weex.common.WXModule;

import app.eeui.framework.extend.module.eeuiVersionUpdate;


public class WeexVersionUpdateModule extends WXModule {

    @JSMethod(uiThread = false)
    public String getTitle() {
        return eeuiVersionUpdate.getTitle();
    }

    @JSMethod(uiThread = false)
    public String getContent() {
        return eeuiVersionUpdate.getContent();
    }

    @JSMethod(uiThread = false)
    public boolean canCancel() {
        return eeuiVersionUpdate.isCanCancel();
    }

    @JSMethod
    public void closeUpdate() {
        eeuiVersionUpdate.closeUpdate();
    }

    @JSMethod
    public void startUpdate() {
        eeuiVersionUpdate.startUpdate(mWXSDKInstance.getContext());
    }
}
