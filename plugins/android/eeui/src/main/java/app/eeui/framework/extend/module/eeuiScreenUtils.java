package app.eeui.framework.extend.module;

import com.taobao.weex.WXSDKInstance;
import com.taobao.weex.WXSDKManager;
import com.taobao.weex.utils.WXUtils;

import app.eeui.framework.extend.module.utilcode.util.ScreenUtils;

/**
 * Created by WDM on 2018/3/13.
 */

public class eeuiScreenUtils {

    public static int weexPx2dp(WXSDKInstance mInstance, Object pxValue, int defaultValue) {
        return (int) (weexPx2dpFloat(mInstance, pxValue, defaultValue));
    }

    public static int weexPx2dp(WXSDKInstance mInstance, Object pxValue) {
        return (int) weexPx2dpFloat(mInstance, pxValue);
    }

    public static int weexDp2px(WXSDKInstance mInstance, Object dpValue) {
        return (int) (weexDp2pxFloat(mInstance, dpValue));
    }

    /******************************************************************************************/
    /******************************************************************************************/
    /******************************************************************************************/

    public static float weexPx2dpFloat(WXSDKInstance mInstance, Object pxValue, float defaultValue) {
        float width;
        if (mInstance == null) {
            width = WXSDKManager.getInstanceViewPortWidth(null);
        }else{
            width = mInstance.getInstanceViewPortWidth();
        }
        return runTwo(ScreenUtils.getScreenWidth() / width * eeuiParse.parseFloat(removePxString(pxValue), defaultValue));
    }

    public static float weexPx2dpFloat(WXSDKInstance mInstance, Object pxValue) {
        return weexPx2dpFloat(mInstance, pxValue, 0);
    }

    public static float weexDp2pxFloat(WXSDKInstance mInstance, Object dpValue) {
        float width;
        if (mInstance == null) {
            width = WXSDKManager.getInstanceViewPortWidth(null);
        }else{
            width = mInstance.getInstanceViewPortWidth();
        }
        return runTwo(width / ScreenUtils.getScreenWidth() * eeuiParse.parseFloat(dpValue, 0));
    }

    /******************************************************************************************/
    /******************************************************************************************/
    /******************************************************************************************/

    private static float runTwo(float number) {
        return (float)(Math.round(number * 100) / 100.0);
    }

    private static String removePxString(Object pxValue) {
        String temp = WXUtils.getString(pxValue, null);
        if (temp != null && !temp.isEmpty()) {
            temp = temp.replace("px", "");
        }
        return temp;
    }
}
