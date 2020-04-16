package app.eeui.framework.ui.component.view;

import android.content.Context;
import android.view.ViewTreeObserver;


import androidx.annotation.NonNull;

import com.taobao.weex.WXSDKInstance;
import com.taobao.weex.ui.action.BasicComponentData;
import com.taobao.weex.ui.component.WXDiv;
import com.taobao.weex.ui.component.WXVContainer;
import com.taobao.weex.ui.view.WXFrameLayout;
import com.taobao.weex.utils.WXViewUtils;

import java.util.HashMap;
import java.util.Map;

import app.eeui.framework.extend.module.eeuiConstants;


public class View extends WXDiv implements ViewTreeObserver.OnGlobalLayoutListener {

    private float mLayerWidth = 0;
    private float mLayerHeight = 0;

    public View(WXSDKInstance instance, WXVContainer parent, BasicComponentData basicComponentData) {
        super(instance, parent, basicComponentData);
    }

    @Override
    protected WXFrameLayout initComponentHostView(@NonNull Context context) {
        if (getEvents().contains(eeuiConstants.Event.READY)) {
            fireEvent(eeuiConstants.Event.READY, null);
        }
        return super.initComponentHostView(context);
    }

    @Override
    protected void onHostViewInitialized(WXFrameLayout host) {
        if (getEvents().contains(eeuiConstants.Event.COMPONENT_RESIZE)) {
            getRealView().getViewTreeObserver().addOnGlobalLayoutListener(this);
        }
        super.onHostViewInitialized(host);
    }

    @Override
    public void destroy() {
        if (getEvents().contains(eeuiConstants.Event.COMPONENT_RESIZE)) {
            getRealView().getViewTreeObserver().removeOnGlobalLayoutListener(this);
        }
        super.destroy();
    }


    @Override
    public void onGlobalLayout() {
        float tmpWidth = (float) getRealView().getWidth();
        float tmpHeight = (float) getRealView().getHeight();
        if (tmpWidth != mLayerWidth || tmpHeight != mLayerHeight) {
            mLayerWidth = tmpWidth;
            mLayerHeight = tmpHeight;
            Map<String, Object> data = new HashMap<>();
            int viewPort = getInstance().getInstanceViewPortWidth();
            data.put("width", WXViewUtils.getWebPxByWidth(mLayerWidth, viewPort));
            data.put("height", WXViewUtils.getWebPxByWidth(mLayerHeight, viewPort));
            fireEvent(eeuiConstants.Event.COMPONENT_RESIZE, data);
        }
    }
}
