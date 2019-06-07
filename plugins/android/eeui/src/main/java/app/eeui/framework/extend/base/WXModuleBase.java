package app.eeui.framework.extend.base;

import android.content.Context;
import com.taobao.weex.common.WXModule;
import app.eeui.framework.activity.PageActivity;

public class WXModuleBase extends WXModule {

    public PageActivity getActivity() {
        return (PageActivity) mWXSDKInstance.getContext();
    }

    public Context getContext() {
        return mWXSDKInstance.getContext();
    }
}
