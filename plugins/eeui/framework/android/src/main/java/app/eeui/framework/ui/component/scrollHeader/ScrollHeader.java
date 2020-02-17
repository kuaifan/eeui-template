package app.eeui.framework.ui.component.scrollHeader;

import android.content.Context;
import androidx.annotation.NonNull;

import com.taobao.weex.WXSDKInstance;
import com.taobao.weex.ui.action.BasicComponentData;
import com.taobao.weex.ui.component.WXVContainer;

import java.util.HashMap;
import java.util.Map;

import app.eeui.framework.extend.module.eeuiConstants;


public class ScrollHeader extends WXVContainer<ScrollHeaderView> {

    public ScrollHeader(WXSDKInstance instance, WXVContainer parent, BasicComponentData basicComponentData) {
        super(instance, parent, basicComponentData);
    }

    @Override
    protected ScrollHeaderView initComponentHostView(@NonNull Context context) {
        ScrollHeaderView view = new ScrollHeaderView(getContext());
        if (getEvents().contains(eeuiConstants.Event.STATE_CHANGED)) {
            view.setStateCallback(result -> {
                Map<String, Object> retData = new HashMap<>();
                retData.put("status", result);
                fireEvent(eeuiConstants.Event.STATE_CHANGED, retData);
            });
        }
        return view;
    }
}
