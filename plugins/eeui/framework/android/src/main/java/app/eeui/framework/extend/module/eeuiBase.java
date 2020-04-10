package app.eeui.framework.extend.module;

import android.app.Activity;
import android.content.Context;
import android.graphics.Bitmap;
import android.os.Handler;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import android.text.TextUtils;
import android.util.Log;
import android.view.View;
import android.widget.ImageView;
import android.widget.ProgressBar;

import com.alibaba.fastjson.JSONArray;
import com.alibaba.fastjson.JSONObject;
import com.taobao.weex.bridge.JSCallback;
import com.taobao.weex.utils.WXFileUtils;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.net.MalformedURLException;
import java.net.URL;
import java.util.Arrays;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Timer;
import java.util.TimerTask;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import app.eeui.framework.BuildConfig;
import app.eeui.framework.R;
import app.eeui.framework.extend.integration.glide.Glide;
import app.eeui.framework.extend.integration.glide.load.engine.DiskCacheStrategy;
import app.eeui.framework.extend.integration.glide.request.RequestOptions;
import app.eeui.framework.extend.integration.glide.request.target.SimpleTarget;
import app.eeui.framework.extend.integration.glide.request.transition.Transition;
import app.eeui.framework.extend.integration.xutils.common.Callback;
import app.eeui.framework.extend.integration.xutils.http.RequestParams;
import app.eeui.framework.extend.integration.xutils.x;
import app.eeui.framework.extend.module.http.HttpResponseParser;
import app.eeui.framework.extend.module.rxtools.tool.RxEncryptTool;
import app.eeui.framework.extend.module.utilcode.util.FileUtils;
import app.eeui.framework.extend.module.utilcode.util.PermissionUtils;
import app.eeui.framework.extend.module.utilcode.util.ScreenUtils;
import app.eeui.framework.extend.module.utilcode.util.TimeUtils;
import app.eeui.framework.extend.module.utilcode.util.ZipUtils;
import app.eeui.framework.extend.view.SkipView;
import app.eeui.framework.ui.eeui;

public class eeuiBase {

    private static String TAG = "eeuiBase";

    public static String appName = "EEUI";
    public static String appGroup = "EEUI";

    public interface OnWelcomeListener {
        void skip();
        void finish();
        void click(String var);
    }

    public interface OnHomeUrlListener {
        void result(String var);
    }

    private static eeui __obj;

    private static eeui myApp() {
        if (__obj == null) {
            __obj = new eeui();
        }
        return __obj;
    }

    /**
     * 配置类
     */
    public static class config {

        private static JSONObject configData;
        private static JSONArray verifyDir;

        /**
         * 读取配置
         * @return
         */
        public static JSONObject get() {
            if (configData == null) {
                configData = eeuiJson.parseObject(verifyAssets(eeui.getApplication(), "file://assets/eeui/config.json"));
            }
            for (Map.Entry<String, Object> entry :  getCustomConfig().entrySet()) {
                configData.put(entry.getKey(), entry.getValue());
            }
            return configData;
        }

        /**
         * 清除配置
         */
        public static void clear() {
            configData = null;
            verifyDir = null;
        }

        /**
         * 获取配置值
         * @param key
         * @return
         */
        public static String getString(String key, String defaultVal) {
            return eeuiJson.getString(get(), key, defaultVal);
        }

        /**
         * 获取配置值
         * @param key
         * @return
         */
        public static JSONObject getObject(String key) {
            return eeuiJson.parseObject(getRawValue(key));
        }

        /**
         * 获取配置原始值
         * @param key
         * @return
         */
        public static Object getRawValue(String key) {
            return get().get(key);
        }

        /**
         * 获取主页地址
         * @param mOnHomeUrlListener
         */
        public static void getHomeUrl(OnHomeUrlListener mOnHomeUrlListener) {
            String socketHome = eeuiJson.getString(get(), "socketHome");
            final String[] homePage = {eeuiJson.getString(get(), "homePage")};
            if (homePage[0].length() == 0) {
                homePage[0] = "file://assets/eeui/pages/index.js";
            }else{
                homePage[0] = eeuiPage.suffixUrl("app", homePage[0]);
                homePage[0] = eeuiPage.rewriteUrl("file://assets/eeui/pages/index.js", homePage[0]);
            }
            if (!BuildConfig.DEBUG || TextUtils.isEmpty(socketHome)) {
                mOnHomeUrlListener.result(homePage[0]);
                return;
            }
            //
            boolean isLip = false;
            try {
                String socketIP = eeuiParse.parseStr(new URL(socketHome).getHost());
                for(String ipv: eeuiIp.getHostIPv4Lists()) {
                    ipv = ipv.substring(0, ipv.lastIndexOf("."));
                    if (socketIP.startsWith(ipv)) {
                        isLip = true;
                    }
                }
            } catch (MalformedURLException e) {
                e.printStackTrace();
            }
            if (!isLip) {
                mOnHomeUrlListener.result(homePage[0]);
                return;
            }
            //
            Map<String, Object> data = new HashMap<>();
            data.put("preload", "preload");
            data.put("setting:timeout", 2000);
            eeuiIhttp.get("eeuiPage", socketHome, data, new eeuiIhttp.ResultCallback() {
                @Override
                public void progress(long total, long current, boolean isDownloading) {

                }

                @Override
                public void success(HttpResponseParser resData, boolean isCache) {
                    if (!TextUtils.isEmpty(resData.getBody())) {
                        JSONObject resJson = eeuiJson.parseObject(resData.getBody());
                        //
                        JSONArray appboards = eeuiJson.parseArray(resJson.getJSONArray("appboards"));
                        if (appboards.size() > 0) {
                            for (int i = 0; i < appboards.size(); i++) {
                                JSONObject appboardItem = eeuiJson.parseObject(appboards.get(i));
                                eeuiPage.mAppboardWifi.put(eeuiJson.getString(appboardItem, "path"), eeuiJson.getString(appboardItem, "content"));
                            }
                        }
                        //
                        Matcher matcher = Pattern.compile("^//\\s*\\{\\s*\"framework\"\\s*:\\s*\"Vue\"\\s*\\}").matcher(resJson.getString("body"));
                        if (matcher.find()) {
                            homePage[0] = socketHome;
                        }
                    }
                    mOnHomeUrlListener.result(homePage[0]);
                }

                @Override
                public void error(String error, int errCode) {
                    mOnHomeUrlListener.result(homePage[0]);
                }

                @Override
                public void complete() {

                }
            });
        }

        /**
         * 获取主页配置值
         * @param key
         * @param defaultVal
         * @return
         */
        public static String getHomeParams(String key, String defaultVal) {
            JSONObject params = getObject("homePageParams");
            if (params == null) {
                return defaultVal;
            }
            return eeuiJson.getString(params, key, defaultVal);
        }

        /**
         * 转换修复Assets文件内容
         * @param context
         * @param originalUrl
         * @return
         */
        public static String verifyAssets(Context context, String originalUrl) {
            String temp = verifyFile(originalUrl);
            if (!originalUrl.contentEquals(temp)) {
                temp = temp.substring(7);
                File file = new File(temp);
                if (file.exists()) {
                    return WXFileUtils.loadFileOrAsset(temp, context);
                }
            }
            return eeuiCommon.getAssetsFile(context, originalUrl);
        }

        /**
         * 转换修复文件路径
         * @param originalUrl
         * @return
         */
        public static String verifyFile(String originalUrl) {
            if (originalUrl == null ||
                    originalUrl.startsWith("http://") ||
                    originalUrl.startsWith("https://") ||
                    originalUrl.startsWith("ftp://") ||
                    originalUrl.startsWith("data:image/")) {
                return originalUrl;
            }
            String rootPath = "file://assets/eeui";
            if (!originalUrl.startsWith(rootPath)) {
                return originalUrl;
            }
            rootPath+= "/";

            String originalPath = originalUrl.replace(rootPath, "");
            File path = eeui.getApplication().getExternalFilesDir("update");
            if (path == null) {
                return originalUrl;
            }

            String newUrl = "";
            JSONArray tempArray = verifyData();
            for (int i = 0; i < tempArray.size(); i++) {
                File tempPath = eeui.getApplication().getExternalFilesDir("update/" + tempArray.getString(i));
                if (tempPath != null) {
                    tempPath = new File(tempPath.getPath() + "/" + getPathname(originalPath));
                    if (isFile(tempPath)) {
                        newUrl = "file://" + tempPath.getPath();
                        break;
                    }
                }
            }

            return newUrl.length() > 0 ? newUrl : originalUrl;
        }

        private static String getPathname(String path) {
            if (!TextUtils.isEmpty(path) && path.contains("?")) {
                path = path.substring(0, path.indexOf("?"));
            }
            return path;
        }

        /**
         * 获取热更新目录
         * @return
         */
        public static JSONArray verifyData() {
            if (verifyDir == null) {
                verifyDir = new JSONArray();
                String localVersion = String.valueOf(eeuiCommon.getLocalVersion(eeui.getApplication()));
                File path = eeui.getApplication().getExternalFilesDir("update");
                if (path != null) {
                    File[] files = path.listFiles();
                    if (files != null) {
                        List<File> fileList = Arrays.asList(files);
                        Collections.sort(fileList, (o1, o2) -> {
                            if (o1.isDirectory() && o2.isFile()) {
                                return -1;
                            } else if (o1.isFile() && o2.isDirectory()) {
                                return 1;
                            }
                            return o1.getName().compareTo(o2.getName());
                        });
                        Collections.reverse(fileList);
                        for (File file1 : files) {
                            if (file1.isDirectory() && isFile(new File(file1.getPath() + "/" + localVersion + ".release"))) {
                                verifyDir.add(file1.getName());
                            }
                        }
                    }
                }
            }
            return verifyDir;
        }

        /**
         * 是否有升级文件
         * @return
         */
        public static boolean verifyIsUpdate() {
            File tempDir = eeui.getApplication().getExternalFilesDir("update");
            if (tempDir == null) {
                return false;
            }
            if (!isDir(tempDir)) {
                return false;
            }
            File[] files = tempDir.listFiles();
            if (files == null) {
                return false;
            }
            boolean isUpdate = false;
            for (File file : files) {
                if(isDir(file)){
                    isUpdate = true;
                    break;
                }
            }
            return isUpdate;
        }

        /**
         * 设置自定义配置
         * @param key
         * @param value
         */
        public static void setCustomConfig(String key, Object value) {
            JSONObject json = getCustomConfig();
            json.put(key, value);
            json.put("__system:eeui:customTime", eeuiCommon.timeStamp());
            eeuiCommon.setCachesString(eeui.getApplication(), "__system:eeui:customConfig", json.toJSONString(), 0);
        }

        /**
         * 获取自定义配置
         * @return
         */
        public static JSONObject getCustomConfig() {
            return eeuiJson.parseObject(eeuiCommon.getCachesString(eeui.getApplication(), "__system:eeui:customConfig", "{}"));
        }

        /**
         * 清空自定义配置
         */
        public static void clearCustomConfig() {
            eeuiCommon.setCachesString(eeui.getApplication(), "__system:eeui:customConfig", "{}", 0);
        }

        /**
         * 清除缓存
         */
        public static void clearCache() {
            eeuiBase.config.clearCustomConfig();
            myApp().clearCacheDir(eeui.getApplication(), null);
            myApp().clearCachePage(eeui.getApplication());
            myApp().clearCacheAjax(eeui.getApplication());
        }

        /**
         * 判断是否文件夹（不存在返回NO）
         * @param file
         * @return
         */
        public static boolean isDir(File file) {
            if (file == null) {
                return false;
            }
            if (!file.exists()) {
                return false;
            }
            return file.isDirectory();
        }

        /**
         * 判断是否文件（不存在返回NO）
         * @param file
         * @return
         */
        public static boolean isFile(File file) {
            if (file == null) {
                return false;
            }
            if (!file.exists()) {
                return false;
            }
            return file.isFile();
        }
    }

    /**
     * 云端类
     */
    public static class cloud {

        private static Timer checkUpdateTimer;

        /**
         * 获取服务端地址
         * @param act
         * @return
         */
        public static String getUrl(String act) {
            String url = config.getString("serviceUrl", null);
            if (!TextUtils.isEmpty(url)) {
                url+= url.contains("?") ? "&" : "?";
                return url + "act=" + act;
            }
            //
            String apiUrl = eeuiBase.config.getString("consoleUrl", "https://console.eeui.app/");
            switch (act) {
                case "app":
                    return apiUrl + "api/client/app?";

                case "duration":
                    return apiUrl + "api/client/duration?";

                case "update-success":
                    return apiUrl + "api/client/update/success?";

                case "update-delete":
                    return apiUrl + "api/client/update/delete?";

                default:
                    return apiUrl;
            }
        }

        /**
         * 加载启动图
         * @param activity
         * @return
         */
        public static int welcome(Activity activity, OnWelcomeListener onWelcomeListener) {
            String welcome_image = eeuiCommon.getCachesString(eeui.getApplication(), "__system:welcome_image", "");
            if (welcome_image.isEmpty()) {
                return 0;
            }
            JSONObject appInfo = eeuiJson.parseObject(eeuiCommon.getCachesString(eeui.getApplication(), "__system:appInfo", "{}"));
            int welcome_wait = eeuiParse.parseInt(eeuiCommon.getCachesString(eeui.getApplication(), "__system:welcome_wait", "0")); welcome_wait = welcome_wait > 100 ? welcome_wait : 2000;
            boolean welcome_skip = eeuiJson.getBoolean(appInfo, "welcome_skip");
            String welcome_jump = eeuiJson.getString(appInfo, "welcome_jump");
            long welcome_limit_s = eeuiJson.getLong(appInfo, "welcome_limit_s");
            long welcome_limit_e = eeuiJson.getLong(appInfo, "welcome_limit_e");
            //
            long timeStamp = System.currentTimeMillis() / 1000;
            if (welcome_limit_s > 0 && welcome_limit_s > timeStamp) {
                return 0;
            }
            if (welcome_limit_e > 0 && welcome_limit_e < timeStamp) {
                return 0;
            }
            //
            ProgressBar fillload = activity.findViewById(R.id.fillload);
            SkipView fillskip = activity.findViewById(R.id.fillskip);
            fillskip.setTotalTime(welcome_wait);
            fillskip.setOnSkipListener(new SkipView.OnSkipListener() {
                @Override
                public void onSkip(int progress) {
                    onWelcomeListener.skip();
                }

                @Override
                public void onFinish() {
                    onWelcomeListener.finish();
                }
            });
            //
            File welcomeFile = new File(welcome_image);
            if (config.isFile(welcomeFile)) {
                Glide.with(activity).asBitmap().load(welcomeFile).apply(new RequestOptions().diskCacheStrategy(DiskCacheStrategy.NONE)).into(new SimpleTarget<Bitmap>() {
                    @Override
                    public void onResourceReady(@NonNull Bitmap resource, @Nullable Transition<? super Bitmap> transition) {
                        ImageView tmpImage = activity.findViewById(R.id.fillimage);
                        tmpImage.setImageBitmap(resource);
                        tmpImage.setOnClickListener(this::onClick);
                        activity.findViewById(R.id.fillbox).setVisibility(View.VISIBLE);
                        activity.findViewById(R.id.mainbox).setVisibility(View.GONE);
                        fillskip.start();
                    }

                    private void onClick(View v) {
                        if (!"".equals(welcome_jump)) {
                            onWelcomeListener.click(welcome_jump);
                        }
                    }
                });
            }
            //
            if (welcome_skip) {
                fillskip.setVisibility(View.VISIBLE);
            }else{
                new Handler().postDelayed(() -> fillload.post(() -> fillload.setVisibility(View.VISIBLE)), welcome_wait);
            }
            //
            return welcome_wait;
        }

        /**
         * 云数据
         */
        public static void appData(boolean client_mode) {
            String appkey = config.getString("appKey", "");
            if (appkey.length() == 0) {
                return;
            }
            //读取云配置
            Map<String, Object> data = new HashMap<>();
            data.put("appkey", appkey);
            data.put("package", eeui.getApplication().getPackageName());
            data.put("version", eeuiCommon.getLocalVersion(eeui.getApplication()));
            data.put("versionName", eeuiCommon.getLocalVersionName(eeui.getApplication()));
            data.put("screenWidth", ScreenUtils.getScreenWidth());
            data.put("screenHeight", ScreenUtils.getScreenHeight());
            data.put("platform", "android");
            data.put("mode", client_mode ? 1 : 0);
            data.put("debug", BuildConfig.DEBUG ? 1 : 0);
            data.put("__", eeuiCommon.timeStamp());
            eeuiIhttp.get("main", getUrl("app"), data, new eeuiIhttp.ResultCallback() {
                @Override
                public void progress(long total, long current, boolean isDownloading) {

                }

                @Override
                public void success(HttpResponseParser resData, boolean isCache) {
                    JSONObject json = eeuiJson.parseObject(resData.getBody());
                    if (json.getIntValue("ret") == 1) {
                        JSONObject retData = json.getJSONObject("data");
                        eeuiCommon.setCachesString(eeui.getApplication(), "__system:appInfo", retData.toString(), 0);
                        saveWelcomeImage(retData.getString("welcome_image"), retData.getIntValue("welcome_wait"));
                        checkUpdateLists(retData.getJSONArray("uplists"), 0);
                        eeuiVersionUpdate.checkUpdate(retData.getJSONObject("version_update"));
                    }
                }

                @Override
                public void error(String error, int errCode) {

                }

                @Override
                public void complete() {

                }
            });
        }

        /**
         * 缓存启动图
         * @param url
         * @param wait
         */
        private static void saveWelcomeImage(String url, int wait) {
            if (url.startsWith("http")) {
                new Thread(() -> {
                    try {
                        Bitmap resource = Glide.with(eeui.getApplication()).asBitmap().load(url).apply(new RequestOptions().diskCacheStrategy(DiskCacheStrategy.ALL)).submit().get();
                        if (resource != null) {
                            eeuiCommon.saveImageToGallery(null, resource, "welcome_image", null, path -> eeuiCommon.setCachesString(eeui.getApplication(), "__system:welcome_image", path, 0));
                        }
                    } catch (Exception ignored) {
                        eeuiCommon.setCachesString(eeui.getApplication(), "__system:welcome_image", null, 0);
                    }
                }).start();
            }else{
                eeuiCommon.setCachesString(eeui.getApplication(), "__system:welcome_image", null, 0);
            }
            eeuiCommon.setCachesString(eeui.getApplication(), "__system:welcome_wait", String.valueOf(wait), 0);
        }

        /**
         * 更新部分
         * @param lists
         * @param number
         */
        public static void checkUpdateLists(JSONArray lists, int number) {
            if (number >= lists.size()) {
                return;
            }
            //
            JSONObject data = eeuiJson.parseObject(lists.get(number));
            String id = eeuiJson.getString(data, "id");
            String url = eeuiJson.getString(data, "path");
            int valid = eeuiJson.getInt(data, "valid");
            int clearCache = eeuiJson.getInt(data, "clear_cache");
            if (!url.startsWith("http")) {
                checkUpdateLists(lists, number + 1);
                return;
            }
            //
            File tempDir = eeui.getApplication().getExternalFilesDir("update");
            File lockFile = new File(tempDir, RxEncryptTool.encryptMD5ToString(url) + ".lock");
            File zipSaveFile = new File(tempDir, id + ".zip");
            File zipUnDir = new File(tempDir, id);
            File releaseFile = new File(tempDir, id + "/" + eeuiCommon.getLocalVersion(eeui.getApplication()) + ".release");
            if (valid == 1) {
                //开始修复
                if (config.isFile(lockFile)) {
                    checkUpdateLists(lists, number + 1);
                    return;
                }
                if (tempDir != null && (tempDir.exists() || tempDir.mkdirs())) {
                    //下载zip文件
                    RequestParams requestParams = new RequestParams(url);
                    requestParams.setSaveFilePath(zipSaveFile.getPath());
                    x.http().get(requestParams, new Callback.CommonCallback<File>() {
                        @Override
                        public void onSuccess(File result) {
                            //下载成功 > 解压
                            try {
                                ZipUtils.unzipFile(zipSaveFile, zipUnDir);
                                FileUtils.deleteFile(zipSaveFile);
                                //
                                FileOutputStream fos = new FileOutputStream(lockFile);
                                byte[] bytes = TimeUtils.getNowString().getBytes();
                                fos.write(bytes);
                                fos.close();
                                //
                                fos = new FileOutputStream(releaseFile);
                                bytes = TimeUtils.getNowString().getBytes();
                                fos.write(bytes);
                                fos.close();
                                //
                                eeuiIhttp.get("checkUpdateLists", getUrl("update-success") + "&id=" + id, null, null);
                                eeuiBase.config.clear();
                                if (clearCache == 1) {
                                    eeuiBase.config.clearCache();
                                }
                                if (lists.size() > number + 1) {
                                    checkUpdateLists(lists, number + 1);
                                }else{
                                    checkUpdateHint(data);
                                }
                            } catch (IOException e) {
                                e.printStackTrace();
                            }
                        }

                        @Override
                        public void onError(Throwable ex, boolean isOnCallback) {

                        }

                        @Override
                        public void onCancelled(CancelledException cex) {

                        }

                        @Override
                        public void onFinished() {

                        }
                    });
                }
            }else if (valid == 2) {
                //开始删除
                boolean isDelete = false;
                if (config.isFile(lockFile)) {
                    FileUtils.deleteFile(lockFile);
                    isDelete = true;
                }
                if (config.isDir(zipUnDir)) {
                    FileUtils.deleteDir(zipUnDir);
                    isDelete = true;
                }
                if (!isDelete) {
                    checkUpdateLists(lists, number + 1);
                    return;
                }
                eeuiIhttp.get("checkUpdateLists", getUrl("update-delete") + "&id=" + id, null, null);
                eeuiBase.config.clear();
                if (clearCache == 1) {
                    eeuiBase.config.clearCache();
                }
                if (lists.size() > number + 1) {
                    checkUpdateLists(lists, number + 1);
                }else{
                    checkUpdateHint(data);
                }
            }
        }

        /**
         * 更新部分(提示处理)
         */
        private static void checkUpdateHint(JSONObject data) {
            if (PermissionUtils.isShowApply || PermissionUtils.isShowRationale || PermissionUtils.isShowOpenAppSetting) {
                if (checkUpdateTimer != null) {
                    checkUpdateTimer.cancel();
                    checkUpdateTimer = null;
                }
                checkUpdateTimer = new Timer();
                checkUpdateTimer.schedule(new TimerTask() {
                    @Override
                    public void run() {
                        if (!PermissionUtils.isShowApply && !PermissionUtils.isShowRationale && !PermissionUtils.isShowOpenAppSetting) {
                            checkUpdateTimer.cancel();
                            checkUpdateTimer = null;
                            eeui.getActivityList().getLast().runOnUiThread(() -> {
                                try {
                                    checkUpdateHint(data);
                                } catch (Exception e) {
                                    Log.d(TAG, "run: checkUpdate error:" + e.getMessage());
                                }
                            });
                        }
                    }
                }, 3000, 2000);
                return;
            }
            switch (eeuiJson.getInt(data, "reboot")) {
                case 1:
                    reboot();
                    break;

                case 2:
                    JSONObject rebootInfo = eeuiJson.parseObject(data.getJSONObject("reboot_info"));
                    JSONObject newJson = new JSONObject();
                    newJson.put("title", eeuiJson.getString(rebootInfo, "title"));
                    newJson.put("message", eeuiJson.getString(rebootInfo, "message"));
                    newJson.put("cancelable", false);
                    eeuiAlertDialog.confirm(eeui.getActivityList().getLast(), newJson, new JSCallback() {
                        @Override
                        public void invoke(Object data) {
                            Map<String, Object> retData = eeuiMap.objectToMap(data);
                            if (retData != null && eeuiParse.parseStr(retData.get("status")).equals("click")) {
                                if (eeuiParse.parseStr(retData.get("title")).equals("确定")) {
                                    if (eeuiJson.getBoolean(rebootInfo, "confirm_reboot")) {
                                        reboot();
                                    }
                                }
                            }
                        }

                        @Override
                        public void invokeAndKeepAlive(Object data) {

                        }
                    });
                    break;
            }
        }

        /**
         * 重启
         */
        public static void reboot() {
            eeuiPage.mAppboardContent = new HashMap<>();
            config.clear();
            eeui.reboot();
        }

        /**
         * 清除热更新缓存
         */
        public static void clearUpdate() {
            FileUtils.deleteDir(eeui.getApplication().getExternalFilesDir("update"));
            reboot();
        }
    }
}
