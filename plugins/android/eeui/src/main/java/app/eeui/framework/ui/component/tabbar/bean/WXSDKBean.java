package app.eeui.framework.ui.component.tabbar.bean;


import android.support.v4.widget.SwipeRefreshLayout;
import android.view.View;
import android.widget.FrameLayout;
import android.widget.TextView;

import com.taobao.weex.WXSDKInstance;

public class WXSDKBean {

    private boolean loaded;

    private FrameLayout container;
    private View progress;
    private View errorView;
    private TextView errorCodeView;

    private WXSDKInstance instance;

    private String type = "";
    private Object params;
    private long cache = 0;

    private Object view;

    private String errorMsg = "";

    public boolean isLoaded() {
        return loaded;
    }

    public void setLoaded(boolean loaded) {
        this.loaded = loaded;
    }

    public FrameLayout getContainer() {
        return container;
    }

    public void setContainer(FrameLayout container) {
        this.container = container;
    }

    public View getProgress() {
        return progress;
    }

    public void setProgress(View progress) {
        this.progress = progress;
    }

    public View getErrorView() {
        return errorView;
    }

    public void setErrorView(View errorView) {
        this.errorView = errorView;
    }

    public TextView getErrorCodeView() {
        return errorCodeView;
    }

    public void setErrorCodeView(TextView errorCodeView) {
        this.errorCodeView = errorCodeView;
    }

    public WXSDKInstance getInstance() {
        return instance;
    }

    public void setInstance(WXSDKInstance instance) {
        this.instance = instance;
    }

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }

    public Object getParams() {
        return params;
    }

    public void setParams(Object params) {
        this.params = params;
    }

    public long getCache() {
        return cache;
    }

    public void setCache(long cache) {
        this.cache = cache;
    }

    public Object getView() {
        return view;
    }

    public void setView(Object view) {
        this.view = view;
    }

    public void setErrorMsg(String errorMsg) {
        this.errorMsg = errorMsg;
    }

    public String getErrorMsg() {
        return errorMsg;
    }
}
