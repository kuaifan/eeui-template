package app.eeui.framework.ui.module;

import com.alibaba.fastjson.JSONArray;
import com.alibaba.fastjson.JSONObject;
import com.taobao.weex.annotation.JSMethod;
import com.taobao.weex.bridge.JSCallback;
import com.taobao.weex.common.WXModule;

import app.eeui.framework.BuildConfig;
import app.eeui.framework.activity.PageActivity;
import app.eeui.framework.extend.module.eeuiJson;


public class WeexDebugModule extends WXModule {

    private static JSCallback mJSCallback = null;
    private static JSONArray historys = null;

    @JSMethod
    public void addLog(String type, Object log) {
        if (BuildConfig.DEBUG) {
            if (historys == null) {
                historys = new JSONArray();
            }
            JSONObject data = new JSONObject();
            data.put("type", type);
            data.put("text", log);
            data.put("time", (int) (System.currentTimeMillis() / 1000));
            if (mJSCallback != null) {
                mJSCallback.invokeAndKeepAlive(data);
            }
            if (historys.size() > 1200) {
                JSONArray tmpLists = new JSONArray();
                for (int i = 0; i < historys.size(); i++) {
                    if (i > 200) {
                        tmpLists.add(eeuiJson.parseObject(historys.get(i)));
                    }
                }
                historys = tmpLists;
            }
            historys.add(data);
        }
    }

    @JSMethod
    public void getLog(String type, JSCallback callback) {
        if (callback == null || historys == null) {
            return;
        }
        JSONArray tmpLists = new JSONArray();
        for (int i = 0; i < historys.size(); i++) {
            JSONObject item = eeuiJson.parseObject(historys.get(i));
            if (eeuiJson.getString(item, "type").contentEquals(type)) {
                tmpLists.add(item);
            }
        }
        callback.invoke(tmpLists);
    }

    @JSMethod
    public void getLogAll(JSCallback callback) {
        if (callback == null || historys == null) {
            return;
        }
        callback.invoke(historys);
    }

    @JSMethod
    public void clearLog(String type) {
        if (historys == null) {
            return;
        }
        JSONArray tmpLists = new JSONArray();
        for (int i = 0; i < historys.size(); i++) {
            JSONObject item = eeuiJson.parseObject(historys.get(i));
            if (!eeuiJson.getString(item, "type").contentEquals(type)) {
                tmpLists.add(item);
            }
        }
        historys = tmpLists;
    }

    @JSMethod
    public void clearLogAll() {
        if (historys == null) {
            return;
        }
        historys = new JSONArray();
    }

    @JSMethod
    public void setLogListener(JSCallback callback) {
        mJSCallback = callback;
    }

    @JSMethod
    public void removeLogListener() {
        mJSCallback = null;
    }

    @JSMethod
    public void openConsole() {
        if (mWXSDKInstance.getContext() instanceof PageActivity) {
            PageActivity mActivity = (PageActivity) mWXSDKInstance.getContext();
            mActivity.showConsole();
        }
    }

    @JSMethod
    public void closeConsole() {
        if (mWXSDKInstance.getContext() instanceof PageActivity) {
            PageActivity mActivity = (PageActivity) mWXSDKInstance.getContext();
            mActivity.closeConsole();
        }
    }
}
