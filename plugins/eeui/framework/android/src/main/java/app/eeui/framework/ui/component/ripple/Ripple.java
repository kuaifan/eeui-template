package app.eeui.framework.ui.component.ripple;

import android.app.Activity;
import android.content.Context;
import androidx.annotation.NonNull;
import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;

import com.taobao.weex.WXSDKInstance;
import com.taobao.weex.ui.action.BasicComponentData;
import com.taobao.weex.ui.component.WXVContainer;

import app.eeui.framework.R;
import app.eeui.framework.extend.module.eeuiConstants;

/**
 * Created by WDM on 2018/4/12.
 */
public class Ripple extends WXVContainer<ViewGroup> {

    private static final String TAG = "Ripple";

    private View mView;

    private FrameLayout v_container, v_click;

    public Ripple(WXSDKInstance instance, WXVContainer parent, BasicComponentData basicComponentData) {
        super(instance, parent, basicComponentData);
    }

    @Override
    protected ViewGroup initComponentHostView(@NonNull Context context) {
        mView = ((Activity) context).getLayoutInflater().inflate(R.layout.layout_eeui_ripple, null);
        initPagerView();
        //
        if (getEvents().contains(eeuiConstants.Event.READY)) {
            fireEvent(eeuiConstants.Event.READY, null);
        }
        //
        return (ViewGroup) mView;
    }

    @Override
    public void addSubView(View view, int index) {
        if (view == null) {
            return;
        }
        ViewGroup parentViewGroup = (ViewGroup) view.getParent();
        if (parentViewGroup != null ) {
            parentViewGroup.removeView(view);
        }
        v_container.addView(view, index);
    }

    private void initPagerView() {
        v_container = mView.findViewById(R.id.v_container);
        v_click = mView.findViewById(R.id.v_click);
        if (getEvents().contains(eeuiConstants.Event.CLICK)) {
            v_click.setOnClickListener(v -> fireEvent(eeuiConstants.Event.CLICK, null));
        }
        if (getEvents().contains(eeuiConstants.Event.ITEM_CLICK)) {
            v_click.setOnClickListener(v -> fireEvent(eeuiConstants.Event.ITEM_CLICK, null));
        }
    }
}
