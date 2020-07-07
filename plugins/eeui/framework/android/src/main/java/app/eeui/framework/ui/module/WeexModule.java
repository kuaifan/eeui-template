package app.eeui.framework.ui.module;

import com.alibaba.fastjson.JSONObject;
import com.taobao.weex.annotation.JSMethod;
import com.taobao.weex.bridge.JSCallback;
import com.taobao.weex.common.WXModule;

import java.util.HashMap;
import java.util.Map;

import app.eeui.framework.ui.eeui;

public class WeexModule extends WXModule {

    private static final String TAG = "eeui";

    private eeui __obj;

    private eeui myApp() {
        if (__obj == null) {
            __obj = new eeui();
        }
        return __obj;
    }

    /***************************************************************************************************/
    /***************************************************************************************************/
    /***************************************************************************************************/

    /**
     * 打开页面 或 打开网页（内置浏览器）
     * @param object
     * @param callback
     */
    @JSMethod
    public void openPage(String object, JSCallback callback) {
        myApp().openPage(mWXSDKInstance, object, callback);
    }

    /**
     * 获取页面信息
     * @param object
     * @return
     */
    @JSMethod(uiThread = false)
    public Object getPageInfo(String object) {
        return myApp().getPageInfo(mWXSDKInstance.getContext(), object);
    }

    /**
     * 获取页面信息（异步）
     * @param object
     * @return
     */
    @JSMethod
    public void getPageInfoAsync(String object, JSCallback callback) {
        myApp().getPageInfoAsync(mWXSDKInstance.getContext(), object, callback);
    }

    /**
     * 获取页面传递的参数
     * @param object
     * @return
     */
    @JSMethod(uiThread = false)
    public Object getPageParams(String object) {
        return myApp().getPageParams(mWXSDKInstance.getContext(), object);
    }

    /**
     * 重新加载页面（刷新）
     * @param object
     */
    @JSMethod
    public void reloadPage(String object) {
        myApp().reloadPage(mWXSDKInstance.getContext(), object);
    }

    /**
     * 关闭页面 或 关闭网页（内置浏览器）
     * @param object
     */
    @JSMethod
    public void closePage(String object) {
        myApp().closePage(mWXSDKInstance.getContext(), object);
    }


    /**
     * 关闭页面至指定页面
     * @param object
     */
    @JSMethod
    public void closePageTo(String object) {
        myApp().closePageTo(mWXSDKInstance.getContext(), object);
    }

    /**
     * 设置键盘弹出方式
     * @param object
     * @param mode
     */
    @JSMethod
    public void setSoftInputMode(String object, String mode) {
        myApp().setSoftInputMode(mWXSDKInstance.getContext(), object, mode);
    }

    /**
     * 修改状态栏字体颜色风格
     * @param isLight 是否亮色
     */
    @JSMethod
    public void setStatusBarStyle(boolean isLight) {
        myApp().setStatusBarStyle(mWXSDKInstance.getContext(), isLight);
    }

    /**
     * 修改状态栏字体颜色风格
     * @param isLight 是否亮色
     */
    @JSMethod
    public void statusBarStyle(boolean isLight) {
        myApp().setStatusBarStyle(mWXSDKInstance.getContext(), isLight);
    }

    /**
     * 拦截返回按键事件
     * @param object
     * @param callback  为null时取消拦截
     */
    @JSMethod
    public void setPageBackPressed(String object, JSCallback callback) {
        myApp().setPageBackPressed(mWXSDKInstance.getContext(), object, callback);
    }

    /**
     * 监听下拉刷新事件
     * @param object
     * @param callback  为null时取消监听
     */
    @JSMethod
    public void setOnRefreshListener(String object, JSCallback callback) {
        myApp().setOnRefreshListener(mWXSDKInstance.getContext(), object, callback);
    }

    /**
     * 设置下拉刷新状态
     * @param object
     * @param refreshing
     */
    @JSMethod
    public void setRefreshing(String object, boolean refreshing) {
        myApp().setRefreshing(mWXSDKInstance.getContext(), object, refreshing);
    }

    /**
     * 监听页面状态变化
     * @param object
     * @param callback
     */
    @JSMethod
    public void setPageStatusListener(String object, JSCallback callback) {
        myApp().setPageStatusListener(mWXSDKInstance.getContext(), object, callback);
    }

    /**
     * 取消监听页面状态变化
     * @param object
     */
    @JSMethod
    public void clearPageStatusListener(String object) {
        myApp().clearPageStatusListener(mWXSDKInstance.getContext(), object);
    }

    /**
     * 手动执行(触发)页面状态
     * @param object
     * @param status
     */
    @JSMethod
    public void onPageStatusListener(String object, String status) {
        myApp().onPageStatusListener(mWXSDKInstance.getContext(), object, status);
    }

    /**
     * 向指定页面发送信息
     * @param object
     */
    @JSMethod
    public void postMessage(String object) {
        myApp().postMessage(mWXSDKInstance.getContext(), object);
    }

    /**
     * 获取页面缓存大小
     */
    @JSMethod
    public void getCacheSizePage(JSCallback callback) {
        myApp().getCacheSizePage(mWXSDKInstance.getContext(), callback);
    }

    /**
     * 清除缓存页面
     */
    @JSMethod
    public void clearCachePage() {
        myApp().clearCachePage(mWXSDKInstance.getContext());
    }

    /**
     * 打开网页（系统浏览器）
     * @param url
     */
    @JSMethod
    public void openWeb(String url) {
        myApp().openWeb(mWXSDKInstance.getContext(), url);
    }

    /**
     * 返回桌面
     */
    @JSMethod
    public void goDesktop() {
        myApp().goDesktop(mWXSDKInstance.getContext());
    }

    /**
     * 获取eeui.config.js配置指定参数
     * @param key
     * @return
     */
    @JSMethod(uiThread = false)
    public Object getConfigRaw(String key) {
        return myApp().getConfigRaw(key);
    }

    /**
     * 获取eeui.config.js配置指定参数
     * @param key
     * @return
     */
    @JSMethod(uiThread = false)
    public String getConfigString(String key) {
        return myApp().getConfigString(key);
    }

    /**
     * 设置自定义配置
     * @param key
     * @param value
     */
    @JSMethod(uiThread = false)
    public void setCustomConfig(String key, Object value) {
        myApp().setCustomConfig(key, value);
    }

    /**
     * 获取自定义配置
     */
    @JSMethod(uiThread = false)
    public Object getCustomConfig() {
        return myApp().getCustomConfig();
    }

    /**
     * 清空自定义配置
     */
    @JSMethod(uiThread = false)
    public void clearCustomConfig() {
        myApp().clearCustomConfig();
    }

    /**
     * 规范化url，删除所有符号连接（比如'/./', '/../' 以及多余的'/'）
     * @param url
     * @return
     */
    @JSMethod(uiThread = false)
    public String realUrl(String url) {
        return myApp().realUrl(url);
    }

    /**
     * 补全地址
     * @param url
     * @return
     */
    @JSMethod(uiThread = false)
    public String rewriteUrl(String url) {
        return myApp().rewriteUrl(mWXSDKInstance, url);
    }

    /**
     * 获取已热更新至的数据ID
     * @return
     */
    @JSMethod(uiThread = false)
    public int getUpdateId() {
        return myApp().getUpdateId();
    }

    /**
     * 客户触发检测热更新
     */
    @JSMethod
    public void checkUpdate() {
        myApp().checkUpdate();
    }

    /****************************************************************************************/
    /****************************************************************************************/

    /**
     * 获取状态栏高度（屏幕像素）
     */
    @JSMethod(uiThread = false)
    public int getStatusBarHeight() {
        return myApp().getStatusBarHeight(mWXSDKInstance.getContext());
    }

    /**
     * 获取状态栏高度（weexPX单位）
     */
    @JSMethod(uiThread = false)
    public int getStatusBarHeightPx() {
        return myApp().getStatusBarHeightPx(mWXSDKInstance.getContext());
    }

    /**
     * 获取虚拟键盘高度（屏幕像素）
     */
    @JSMethod(uiThread = false)
    public int getNavigationBarHeight() {
        return myApp().getNavigationBarHeight(mWXSDKInstance.getContext());
    }

    /**
     * 获取虚拟键盘高度（weexPX单位）
     */
    @JSMethod(uiThread = false)
    public int getNavigationBarHeightPx() {
        return myApp().getNavigationBarHeightPx(mWXSDKInstance.getContext());
    }

    /**
     * 获取eeui版本号
     */
    @JSMethod(uiThread = false)
    public int getVersion() {
        return myApp().getVersion(mWXSDKInstance.getContext());
    }

    /**
     * 获取eeui版本号名称
     */
    @JSMethod(uiThread = false)
    public String getVersionName() {
        return myApp().getVersionName(mWXSDKInstance.getContext());
    }

    /**
     * 获取本地软件版本号
     */
    @JSMethod(uiThread = false)
    public int getLocalVersion() {
        return myApp().getLocalVersion(mWXSDKInstance.getContext());
    }

    /**
     * 获取本地软件版本号名称
     */
    @JSMethod(uiThread = false)
    public String getLocalVersionName() {
        return myApp().getLocalVersionName(mWXSDKInstance.getContext());
    }

    /**
     * 比较版本号的大小,前者大则返回一个正数,后者大返回一个负数,相等则返回0
     * @param version1
     * @param version2
     * @return
     */
    @JSMethod(uiThread = false)
    public int compareVersion(String version1, String version2) {
        return myApp().compareVersion(mWXSDKInstance.getContext(), version1, version2);
    }

    /**
     * 获取手机的IMEI
     */
    @JSMethod(uiThread = false)
    public String getImei() {
        return myApp().getImei(mWXSDKInstance.getContext());
    }

    /**
     * 获取手机的IFA
     */
    @JSMethod(uiThread = false)
    public String getIfa() {
        return getImei();
    }

    /**
     * 获取手机的IMEI（异步）
     */
    @JSMethod
    public void getImeiAsync(JSCallback callback) {
        if (callback == null) {
            return;
        }
        myApp().getImeiAsync(mWXSDKInstance.getContext(), imei -> {
            Map<String, Object> data = new HashMap<>();
            data.put("status", "success");
            data.put("content", imei);
            callback.invoke(data);
        });
    }

    /**
     * 获取手机的IFA（异步）
     */
    @JSMethod
    public void getIfaAsync(JSCallback callback) {
        getImeiAsync(callback);
    }

    /**
     * 获取设备系统版本号
     */
    @JSMethod(uiThread = false)
    public int getSDKVersionCode() {
        return myApp().getSDKVersionCode(mWXSDKInstance.getContext());
    }

    /**
     * 获取设备系统版本名称
     */
    @JSMethod(uiThread = false)
    public String getSDKVersionName() {
        return myApp().getSDKVersionName(mWXSDKInstance.getContext());
    }

    /**
     * 是否IPhoneX系列设配
     * @return
     */
    @JSMethod(uiThread = false)
    public boolean isIPhoneXType() {
        return myApp().isIPhoneXType(mWXSDKInstance.getContext());
    }

    /****************************************************************************************/
    /****************************************************************************************/

    /**
     * 保存缓存信息
     * @param key
     * @param value
     * @param expired
     */
    @JSMethod(uiThread = false)
    public void setCaches(String key, Object value, Long expired) {
        myApp().setCaches(mWXSDKInstance.getContext(), key, value, expired);
    }

    /**
     * 获取缓存信息
     * @param key
     * @param defaultVal
     */
    @JSMethod(uiThread = false)
    public Object getCaches(String key, Object defaultVal) {
        return myApp().getCaches(mWXSDKInstance.getContext(), key, defaultVal);
    }

    /**
     * 保存缓存信息
     * @param key
     * @param value
     * @param expired
     */
    @JSMethod(uiThread = false)
    public void setCachesString(String key, String value, Long expired) {
        myApp().setCachesString(mWXSDKInstance.getContext(), key, value, expired);
    }

    /**
     * 获取缓存信息
     * @param key
     * @param defaultVal
     */
    @JSMethod(uiThread = false)
    public String getCachesString(String key, String defaultVal) {
        return myApp().getCachesString(mWXSDKInstance.getContext(), key, defaultVal);
    }

    /**
     * 获取全部缓存信息
     */
    @JSMethod(uiThread = false)
    public JSONObject getAllCaches() {
        return myApp().getAllCaches(mWXSDKInstance.getContext());
    }

    /**
     * 清除缓存信息
     */
    @JSMethod(uiThread = false)
    public void clearAllCaches() {
        myApp().clearAllCaches(mWXSDKInstance.getContext());
    }

    /**
     * 设置全局变量
     * @param key
     * @param value
     */
    @JSMethod(uiThread = false)
    public void setVariate(String key, Object value) {
        myApp().setVariate(key, value);
    }

    /**
     * 获取全局变量
     * @param key
     * @param defaultVal
     */
    @JSMethod(uiThread = false)
    public Object getVariate(String key, Object defaultVal) {
        return myApp().getVariate(key, defaultVal);
    }

    /**
     * 获取全部变量
     */
    @JSMethod(uiThread = false)
    public JSONObject getAllVariate() {
        return myApp().getAllVariate();
    }

    /**
     * 清除全部变量
     */
    @JSMethod(uiThread = false)
    public void clearAllVariate() {
        myApp().clearAllVariate();
    }

    /****************************************************************************************/
    /****************************************************************************************/

    /**
     * 获取内部缓存目录大小
     * @param callback
     */
    @JSMethod
    public void getCacheSizeDir(JSCallback callback) {
        myApp().getCacheSizeDir(mWXSDKInstance.getContext(), callback);
    }

    /**
     * 清空内部缓存目录
     */
    @JSMethod
    public void clearCacheDir(JSCallback callback) {
        myApp().clearCacheDir(mWXSDKInstance.getContext(), callback);
    }

    /**
     * 获取内部文件目录大小
     * @param callback
     */
    @JSMethod
    public void getCacheSizeFiles(JSCallback callback) {
        myApp().getCacheSizeFiles(mWXSDKInstance.getContext(), callback);
    }

    /**
     * 清空内部文件目录
     */
    @JSMethod
    public void clearCacheFiles(JSCallback callback) {
        myApp().clearCacheFiles(mWXSDKInstance.getContext(), callback);
    }

    /**
     * 获取内部数据库目录大小
     * @param callback
     */
    @JSMethod
    public void getCacheSizeDbs(JSCallback callback) {
        myApp().getCacheSizeDbs(mWXSDKInstance.getContext(), callback);
    }

    /**
     * 清空内部数据库目录
     */
    @JSMethod
    public void clearCacheDbs(JSCallback callback) {
        myApp().clearCacheDbs(mWXSDKInstance.getContext(), callback);
    }

    /****************************************************************************************/
    /****************************************************************************************/

    /**
     * weex px转dp
     * @param var
     */
    @JSMethod(uiThread = false)
    public int weexPx2dp(String var) {
        return myApp().weexPx2dp(mWXSDKInstance.getContext(), var);
    }

    /**
     * weex dp转px
     * @param var
     */
    @JSMethod(uiThread = false)
    public int weexDp2px(String var) {
        return myApp().weexDp2px(mWXSDKInstance.getContext(), var);
    }

    /****************************************************************************************/
    /****************************************************************************************/

    /**
     * alert 警告框
     */
    @JSMethod
    public void alert(Object object, JSCallback callback) {
        myApp().alert(mWXSDKInstance.getContext(), object, callback);
    }

    /**
     * confirm 确认对话框
     */
    @JSMethod
    public void confirm(Object object, JSCallback callback) {
        myApp().confirm(mWXSDKInstance.getContext(), object, callback);
    }

    /**
     * input 输入对话框
     */
    @JSMethod
    public void input(Object object, JSCallback callback) {
        myApp().input(mWXSDKInstance.getContext(), object, callback);
    }

    /****************************************************************************************/
    /****************************************************************************************/

    /**
     * 显示等待图标
     * @param object        参数
     * @param callback      返回键或点击空白处取消回调事件
     * @return
     */
    @JSMethod(uiThread = false)
    public String loading(String object, JSCallback callback) {
        return myApp().loading(mWXSDKInstance.getContext(), object, callback);
    }

    /**
     * 关闭等待图标
     */
    @JSMethod(uiThread = false)
    public void loadingClose(String var) {
        myApp().loadingClose(mWXSDKInstance.getContext(), var);
    }

    /****************************************************************************************/
    /****************************************************************************************/

    /**
     * 打开滑动验证码
     * @param imgUrl
     * @param callback
     */
    @JSMethod
    public void swipeCaptcha(String imgUrl, JSCallback callback) {
        myApp().swipeCaptcha(mWXSDKInstance.getContext(), imgUrl, callback);
    }

    /****************************************************************************************/
    /****************************************************************************************/

    /**
     * 打开二维码扫描
     * @param object
     * @param callback
     */
    @JSMethod
    public void openScaner(String object, JSCallback callback) {
        myApp().openScaner(mWXSDKInstance.getContext(), object, callback);
    }

    /****************************************************************************************/
    /****************************************************************************************/

    /**
     * 跨域异步请求
     * @param object
     * @param callback
     */
    @JSMethod
    public void ajax(String object, JSCallback callback) {
        myApp().ajax(mWXSDKInstance.getContext(), object, callback);
    }

    /**
     * 取消跨域异步请求
     * @param name
     */
    @JSMethod
    public void ajaxCancel(String name) {
        myApp().ajaxCancel(mWXSDKInstance.getContext(), name);
    }

    /**
     * 获取异步请求缓存大小
     */
    @JSMethod
    public void getCacheSizeAjax(JSCallback callback) {
        myApp().getCacheSizeAjax(mWXSDKInstance.getContext(), callback);
    }

    /**
     * 清除异步请求缓存
     */
    @JSMethod
    public void clearCacheAjax() {
        myApp().clearCacheAjax(mWXSDKInstance.getContext());
    }

    /**
     * 获取图片尺寸
     * @param url
     * @param callback
     */
    @JSMethod
    public void getImageSize(String url, JSCallback callback) {
        myApp().getImageSize(mWXSDKInstance.getContext(), url, callback);
    }

    /****************************************************************************************/
    /****************************************************************************************/

    /**
     * 复制文本到剪贴板
     * @param var
     */
    @JSMethod
    public void copyText(String var) {
        myApp().copyText(mWXSDKInstance.getContext(), var);
    }

    /**
     * 获取剪贴板的文本
     * @return
     */
    @JSMethod(uiThread = false)
    public CharSequence pasteText() {
        return myApp().pasteText(mWXSDKInstance.getContext());
    }

    /****************************************************************************************/
    /****************************************************************************************/

    /**
     * 吐司(Toast)显示
     * @param object
     */
    @JSMethod
    public void toast(String object) {
        myApp().toast(mWXSDKInstance.getContext(), object);
    }

    /**
     * 吐司(Toast)隐藏
     */
    @JSMethod
    public void toastClose() {
        myApp().toastClose(mWXSDKInstance.getContext());
    }

    /****************************************************************************************/
    /****************************************************************************************/

    /**
     * 图片广告弹窗
     * @param object
     * @param callback
     */
    @JSMethod
    public void adDialog(String object, JSCallback callback) {
        myApp().adDialog(mWXSDKInstance.getContext(), object, callback);
    }

    /**
     * 手动关闭图片广告弹窗
     * @param dialogName
     */
    @JSMethod
    public void adDialogClose(String dialogName) {
        myApp().adDialogClose(mWXSDKInstance.getContext(), dialogName);
    }

    /****************************************************************************************/
    /****************************************************************************************/

    /**
     * 保存图片到本地
     * @param url
     */
    @JSMethod
    public void saveImage(String url, JSCallback callback) {
        myApp().saveImage(mWXSDKInstance.getContext(), url, callback);
    }

    /**
     * 保存图片到本地（自定义目录）
     * @param url
     * @param childDir
     */
    @JSMethod
    public void saveImageTo(String url, String childDir, JSCallback callback) {
        myApp().saveImageTo(mWXSDKInstance.getContext(), url, childDir, callback);
    }

    /****************************************************************************************/
    /****************************************************************************************/

    /**
     * 打开指定APP
     * @param type
     */
    @JSMethod
    public void openOtherApp(String type) {
        myApp().openOtherApp(mWXSDKInstance.getContext(), type);
    }

    /**
     * 打开其他APP
     * @param pkg
     * @param cls
     * @param callback
     */
    @JSMethod
    public void openOtherAppTo(String pkg, String cls, JSCallback callback) {
        myApp().openOtherAppTo(mWXSDKInstance.getContext(), pkg, cls, callback);
    }

    /****************************************************************************************/
    /****************************************************************************************/

    /**
     * 分享文字
     * @param text
     */
    @JSMethod
    public void shareText(String text) {
        myApp().shareText(mWXSDKInstance.getContext(), text);
    }

    /**
     * 分享图片
     * @param imgUrl
     */
    @JSMethod
    public void shareImage(String imgUrl) {
        myApp().shareImage(mWXSDKInstance.getContext(), imgUrl);
    }

    /****************************************************************************************/
    /****************************************************************************************/

    /**
     * 动态隐藏软键盘
     * @return
     */
    @JSMethod
    public void keyboardHide() {
        myApp().keyboardHide(mWXSDKInstance.getContext());
    }

    /**
     * 判断软键盘是否可见
     * @return
     */
    @JSMethod(uiThread = false)
    public Boolean keyboardStatus() {
        return (Boolean) myApp().keyboardStatus(mWXSDKInstance.getContext());
    }
}
