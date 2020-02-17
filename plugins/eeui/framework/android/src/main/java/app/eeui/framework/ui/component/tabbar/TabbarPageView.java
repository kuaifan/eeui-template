package app.eeui.framework.ui.component.tabbar;

import android.content.Context;
import androidx.swiperefreshlayout.widget.SwipeRefreshLayout;
import android.util.AttributeSet;

import app.eeui.framework.ui.component.tabbar.bean.TabbarBean;

/**
 * Created by WDM on 2018/3/9.
 */

public class TabbarPageView extends SwipeRefreshLayout {

    private TabbarBean mTabbarBean = new TabbarBean();

    public TabbarPageView(Context context) {
        super(context);
    }

    public TabbarPageView(Context context, AttributeSet attrs) {
        super(context, attrs);
    }


    public void setBarBean(TabbarBean barBean) {
        mTabbarBean = barBean;
    }

    public TabbarBean getBarBean() {
        return mTabbarBean;
    }
}
