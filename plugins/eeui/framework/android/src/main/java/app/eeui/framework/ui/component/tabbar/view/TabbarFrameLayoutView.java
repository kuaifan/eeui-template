package app.eeui.framework.ui.component.tabbar.view;

import android.content.Context;
import android.util.AttributeSet;
import android.widget.FrameLayout;

public class TabbarFrameLayoutView extends FrameLayout {

    private String url = null;

    public TabbarFrameLayoutView(Context context) {
        super(context);
    }

    public TabbarFrameLayoutView(Context context, AttributeSet attrs) {
        super(context, attrs);
    }

    public TabbarFrameLayoutView(Context context, AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
    }

    public void setUrl(String url) {
        this.url = url;
    }

    public String getUrl() {
        return url;
    }
}
