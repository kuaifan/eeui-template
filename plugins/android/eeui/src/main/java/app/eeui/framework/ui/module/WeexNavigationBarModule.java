package app.eeui.framework.ui.module;

import com.alibaba.fastjson.JSONArray;
import com.alibaba.fastjson.JSONObject;
import com.taobao.weex.annotation.JSMethod;
import com.taobao.weex.bridge.JSCallback;
import com.taobao.weex.common.WXModule;

import app.eeui.framework.activity.PageActivity;
import app.eeui.framework.extend.module.eeuiJson;

public class WeexNavigationBarModule extends WXModule {

    @JSMethod
    public void setTitle(String object, JSCallback callback) {
        if (mWXSDKInstance.getContext() instanceof PageActivity) {
            JSONObject json = eeuiJson.parseObject(object);
            if (json.size() == 0) {
                json.put("title", object);
            }
            PageActivity mPageActivity = ((PageActivity) mWXSDKInstance.getContext());
            mPageActivity.setNavigationTitle(json, result -> {
                if (callback != null) {
                    callback.invokeAndKeepAlive(result);
                }
            });
        }
    }

    @JSMethod
    public void setLeftItem(String object, JSCallback callback) {
        if (mWXSDKInstance.getContext() instanceof PageActivity) {
            Object items = null;
            JSONObject json = eeuiJson.parseObject(object);
            if (json.size() == 0) {
                JSONArray array = eeuiJson.parseArray(object);
                if (array.size() == 0) {
                    json.put("title", object);
                }else{
                    items = array;
                }
            }else{
                items = json;
            }
            PageActivity mPageActivity = ((PageActivity) mWXSDKInstance.getContext());
            mPageActivity.setNavigationItems(items, "left", result -> {
                if (callback != null) {
                    callback.invokeAndKeepAlive(result);
                }
            });
        }
    }

    @JSMethod
    public void setRightItem(String object, JSCallback callback) {
        if (mWXSDKInstance.getContext() instanceof PageActivity) {
            Object items = null;
            JSONObject json = eeuiJson.parseObject(object);
            if (json.size() == 0) {
                JSONArray array = eeuiJson.parseArray(object);
                if (array.size() == 0) {
                    json.put("title", object);
                }else{
                    items = array;
                }
            }else{
                items = json;
            }
            PageActivity mPageActivity = ((PageActivity) mWXSDKInstance.getContext());
            mPageActivity.setNavigationItems(items, "right", result -> {
                if (callback != null) {
                    callback.invokeAndKeepAlive(result);
                }
            });
        }
    }

    @JSMethod
    public void show() {
        if (mWXSDKInstance.getContext() instanceof PageActivity) {
            PageActivity mPageActivity = ((PageActivity) mWXSDKInstance.getContext());
            mPageActivity.showNavigation();
        }
    }

    @JSMethod
    public void hide() {
        if (mWXSDKInstance.getContext() instanceof PageActivity) {
            PageActivity mPageActivity = ((PageActivity) mWXSDKInstance.getContext());
            mPageActivity.hideNavigation();
        }
    }
}
