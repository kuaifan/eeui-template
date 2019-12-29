package app.eeui.framework.extend.bean;

import android.app.Activity;
import android.content.Context;

import com.alibaba.fastjson.JSONObject;
import com.taobao.weex.bridge.JSCallback;

import java.util.HashMap;
import java.util.Map;

/**
 * Created by WDM on 2018/3/7.
 */

public class PageBean {


    public Map<String, Object> toMap() {
        Map<String, Object> temp = new HashMap<>();
        temp.put("url", getUrl());
        temp.put("pageName", getPageName());
        temp.put("pageTitle", getPageTitle());
        temp.put("pageType", getPageType());
        temp.put("params", getParams());
        temp.put("cache", getCache());
        temp.put("loading", isLoading());
        temp.put("loadingBackground", isLoadingBackground());
        temp.put("loadTime", getLoadTime());
        temp.put("swipeBack", isSwipeBack());
        temp.put("swipeFullBack", isSwipeFullBack());
        temp.put("swipeColorBack", isSwipeColorBack());
        temp.put("animated", isAnimated());
        temp.put("animatedType", getAnimatedType());
        temp.put("animatedClose", isAnimatedClose());
        temp.put("statusBarType", getStatusBarType());
        temp.put("statusBarColor", getStatusBarColor());
        temp.put("statusBarAlpha", getStatusBarAlpha());
        temp.put("statusBarStyle", getStatusBarStyle());
        temp.put("softInputMode", getSoftInputMode());
        temp.put("translucent", isTranslucent());
        temp.put("backgroundColor", getBackgroundColor());
        temp.put("backPressedClose", isBackPressedClose());
        return temp;
    }

    /**
     * url :                网址
     * pageName :           页面标识（可选）
     * pageTitle :          页面标题（可选）
     * pageType :           类型（可选，如：web|app，默认：app）
     * params :             传递参数（可选）
     * cache :              缓存时间（可选，单位：毫秒，仅weex有效，默认：0不启用）
     * loading :            是否显示等待（可选，默认：true）
     * loadingBackground :  是否显示等待过渡背景（可选，默认：false）
     * swipeBack :          是否支持滑动返回（可选，默认：true，首页默认：false）
     * swipeFullBack :      是否支持全屏滑动返回（可选，默认：false）
     * swipeColorBack :     是否为滑动返回界面设置状态栏颜色跟随滑动（可选，默认：true，首页默认：false）
     * animated :           是否进入页面需要动画效果（可选，默认：true）
     * animatedType :       页面动画效果类型（可选，默认：跟随系统）
     * animatedClose :      是否关闭页面需要动画效果（可选，默认：true）
     * statusBarType :      状态栏样式（可选，等于fullscreen|immersion时statusBarType、statusBarAlpha无效）
     * statusBarColor :     状态栏颜色值（可选，默认：#3EB4FF）
     * statusBarAlpha : 0   状态栏透明度（可选，默认：0）
     * statusBarStyle :     状态栏样式（可选，默认：null）
     * softInputMode :      键盘弹出方式（可选，默认：auto）
     * translucent :        透明底色窗口（可选，默认：false）
     * backgroundColor :    页面背景颜色（可选，默认：#ffffff）
     * backPressedClose :   返回键关闭（可选，默认：true）
     * callback :           JS回调事件（可选）
     *
     * firstPage :          是否为启动页（可选，默认：false，内部使用）
     * resumeUrl :          页面恢复时访问的网址（可选，默认：空，内部使用）
     *
     * context :            上下文
     */

    private String url;
    private String pageName;
    private String pageTitle;
    private String pageType = "app";
    private Object params;
    private long cache = 0;
    private boolean loading = true;
    private boolean loadingBackground = false;
    private boolean swipeBack = true;
    private boolean swipeFullBack = false;
    private boolean swipeColorBack = true;
    private boolean animated = true;
    private String animatedType = "";
    private boolean animatedClose = true;
    private String statusBarType = "normal";
    private String statusBarColor = "";
    private int statusBarAlpha = 0;
    private Boolean statusBarStyle = null;
    private String softInputMode = "auto";
    private boolean translucent = false;
    private String backgroundColor = "";
    private boolean backPressedClose = true;
    private boolean firstPage = false;
    private String resumeUrl = "";
    private JSCallback callback;
    private Context context;
    private JSONObject otherObject;
    private long loadTime = 0;

    public String getPageName() {
        return pageName;
    }

    public void setPageName(String pageName) {
        this.pageName = pageName;
    }

    public String getPageTitle() {
        return pageTitle;
    }

    public void setPageTitle(String pageTitle) {
        this.pageTitle = pageTitle;
    }

    public String getUrl() {
        return url;
    }

    public void setUrl(String url) {
        this.url = url;
    }

    public String getPageType() {
        return pageType;
    }

    public void setPageType(String pageType) {
        this.pageType = pageType;
    }

    public Object getParams() {
        return params;
    }

    public void setData(Object params) {
        this.params = params;
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

    public boolean isSwipeBack() {
        return swipeBack;
    }

    public void setSwipeBack(boolean swipeBack) {
        this.swipeBack = swipeBack;
    }

    public boolean isSwipeFullBack() {
        return swipeFullBack;
    }

    public void setSwipeFullBack(boolean swipeFullBack) {
        this.swipeFullBack = swipeFullBack;
    }

    public boolean isSwipeColorBack() {
        return swipeColorBack;
    }

    public void setSwipeColorBack(boolean swipeColorBack) {
        this.swipeColorBack = swipeColorBack;
    }

    public boolean isAnimated() {
        return animated;
    }

    public void setAnimated(boolean animated) {
        this.animated = animated;
    }

    public String getAnimatedType() {
        return animatedType;
    }

    public void setAnimatedType(String animatedType) {
        this.animatedType = animatedType;
    }

    public boolean isAnimatedClose() {
        return animatedClose;
    }

    public void setAnimatedClose(boolean animatedClose) {
        this.animatedClose = animatedClose;
    }

    public String getStatusBarType() {
        return statusBarType;
    }

    public void setStatusBarType(String statusBarType) {
        this.statusBarType = statusBarType;
    }

    public String getStatusBarColor() {
        return statusBarColor;
    }

    public void setStatusBarColor(String statusBarColor) {
        this.statusBarColor = statusBarColor;
    }

    public int getStatusBarAlpha() {
        return statusBarAlpha;
    }

    public void setStatusBarAlpha(int statusBarAlpha) {
        this.statusBarAlpha = statusBarAlpha;
    }

    public Boolean getStatusBarStyle() {
        return statusBarStyle;
    }

    public void setStatusBarStyle(Boolean statusBarStyle) {
        this.statusBarStyle = statusBarStyle;
    }

    public String getSoftInputMode() {
        return softInputMode;
    }

    public void setSoftInputMode(String softInputMode) {
        this.softInputMode = softInputMode;
    }

    public boolean isTranslucent() {
        return translucent;
    }

    public void setTranslucent(boolean translucent) {
        this.translucent = translucent;
    }

    public String getBackgroundColor() {
        return backgroundColor;
    }

    public void setBackgroundColor(String backgroundColor) {
        this.backgroundColor = backgroundColor;
    }

    public boolean isBackPressedClose() {
        return backPressedClose;
    }

    public void setBackPressedClose(boolean backPressedClose) {
        this.backPressedClose = backPressedClose;
    }

    public boolean isFirstPage() {
        return firstPage;
    }

    public void setFirstPage(boolean firstPage) {
        this.firstPage = firstPage;
    }

    public void setResumeUrl(String resumeUrl) {
        this.resumeUrl = resumeUrl;
    }

    public String getResumeUrl() {
        return resumeUrl;
    }

    public JSCallback getCallback() {
        return callback;
    }

    public void setCallback(JSCallback callback) {
        this.callback = callback;
    }

    public Activity getActivity() {
        return (Activity) context;
    }

    public Context getContext() {
        return context;
    }

    public void setContext(Context context) {
        this.context = context;
    }

    public JSONObject getOtherObject() {
        return otherObject;
    }

    public void setOtherObject(JSONObject otherObject) {
        this.otherObject = otherObject;
    }

    public long getLoadTime() {
        return loadTime;
    }

    public void setLoadTime(long loadTime) {
        this.loadTime = loadTime;
    }
}
