package app.eeui.framework.extend.module;

import android.app.Activity;

import com.alibaba.fastjson.JSONArray;
import com.alibaba.fastjson.JSONObject;
import com.taobao.weex.bridge.JSCallback;

import java.util.List;

import app.eeui.framework.R;
import app.eeui.framework.activity.PageActivity;
import app.eeui.framework.ui.eeui;


public class eeuiDebug {

    private static JSCallback mJSCallback = null;
    private static JSONArray historys = null;
    private static boolean newDebug = false;
    private static int debugType = 0;

    public static void setHistorys(JSONArray historys) {
        eeuiDebug.historys = historys;
    }

    public static JSONArray getHistorys() {
        return historys;
    }

    public static void setJSCallback(JSCallback mJSCallback) {
        eeuiDebug.mJSCallback = mJSCallback;
    }

    public static JSCallback getJSCallback() {
        return mJSCallback;
    }

    public static void setNewDebug(boolean newDebug) {
        setNewDebug(newDebug, eeuiDebug.debugType);
    }

    public static void setNewDebug(boolean newDebug, int debugType) {
        if (eeuiDebug.newDebug != newDebug || eeuiDebug.debugType != debugType) {
            if (!newDebug) debugType = 0;
            eeuiDebug.newDebug = newDebug;
            eeuiDebug.debugType = debugType;
            List<Activity> activityList = eeui.getActivityList();
            for (int i = activityList.size() - 1; i >= 0; --i) {
                Activity activity = activityList.get(i);
                if (activity instanceof PageActivity) {
                    ((PageActivity) activity).deBugButtonRefresh(0);
                }
            }
        }
    }

    public static boolean isNewDebug() {
        return newDebug;
    }

    public static int getDebugType() {
        return debugType;
    }

    public static int getDebugButton(int status) {
        if (status == 1) {
            if (!isNewDebug()) {
                return R.drawable.debug_button_success;
            }
            if (getDebugType() == 9) {
                return R.drawable.debug_button_success_error;
            } else if (getDebugType() == 8) {
                return R.drawable.debug_button_success_warn;
            } else {
                return R.drawable.debug_button_success_info;
            }
        } else {
            if (!isNewDebug()) {
                return R.drawable.debug_button_connect;
            }
            if (getDebugType() == 9) {
                return R.drawable.debug_button_connect_error;
            } else if (getDebugType() == 8) {
                return R.drawable.debug_button_connect_warn;
            } else {
                return R.drawable.debug_button_connect_info;
            }
        }
    }

    /**
     * 添加日志
     * @param type
     * @param log
     * @param pageUrl
     */
    public static void addDebug(String type, Object log, String pageUrl) {
        if (historys == null) {
            historys = new JSONArray();
        }
        //
        com.alibaba.fastjson.JSONObject data = new JSONObject();
        data.put("type", type);
        data.put("text", log);
        data.put("page", pageUrl);
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
        //
        int debugType = 1;
        switch (type) {
            case "error":
                debugType = 9;
                break;
            case "warn":
                debugType = 8;
                break;
        }
        setNewDebug(true, Math.max(debugType, eeuiDebug.debugType));
    }
}
