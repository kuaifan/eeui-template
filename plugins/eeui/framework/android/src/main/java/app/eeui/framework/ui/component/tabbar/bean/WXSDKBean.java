package app.eeui.framework.ui.component.tabbar.bean;


import android.view.View;
import android.widget.FrameLayout;
import android.widget.TextView;

import com.taobao.weex.WXSDKInstance;

public class WXSDKBean {

    private boolean loaded;

    private FrameLayout container;
    private View progress;
    private View progressBackground;
    private View errorView;
    private TextView errorCodeView;

    private WXSDKInstance instance;

    private String tabName = "";
    private String type = "";
    private Object params;
    private long cache = 0;
    private boolean loading = true;
    private boolean loadingBackground = false;

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

    public View getProgressBackground() {
        return progressBackground;
    }

    public void setProgressBackground(View progressBackground) {
        this.progressBackground = progressBackground;
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

    public String getTabName() {
        return tabName;
    }

    public void setTabName(String tabName) {
        this.tabName = tabName;
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

    public boolean isLoading() {
        return loading;
    }

    public void setLoading(boolean loading) {
        this.loading = loading;
    }

    public boolean isLoadingBackground() {
        return loadingBackground;
    }

    public void setLoadingBackground(boolean loadingBackground) {
        this.loadingBackground = loadingBackground;
    }

    public void setErrorMsg(String errorMsg) {
        this.errorMsg = errorMsg;
    }

    public String getErrorMsg() {
        return errorMsg;
    }
}
