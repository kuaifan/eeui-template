package app.eeui.framework.ui.component.scrollHeader;

import android.content.Context;

import com.taobao.weex.ui.view.WXFrameLayout;


public class ScrollHeaderView extends WXFrameLayout {

    private StateCallback stateCallback = null;

    public ScrollHeaderView(Context context) {
        super(context);
    }

    public void stateChanged(String status) {
        if (stateCallback !=  null) {
            stateCallback.onResult(status);
        }
    }

    public void setStateCallback(StateCallback stateCallback) {
        this.stateCallback = stateCallback;
    }

    public interface StateCallback {
        void onResult(String result);
    }
}
