package app.eeui.framework.extend.module.utilcode;

import android.app.Activity;
import android.graphics.Color;
import android.view.Gravity;

import com.alibaba.fastjson.JSONObject;
import com.taobao.weex.WXSDKInstance;

import app.eeui.framework.extend.module.utilcode.util.KeyboardUtils;
import app.eeui.framework.extend.module.utilcode.util.ToastUtils;
import app.eeui.framework.extend.module.eeuiJson;
import app.eeui.framework.extend.module.eeuiScreenUtils;

/**
 * Created by WDM on 2018/3/13.
 */

public class utilcodeModule {

    /**
     * 键盘相关
     * @param activity
     * @param method
     * @return
     */
    public static Object KeyboardUtils(Activity activity, String method) {
        if (method == null) {
            return null;
        }
        switch (method) {
            case "showSoftInput":
                KeyboardUtils.showSoftInput(activity);
                break;

            case "hideSoftInput":
                KeyboardUtils.hideSoftInput(activity);
                break;

            case "toggleSoftInput":
                KeyboardUtils.toggleSoftInput();
                break;

            case "isSoftInputVisible":
                return KeyboardUtils.isSoftInputVisible(activity);
        }
        return null;
    }

    /**
     * 吐司(Toast)相关
     * @param mInstance
     * @param obj
     */
    public static void Toast(WXSDKInstance mInstance, String obj) {
        if (obj == null) {
            ToastClose();
            return;
        }
        //
        ToastUtils.setGravity(-1, -1, -1);
        ToastUtils.setMsgColor(0xFDFFFFFF);
        ToastUtils.setBgColor(0xE6000000);
        //
        JSONObject param = eeuiJson.parseObject(obj);
        String message = param.getString("message");
        String gravity = param.getString("gravity");
        String messageColor = param.getString("messageColor");
        String backgroundColor = param.getString("backgroundColor");
        Boolean isLong = param.getBooleanValue("long");
        if (message == null) {
            message = obj;
        }
        if (gravity != null) {
            int x = param.getIntValue("x");
            int y = param.getIntValue("y");
            if (x != 0) {
                x = eeuiScreenUtils.weexPx2dp(mInstance, x);
            }
            if (y != 0) {
                y = eeuiScreenUtils.weexPx2dp(mInstance, y);
            }
            switch (gravity.toLowerCase()) {
                case "top":
                    ToastUtils.setGravity(Gravity.TOP, x, y);
                    break;

                case "center":
                case "middle":
                    ToastUtils.setGravity(Gravity.CENTER, x, y);
                    break;
                case "bottom":
                    ToastUtils.setGravity(Gravity.BOTTOM, x, y);
                    break;
            }
        }
        if (messageColor != null) {
            ToastUtils.setMsgColor(Color.parseColor(messageColor));
        }
        if (backgroundColor != null) {
            ToastUtils.setBgColor(Color.parseColor(backgroundColor));
        }
        if (isLong) {
            ToastUtils.showLong(message);
        }else{
            ToastUtils.showShort(message);
        }
    }

    /**
     * 取消吐司(Toast)显示
     */
    public static void ToastClose() {
        ToastUtils.cancel();
    }
}
