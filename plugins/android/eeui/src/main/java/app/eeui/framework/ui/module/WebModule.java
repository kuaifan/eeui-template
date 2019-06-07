package app.eeui.framework.ui.module;


import app.eeui.framework.extend.view.ExtendWebView;
import app.eeui.framework.extend.view.webviewBridge.JsCallback;
import app.eeui.framework.ui.eeui;


public class WebModule {

    private static eeui __obj;

    private static eeui myApp() {
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
    public static void openPage(ExtendWebView webView, String object, JsCallback callback) {
        myApp().openPage(webView.getContext(), object, eeui.MCallback(callback));
    }

    /**
     * 获取页面信息
     * @param object
     * @return
     */
    public static Object getPageInfo(ExtendWebView webView, String object) {
        return myApp().getPageInfo(webView.getContext(), object);
    }

    /**
     * 获取页面信息（异步）
     * @param object
     * @return
     */
    public static void getPageInfoAsync(ExtendWebView webView, String object, JsCallback callback) {
        myApp().getPageInfoAsync(webView.getContext(), object, eeui.MCallback(callback));
    }

    /**
     * 获取页面传递的参数
     * @param object
     * @return
     */
    public static Object getPageParams(ExtendWebView webView, String object) {
        return myApp().getPageParams(webView.getContext(), object);
    }

    /**
     * 重新加载页面（刷新）
     * @param object
     */
    public static void reloadPage(ExtendWebView webView, String object) {
        myApp().reloadPage(webView.getContext(), object);
    }

    /**
     * 关闭页面 或 关闭网页（内置浏览器）
     * @param object
     */
    public static void closePage(ExtendWebView webView, String object) {
        myApp().closePage(webView.getContext(), object);
    }


    /**
     * 关闭页面至指定页面
     * @param object
     */
    public static void closePageTo(ExtendWebView webView, String object) {
        myApp().closePageTo(webView.getContext(), object);
    }

    /**
     * 设置键盘弹出方式
     * @param object
     * @param mode
     */
    public static void setSoftInputMode(ExtendWebView webView, String object, String mode) {
        myApp().setSoftInputMode(webView.getContext(), object, mode);
    }

    /**
     * 修改状态栏样式
     * @param isLight 是否亮色
     */
    public void setStatusBarStyle(ExtendWebView webView, boolean isLight) {
        myApp().setStatusBarStyle(webView.getContext(), isLight);
    }

    /**
     * 修改状态栏样式
     * @param isLight 是否亮色
     */
    public void statusBarStyle(ExtendWebView webView, boolean isLight) {
        myApp().setStatusBarStyle(webView.getContext(), isLight);
    }

    /**
     * 拦截返回按键事件
     * @param object
     * @param callback  为null时取消拦截
     */
    public static void setPageBackPressed(ExtendWebView webView, String object, JsCallback callback) {
        myApp().setPageBackPressed(webView.getContext(), object, eeui.MCallback(callback));
    }

    /**
     * 监听下拉刷新事件
     * @param object
     * @param callback  为null时取消监听
     */
    public static void setOnRefreshListener(ExtendWebView webView, String object, JsCallback callback) {
        myApp().setOnRefreshListener(webView.getContext(), object, eeui.MCallback(callback));
    }

    /**
     * 设置下拉刷新状态
     * @param object
     * @param refreshing
     */
    public static void setRefreshing(ExtendWebView webView, String object, boolean refreshing) {
        myApp().setRefreshing(webView.getContext(), object, refreshing);
    }

    /**
     * 监听页面状态变化
     * @param object
     * @param callback
     */
    public static void setPageStatusListener(ExtendWebView webView, String object, JsCallback callback) {
        myApp().setPageStatusListener(webView.getContext(), object, eeui.MCallback(callback));
    }

    /**
     * 取消监听页面状态变化
     * @param object
     */
    public static void clearPageStatusListener(ExtendWebView webView, String object) {
        myApp().clearPageStatusListener(webView.getContext(), object);
    }

    /**
     * 手动执行(触发)页面状态
     * @param object
     * @param status
     */
    public static void onPageStatusListener(ExtendWebView webView, String object, String status) {
        myApp().onPageStatusListener(webView.getContext(), object, status);
    }

    /**
     * 获取页面缓存大小
     */
    public static void getCacheSizePage(ExtendWebView webView, JsCallback callback) {
        myApp().getCacheSizePage(webView.getContext(), eeui.MCallback(callback));
    }

    /**
     * 清除缓存页面
     */
    public static void clearCachePage(ExtendWebView webView) {
        myApp().clearCachePage(webView.getContext());
    }

    /**
     * 打开网页（系统浏览器）
     * @param url
     */
    public static void openWeb(ExtendWebView webView, String url) {
        myApp().openWeb(webView.getContext(), url);
    }

    /**
     * 返回桌面
     */
    public static void goDesktop(ExtendWebView webView) {
        myApp().goDesktop(webView.getContext());
    }

    /**
     * 获取eeui.config.js配置指定参数
     * @param webView
     * @param key
     * @return
     */
    public String getConfigString(ExtendWebView webView, String key) {
        return myApp().getConfigString(key);
    }

    /**
     * 规范化url，删除所有符号连接（比如'/./', '/../' 以及多余的'/'）
     * @param webView
     * @param url
     * @return
     */
    public String realUrl(ExtendWebView webView, String url) {
        return myApp().realUrl(url);
    }

    /**
     * 补全地址
     * @param webView
     * @param url
     * @return
     */
    public String rewriteUrl(ExtendWebView webView, String url) {
        return myApp().rewriteUrl(webView.getContext(), url);
    }

    /****************************************************************************************/
    /****************************************************************************************/

    /**
     * 获取状态栏高度（屏幕像素）
     */
    public static int getStatusBarHeight(ExtendWebView webView) {
        return myApp().getStatusBarHeight(webView.getContext());
    }

    /**
     * 获取状态栏高度（weexPX单位）
     */
    public static int getStatusBarHeightPx(ExtendWebView webView) {
        return myApp().getStatusBarHeightPx(webView.getContext());
    }

    /**
     * 获取虚拟键盘高度（屏幕像素）
     */
    public static int getNavigationBarHeight(ExtendWebView webView) {
        return myApp().getNavigationBarHeight(webView.getContext());
    }

    /**
     * 获取虚拟键盘高度（weexPX单位）
     */
    public static int getNavigationBarHeightPx(ExtendWebView webView) {
        return myApp().getNavigationBarHeightPx(webView.getContext());
    }

    /**
     * 获取eeui版本号
     */
    public static int getVersion(ExtendWebView webView) {
        return myApp().getVersion(webView.getContext());
    }

    /**
     * 获取eeui版本号名称
     */
    public static String getVersionName(ExtendWebView webView) {
        return myApp().getVersionName(webView.getContext());
    }

    /**
     * 获取本地软件版本号
     */
    public static int getLocalVersion(ExtendWebView webView) {
        return myApp().getLocalVersion(webView.getContext());
    }

    /**
     * 获取本地软件版本号名称
     */
    public static String getLocalVersionName(ExtendWebView webView) {
        return myApp().getLocalVersionName(webView.getContext());
    }

    /**
     * 比较版本号的大小,前者大则返回一个正数,后者大返回一个负数,相等则返回0
     * @param version1
     * @param version2
     * @return
     */
    public static int compareVersion(ExtendWebView webView, String version1, String version2) {
        return myApp().compareVersion(webView.getContext(), version1, version2);
    }

    /**
     * 获取手机的IMEI
     */
    public static String getImei(ExtendWebView webView) {
        return myApp().getImei(webView.getContext());
    }

    /**
     * 获取手机的IFA
     */
    public static String getIfa(ExtendWebView webView) {
        return myApp().getIfa(webView.getContext());
    }

    /**
     * 获取设备系统版本号
     */
    public static int getSDKVersionCode(ExtendWebView webView) {
        return myApp().getSDKVersionCode(webView.getContext());
    }

    /**
     * 获取设备系统版本名称
     */
    public static String getSDKVersionName(ExtendWebView webView) {
        return myApp().getSDKVersionName(webView.getContext());
    }

    /**
     * 是否IPhoneX系列设配
     * @return
     */
    public static boolean isIPhoneXType(ExtendWebView webView) {
        return myApp().isIPhoneXType(webView.getContext());
    }

    /****************************************************************************************/
    /****************************************************************************************/

    /**
     * 保存缓存信息
     * @param key
     * @param value
     * @param expired
     */
    public static void setCachesString(ExtendWebView webView, String key, String value, Long expired) {
        myApp().setCachesString(webView.getContext(), key, value, expired);
    }

    /**
     * 获取缓存信息
     * @param key
     * @param defaultVal
     */
    public static String getCachesString(ExtendWebView webView, String key, String defaultVal) {
        return myApp().getCachesString(webView.getContext(), key, defaultVal);
    }

    /**
     * 设置全局变量
     * @param key
     * @param value
     */
    public static void setVariate(ExtendWebView webView, String key, String value) {
        myApp().setVariate(webView.getContext(), key, value);
    }

    /**
     * 获取全局变量
     * @param key
     * @param defaultVal
     */
    public static String getVariate(ExtendWebView webView, String key, String defaultVal) {
        return myApp().getVariate(webView.getContext(), key, defaultVal);
    }

    /****************************************************************************************/
    /****************************************************************************************/

    /**
     * 获取内部缓存目录大小
     * @param callback
     */
    public static void getCacheSizeDir(ExtendWebView webView, JsCallback callback) {
        myApp().getCacheSizeDir(webView.getContext(), eeui.MCallback(callback));
    }

    /**
     * 清空内部缓存目录
     */
    public static void clearCacheDir(ExtendWebView webView, JsCallback callback) {
        myApp().clearCacheDir(webView.getContext(), eeui.MCallback(callback));
    }

    /**
     * 获取内部文件目录大小
     * @param callback
     */
    public static void getCacheSizeFiles(ExtendWebView webView, JsCallback callback) {
        myApp().getCacheSizeFiles(webView.getContext(), eeui.MCallback(callback));
    }

    /**
     * 清空内部文件目录
     */
    public static void clearCacheFiles(ExtendWebView webView, JsCallback callback) {
        myApp().clearCacheFiles(webView.getContext(), eeui.MCallback(callback));
    }

    /**
     * 获取内部数据库目录大小
     * @param callback
     */
    public static void getCacheSizeDbs(ExtendWebView webView, JsCallback callback) {
        myApp().getCacheSizeDbs(webView.getContext(), eeui.MCallback(callback));
    }

    /**
     * 清空内部数据库目录
     */
    public static void clearCacheDbs(ExtendWebView webView, JsCallback callback) {
        myApp().clearCacheDbs(webView.getContext(), eeui.MCallback(callback));
    }

    /****************************************************************************************/
    /****************************************************************************************/

    /**
     * weex px转dp
     * @param var
     */
    public static int weexPx2dp(ExtendWebView webView, String var) {
        return myApp().weexPx2dp(webView.getContext(), var);
    }

    /**
     * weex dp转px
     * @param var
     */
    public static int weexDp2px(ExtendWebView webView, String var) {
        return myApp().weexDp2px(webView.getContext(), var);
    }

    /****************************************************************************************/
    /****************************************************************************************/

    /**
     * alert 警告框
     */
    public static void alert(ExtendWebView webView, Object object, JsCallback callback) {
        myApp().alert(webView.getContext(), object, eeui.MCallback(callback));
    }

    /**
     * confirm 确认对话框
     */
    public static void confirm(ExtendWebView webView, Object object, JsCallback callback) {
        myApp().confirm(webView.getContext(), object, eeui.MCallback(callback));
    }

    /**
     * input 输入对话框
     */
    public static void input(ExtendWebView webView, Object object, JsCallback callback) {
        myApp().input(webView.getContext(), object, eeui.MCallback(callback));
    }

    /****************************************************************************************/
    /****************************************************************************************/

    /**
     * 显示等待图标
     * @param object        参数
     * @param callback      返回键或点击空白处取消回调事件
     * @return
     */
    public static String loading(ExtendWebView webView, String object, JsCallback callback) {
        return myApp().loading(webView.getContext(), object, eeui.MCallback(callback));
    }

    /**
     * 关闭等待图标
     */
    public static void loadingClose(ExtendWebView webView, String var) {
        myApp().loadingClose(webView.getContext(), var);
    }

    /****************************************************************************************/
    /****************************************************************************************/

    /**
     * 打开滑动验证码
     * @param imgUrl
     * @param callback
     */
    public static void swipeCaptcha(ExtendWebView webView, String imgUrl, JsCallback callback) {
        myApp().swipeCaptcha(webView.getContext(), imgUrl, eeui.MCallback(callback));
    }

    /****************************************************************************************/
    /****************************************************************************************/

    /**
     * 打开二维码扫描
     * @param object
     * @param callback
     */
    public static void openScaner(ExtendWebView webView, String object, JsCallback callback) {
        myApp().openScaner(webView.getContext(), object, eeui.MCallback(callback));
    }

    /****************************************************************************************/
    /****************************************************************************************/

    /**
     * 跨域异步请求
     * @param object
     * @param callback
     */
    public static void ajax(ExtendWebView webView, String object, JsCallback callback) {
        myApp().ajax(webView.getContext(), object, eeui.MCallback(callback));
    }

    /**
     * 取消跨域异步请求
     * @param name
     */
    public static void ajaxCancel(ExtendWebView webView, String name) {
        myApp().ajaxCancel(webView.getContext(), name);
    }

    /**
     * 获取异步请求缓存大小
     */
    public static void getCacheSizeAjax(ExtendWebView webView, JsCallback callback) {
        myApp().getCacheSizeAjax(webView.getContext(), eeui.MCallback(callback));
    }

    /**
     * 清除异步请求缓存
     */
    public static void clearCacheAjax(ExtendWebView webView) {
        myApp().clearCacheAjax(webView.getContext());
    }

    /**
     * 获取图片尺寸
     * @param url
     * @param callback
     */
    public static void getImageSize(ExtendWebView webView, String url, JsCallback callback) {
        myApp().getImageSize(webView.getContext(), url, eeui.MCallback(callback));
    }

    /****************************************************************************************/
    /****************************************************************************************/

    /**
     * 复制文本到剪贴板
     * @param var
     */
    public static void copyText(ExtendWebView webView, String var) {
        myApp().copyText(webView.getContext(), var);
    }

    /**
     * 获取剪贴板的文本
     * @return
     */
    public static CharSequence pasteText(ExtendWebView webView) {
        return myApp().pasteText(webView.getContext());
    }

    /****************************************************************************************/
    /****************************************************************************************/

    /**
     * 吐司(Toast)显示
     * @param object
     */
    public static void toast(ExtendWebView webView, String object) {
        myApp().toast(webView.getContext(), object);
    }

    /**
     * 吐司(Toast)隐藏
     */
    public static void toastClose(ExtendWebView webView) {
        myApp().toastClose(webView.getContext());
    }

    /****************************************************************************************/
    /****************************************************************************************/

    /**
     * 图片广告弹窗
     * @param object
     * @param callback
     */
    public static void adDialog(ExtendWebView webView, String object, JsCallback callback) {
        myApp().adDialog(webView.getContext(), object, eeui.MCallback(callback));
    }

    /**
     * 手动关闭图片广告弹窗
     * @param dialogName
     */
    public static void adDialogClose(ExtendWebView webView, String dialogName) {
        myApp().adDialogClose(webView.getContext(), dialogName);
    }

    /****************************************************************************************/
    /****************************************************************************************/

    /**
     * 保存图片到本地
     * @param url
     */
    public static void saveImage(ExtendWebView webView, String url, JsCallback callback) {
        myApp().saveImage(webView.getContext(), url, eeui.MCallback(callback));
    }

    /****************************************************************************************/
    /****************************************************************************************/

    /**
     * 打开其他APP
     * @param type
     */
    public static void openOtherApp(ExtendWebView webView, String type) {
        myApp().openOtherApp(webView.getContext(), type);
    }

    /****************************************************************************************/
    /****************************************************************************************/

    /**
     * 分享文字
     * @param text
     */
    public static void shareText(ExtendWebView webView, String text) {
        myApp().shareText(webView.getContext(), text);
    }

    /**
     * 分享图片
     * @param imgUrl
     */
    public static void shareImage(ExtendWebView webView, String imgUrl) {
        myApp().shareImage(webView.getContext(), imgUrl);
    }

    /****************************************************************************************/
    /****************************************************************************************/

    /**
     * 动态隐藏软键盘
     * @return
     */
    public static void keyboardHide(ExtendWebView webView) {
        myApp().keyboardUtils(webView.getContext(), "hideSoftInput");
    }

    /**
     * 判断软键盘是否可见
     * @return
     */
    public static Boolean keyboardStatus(ExtendWebView webView) {
        return (Boolean) myApp().keyboardUtils(webView.getContext(), "isSoftInputVisible");
    }

    /***************************************************************************************************/
    /***************************************************************************************************/
    /***************************************************************************************************/

    /**
     * App 相关
     * @param method
     * @return
     */
    public static Object appUtils(ExtendWebView webView, String method, Object var0, Object var1) {
        return myApp().appUtils(webView.getContext(), method, var0, var1);
    }

    /**
     * 设备相关
     * @param method
     * @return
     */
    public static Object deviceUtils(ExtendWebView webView, String method) {
        return myApp().deviceUtils(webView.getContext(), method);
    }

    /**
     * 键盘相关
     * @param method
     * @return
     */
    public static Object keyboardUtils(ExtendWebView webView, String method) {
        return myApp().keyboardUtils(webView.getContext(), method);
    }

    /**
     * 网络相关
     * @param method
     * @return
     */
    public static Object networkUtils(ExtendWebView webView, String method, Object var0, Object var1) {
        return myApp().networkUtils(webView.getContext(), method, var0, var1);
    }

    /**
     * 权限相关
     * @param method
     * @return
     */
    public static Object permissionUtils(ExtendWebView webView, String method, Object var0, Object var1) {
        return myApp().permissionUtils(webView.getContext(), method, var0, var1);
    }

    /**
     * 手机相关
     * @param method
     * @return
     */
    public static Object phoneUtils(ExtendWebView webView, String method, Object var0, Object var1, Object var2) {
        return myApp().phoneUtils(webView.getContext(), method, var0, var1, var2);
    }

    /**
     * 进程相关
     * @param method
     * @return
     */
    public static Object processUtils(ExtendWebView webView, String method, Object var0, Object var1) {
        return myApp().processUtils(webView.getContext(), method, var0, var1);
    }

    /**
     * 屏幕相关
     * @param method
     * @return
     */
    public static Object screenUtils(ExtendWebView webView, String method, Object var0, Object var1) {
        return myApp().screenUtils(webView.getContext(), method, var0, var1);
    }

    /**
     * 时间相关
     * @param method
     * @return
     */
    public static Object timeUtils(ExtendWebView webView, String method, Object var0, Object var1, Object var2) {
        return myApp().timeUtils(webView.getContext(), method, var0, var1, var2);
    }

    /**
     * 摄像机相关
     * @param method
     */
    public static void cameraTool(ExtendWebView webView, String method) {
        myApp().cameraTool(webView.getContext(), method);
    }

    /**
     * 定位相关
     * @param method
     * @return
     */
    public static Object locationTool(ExtendWebView webView, String method, Object var0, Object var1, Object var2) {
        return myApp().locationTool(webView.getContext(), method, var0, var1, var2);
    }

    /**
     * 震动相关
     * @param method
     */
    public static void vibrateTool(ExtendWebView webView, String method, Object var0, Object var1) {
        myApp().vibrateTool(webView.getContext(), method, var0, var1);
    }
}
