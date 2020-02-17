package app.eeui.framework.ui.component.icon;

import android.annotation.SuppressLint;
import android.content.Context;
import androidx.annotation.NonNull;
import android.util.TypedValue;
import android.view.Gravity;
import android.view.MotionEvent;

import com.alibaba.fastjson.JSONObject;

import com.taobao.weex.WXSDKInstance;
import com.taobao.weex.annotation.JSMethod;
import com.taobao.weex.common.Constants;
import com.taobao.weex.ui.action.BasicComponentData;
import com.taobao.weex.ui.component.WXComponent;
import com.taobao.weex.ui.component.WXVContainer;

import java.util.Map;


import app.eeui.framework.extend.module.eeuiCommon;
import app.eeui.framework.extend.module.eeuiConstants;
import app.eeui.framework.extend.module.eeuiJson;
import app.eeui.framework.extend.module.eeuiParse;
import app.eeui.framework.extend.module.eeuiScreenUtils;

/**
 * Created by WDM on 2018/3/13.
 */
@SuppressLint("SetTextI18n")
public class Icon extends WXComponent<IconView> {

    private static final String TAG = "Icon";

    private IconView mIconView;

    private int mIconColor;

    private int mIconClickColor;

    public Icon(WXSDKInstance instance, WXVContainer parent, BasicComponentData basicComponentData) {
        super(instance, parent, basicComponentData);
        updateNativeStyle(Constants.Name.JUSTIFY_CONTENT, "center");
        updateNativeStyle(Constants.Name.ALIGN_ITEMS, "center");
    }

    @Override
    protected IconView initComponentHostView(@NonNull Context context) {
        mIconView = new IconView(context);
        appleStyleAfterCreated();
        //
        if (getEvents().contains(eeuiConstants.Event.READY)) {
            fireEvent(eeuiConstants.Event.READY, null);
        }
        //
        return mIconView;
    }

    @Override
    protected boolean setProperty(String key, Object param) {
        return initProperty(key, param) || super.setProperty(key, param);
    }

    private boolean initProperty(String key, Object val) {
        switch (eeuiCommon.camelCaseName(key)) {
            case "eeui":
                JSONObject json = eeuiJson.parseObject(eeuiParse.parseStr(val, ""));
                if (json.size() > 0) {
                    for (Map.Entry<String, Object> entry : json.entrySet()) {
                        initProperty(entry.getKey(), entry.getValue());
                    }
                }
                return true;

            case "text":
            case "content":
                setIcon(eeuiParse.parseStr(val, null));
                return true;

            case "color":
                setIconColor(eeuiParse.parseStr(val, null));
                return true;

            case "fontSize":
                setIconSize(val);
                return true;

            case "clickColor":
                setIconClickColor(eeuiParse.parseStr(val, null));
                return true;

            default:
                return false;
        }
    }

    private void appleStyleAfterCreated() {
        mIconView.setGravity(Gravity.CENTER);
        setIcon("md-home");
        setIconSize(38);
        setIconColor("#242424");
    }

    /***************************************************************************************************/
    /***************************************************************************************************/
    /***************************************************************************************************/

    /**
     * 设置图标
     * @param var
     */
    @JSMethod
    public void setIcon(String var) {
        if (var == null) {
            return;
        }
        if (var.isEmpty()) {
            mIconView.setText("");
            return;
        }
        var = eeuiCommon.trim(eeuiCommon.trim(var, "'"), "\"");
        //
        mIconView.setText("{" + var + "}");
    }

    /**
     * 设置图标大小
     * @param var
     */
    @JSMethod
    public void setIconSize(Object var) {
        mIconView.setTextSize(TypedValue.COMPLEX_UNIT_PX, eeuiScreenUtils.weexPx2dp(getInstance(), var, 38));
    }

    /**
     * 设置图标颜色
     * @param var
     */
    @JSMethod
    public void setIconColor(String var) {
        if (var == null) {
            return;
        }
        mIconColor = eeuiParse.parseColor(var);
        mIconView.setTextColor(mIconColor);
    }

    /**
     * 设置图标点击颜色
     * @param var
     */
    @JSMethod
    public void setIconClickColor(String var) {
        if (var == null) {
            return;
        }
        int color = eeuiParse.parseColor(var);
        if (mIconClickColor == 0) {
            mIconView.setClickable(true);
            mIconView.setFocusable(true);
            mIconView.setOnTouchListener((view, event) -> {
                switch (event.getAction()) {
                    //离开
                    case MotionEvent.ACTION_UP:
                        mIconView.setTextColor(mIconColor);
                        break;

                    //按下
                    case MotionEvent.ACTION_DOWN:
                        mIconView.setTextColor(mIconClickColor);
                        break;
                }
                return false;
            });
        }
        mIconClickColor = color;
    }

}
