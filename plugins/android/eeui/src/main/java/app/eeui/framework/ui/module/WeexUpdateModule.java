package app.eeui.framework.ui.module;

import com.taobao.weex.annotation.JSMethod;
import com.taobao.weex.common.WXModule;

import app.eeui.framework.extend.module.eeuiUpdate;


public class WeexUpdateModule extends WXModule {

    @JSMethod(uiThread = false)
    public String getTitle() {
        return eeuiUpdate.getTitle();
    }

    @JSMethod(uiThread = false)
    public String getContent() {
        return eeuiUpdate.getContent();
    }

    @JSMethod(uiThread = false)
    public boolean canCancel() {
        return eeuiUpdate.isCanCancel();
    }

    @JSMethod
    public void closeUpdate() {
        eeuiUpdate.closeUpdate();
    }

    @JSMethod
    public void startUpdate() {
        eeuiUpdate.startUpdate();
    }
}
