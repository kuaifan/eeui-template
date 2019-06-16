package app.eeui.playground;

import android.app.Application;
import android.content.Context;
import android.support.multidex.MultiDex;

import com.alibaba.android.bindingx.plugin.weex.BindingX;
import com.alibaba.weex.plugin.loader.WeexPluginContainer;
import com.taobao.weex.WXEnvironment;
import com.taobao.weex.WXSDKEngine;
import com.taobao.weex.common.WXException;

import app.eeui.framework.BuildConfig;
import app.eeui.framework.extend.module.eeuiBase;
import app.eeui.framework.extend.module.eeui;

public class MyApplication extends Application {

    protected void attachBaseContext(Context ctx) {
        super.attachBaseContext(ctx);
        MultiDex.install(this);
    }

    @Override
    public void onCreate() {
        super.onCreate();

        WXEnvironment.setOpenDebugLog(BuildConfig.DEBUG);
        WXEnvironment.setApkDebugable(BuildConfig.DEBUG);

        WXSDKEngine.addCustomOptions("appName", eeuiBase.appName);
        WXSDKEngine.addCustomOptions("appGroup", eeuiBase.appGroup);

        eeui.init(this);

        try {
            BindingX.register();
        } catch (WXException e) {
            e.printStackTrace();
        }

        WeexPluginContainer.loadAll(this);
    }
}
