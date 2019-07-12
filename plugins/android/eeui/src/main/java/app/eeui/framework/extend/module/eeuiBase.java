package app.eeui.framework.extend.module;

import android.app.Activity;
import android.content.Context;
import android.graphics.Bitmap;
import android.os.Handler;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;
import android.view.View;
import android.widget.ImageView;
import android.widget.ProgressBar;

import com.alibaba.fastjson.JSONArray;
import com.alibaba.fastjson.JSONObject;
import com.taobao.weex.bridge.JSCallback;
import com.taobao.weex.utils.WXFileUtils;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.Arrays;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

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
import app.eeui.framework.extend.module.rxtools.tool.RxEncryptTool;
import app.eeui.framework.extend.module.utilcode.util.FileUtils;
import app.eeui.framework.extend.module.utilcode.util.ScreenUtils;
import app.eeui.framework.extend.module.utilcode.util.TimeUtils;
import app.eeui.framework.extend.module.utilcode.util.ZipUtils;
import app.eeui.framework.extend.view.SkipView;
import app.eeui.framework.ui.eeui;

public class eeuiBase {

    public static String appName = "EEUI";
    public static String appGroup = "EEUI";

    public interface OnWelcomeListener {
        void skip();
        void finish();
        void click(String var);
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
            return eeuiJson.parseObject(get().get(key));
        }

        /**
         * 获取主页地址
         * @return
         */
        public static String getHome() {
            String homePage = eeuiJson.getString(get(), "homePage");
            if (homePage.length() == 0) {
                homePage = "file://assets/eeui/pages/index.js";
            }
            return homePage;
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

            if (verifyDir == null) {
                verifyDir = new JSONArray();
                String localVersion = String.valueOf(eeuiCommon.getLocalVersion(eeui.getApplication()));
                File[] files = path.listFiles();
                List<File> fileList = Arrays.asList(files);
                Collections.sort(fileList, (o1, o2) -> {
                    if (o1.isDirectory() && o2.isFile()) {
                        return -1;
                    }else if (o1.isFile() && o2.isDirectory()) {
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

            String newUrl = "";
            for (int i = 0; i < verifyDir.size(); i++) {
                File tempPath = eeui.getApplication().getExternalFilesDir("update/" + verifyDir.getString(i));
                if (tempPath != null) {
                    tempPath = new File(tempPath.getPath() + "/" + originalPath);
                    if (isFile(tempPath)) {
                        newUrl = "file://" + tempPath.getPath();
                        break;
                    }
                }
            }

            return newUrl.length() > 0 ? newUrl : originalUrl;
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

        private static String apiUrl = "https://console.eeui.app/";

        /**
         * 加载启动图
         * @param activity
         * @return
         */
        public static int welcome(Activity activity, OnWelcomeListener onWelcomeListener) {
            String welcome_image = eeuiCommon.getCachesString(eeui.getApplication(), "main", "welcome_image");
            if (welcome_image.isEmpty()) {
                return 0;
            }
            JSONObject appInfo = eeuiJson.parseObject(eeuiCommon.getCachesString(eeui.getApplication(), "main", "appInfo", "{}"));
            int welcome_wait = eeuiParse.parseInt(eeuiCommon.getCachesString(eeui.getApplication(), "main", "welcome_wait")); welcome_wait = welcome_wait > 100 ? welcome_wait : 2000;
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
        public static void appData() {
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
            data.put("debug", BuildConfig.DEBUG ? 1 : 0);
            eeuiIhttp.get("main", apiUrl + "api/client/app", data, new eeuiIhttp.ResultCallback() {
                @Override
                public void success(String resData, boolean isCache) {
                    JSONObject json = eeuiJson.parseObject(resData);
                    if (json.getIntValue("ret") == 1) {
                        JSONObject retData = json.getJSONObject("data");
                        eeuiCommon.setCachesString(eeui.getApplication(), "main", "appInfo", retData.toString());
                        saveWelcomeImage(retData.getString("welcome_image"), retData.getIntValue("welcome_wait"));
                        checkUpdateLists(retData.getJSONArray("uplists"), 0, false);
                    }
                }

                @Override
                public void error(String error) {

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
                            eeuiCommon.saveImageToGallery(null, resource, "welcome_image", null, path -> eeuiCommon.setCachesString(eeui.getApplication(), "main", "welcome_image", path));
                        }
                    } catch (Exception ignored) {
                        eeuiCommon.removeCachesString(eeui.getApplication(), "main", "welcome_image");
                    }
                }).start();
            }else{
                eeuiCommon.removeCachesString(eeui.getApplication(), "main", "welcome_image");
            }
            eeuiCommon.setCachesString(eeui.getApplication(), "main", "welcome_wait", String.valueOf(wait));
        }

        /**
         * 更新部分
         * @param lists
         * @param number
         */
        private static void checkUpdateLists(JSONArray lists, int number, boolean isReboot) {
            if (number >= lists.size()) {
                if (isReboot) {
                    reboot();
                }
                return;
            }
            //
            JSONObject data = eeuiJson.parseObject(lists.get(number));
            String id = eeuiJson.getString(data, "id");
            String url = eeuiJson.getString(data, "path");
            int valid = eeuiJson.getInt(data, "valid");
            if (!url.startsWith("http")) {
                checkUpdateLists(lists, number + 1, isReboot);
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
                    checkUpdateLists(lists, number + 1, isReboot);
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
                                eeuiIhttp.get("checkUpdateLists", apiUrl + "api/client/update/success?id=" + id, null, null);
                                checkUpdateHint(lists, data, number, isReboot);
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
                    checkUpdateLists(lists, number + 1, isReboot);
                    return;
                }
                eeuiIhttp.get("checkUpdateLists", apiUrl + "api/client/update/delete?id=" + id, null, null);
                checkUpdateHint(lists, data, number, isReboot);
            }
        }

        /**
         * 更新部分(提示处理)
         * @param lists
         * @param number
         */
        private static void checkUpdateHint(JSONArray lists, JSONObject data, int number, boolean isReboot) {
            eeuiBase.config.clear();
            switch (eeuiJson.getInt(data, "reboot")) {
                case 1:
                    checkUpdateLists(lists, number + 1, true);
                    break;

                case 2:
                    JSONObject rebootInfo = eeuiJson.parseObject(data.getJSONObject("reboot_info"));
                    JSONObject newJson = new JSONObject();
                    newJson.put("title", eeuiJson.getString(rebootInfo, "title"));
                    newJson.put("message", eeuiJson.getString(rebootInfo, "message"));
                    eeuiAlertDialog.confirm(eeui.getActivityList().getLast(), newJson, new JSCallback() {
                        @Override
                        public void invoke(Object data) {
                            Map<String, Object> retData = eeuiMap.objectToMap(data);
                            if (eeuiParse.parseStr(retData.get("status")).equals("click")) {
                                if (eeuiParse.parseStr(retData.get("title")).equals("确定")) {
                                    if (eeuiJson.getBoolean(rebootInfo, "confirm_reboot")) {
                                        reboot();
                                        return;
                                    }
                                }
                                checkUpdateLists(lists, number + 1, isReboot);
                            }
                        }

                        @Override
                        public void invokeAndKeepAlive(Object data) {

                        }
                    });
                    break;

                default:
                    checkUpdateLists(lists, number + 1, isReboot);
                    break;
            }
        }

        /**
         * 重启
         */
        public static void reboot() {
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
