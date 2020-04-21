package app.eeui.framework.ui.component.blurView;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.content.Context;
import android.graphics.Color;
import android.graphics.drawable.Drawable;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.NonNull;

import com.alibaba.fastjson.JSONObject;
import com.taobao.weex.WXSDKInstance;
import com.taobao.weex.annotation.JSMethod;
import com.taobao.weex.ui.action.BasicComponentData;
import com.taobao.weex.ui.component.WXVContainer;

import java.util.Map;

import app.eeui.framework.extend.module.eeuiConstants;
import app.eeui.framework.extend.module.eeuiJson;
import app.eeui.framework.extend.module.eeuiParse;
import app.eeui.framework.ui.component.blurView.element.RenderScriptBlur;

import static android.graphics.Color.TRANSPARENT;

public class BlurView extends WXVContainer<app.eeui.framework.ui.component.blurView.element.BlurView> {

    private app.eeui.framework.ui.component.blurView.element.BlurView blurView;

    private static final int defaultAmount = 30;

    public BlurView(WXSDKInstance instance, WXVContainer parent, BasicComponentData basicComponentData) {
        super(instance, parent, basicComponentData);
    }

    @SuppressLint("NewApi")
    @Override
    protected app.eeui.framework.ui.component.blurView.element.BlurView initComponentHostView(@NonNull Context context) {
        blurView = new app.eeui.framework.ui.component.blurView.element.BlurView(context);
        View decorView = ((Activity) context).getWindow().getDecorView();
        ViewGroup rootView = decorView.findViewById(android.R.id.content);
        Drawable windowBackground = decorView.getBackground();
        blurView.setupWith(rootView)
                .setFrameClearDrawable(windowBackground)
                .setBlurAlgorithm(new RenderScriptBlur(context))
                .setBlurRadius((float) defaultAmount * 0.25f)
                .setHasFixedTransformationMatrix(false);
        //
        if (getEvents().contains(eeuiConstants.Event.READY)) {
            fireEvent(eeuiConstants.Event.READY, null);
        }
        return blurView;
    }

    @Override
    protected boolean setProperty(String key, Object param) {
        return initProperty(key, param) || super.setProperty(key, param);
    }

    private boolean initProperty(String key, Object val) {
        switch (key) {
            case "eeui":
                JSONObject json = eeuiJson.parseObject(eeuiParse.parseStr(val, ""));
                if (json.size() > 0) {
                    for (Map.Entry<String, Object> entry : json.entrySet()) {
                        initProperty(entry.getKey(), entry.getValue());
                    }
                }
                return true;

            case "amount":
                setAmount(eeuiParse.parseInt(val));
                return true;

            case "type":
                setType(eeuiParse.parseStr(val, "light"));
                return true;

            default:
                return false;
        }
    }


    /***************************************************************************************************/
    /***************************************************************************************************/
    /***************************************************************************************************/

    @JSMethod
    public void setAmount(int amount) {
        if (blurView == null) {
            return;
        }
        if (amount > 100) amount = 100;
        if (amount < 0) amount = 0;
        blurView.setBlurRadius((float) amount * 0.25f);
        blurView.invalidate();
    }

    @JSMethod
    public void setType(String type) {
        if (blurView == null) {
            return;
        }
        if ("dark".equals(type)) {
            blurView.setOverlayColor(Color.argb(150, 0, 0, 0));
        } else {
            blurView.setOverlayColor(TRANSPARENT);
        }
        blurView.invalidate();
    }
}
