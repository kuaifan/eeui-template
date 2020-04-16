package app.eeui.framework.ui.component.tabbar;

import android.content.Context;
import androidx.annotation.NonNull;
import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;
import android.widget.LinearLayout;
import android.widget.ScrollView;

import com.alibaba.fastjson.JSONObject;

import com.taobao.weex.WXSDKInstance;
import com.taobao.weex.annotation.JSMethod;
import com.taobao.weex.dom.CSSShorthand;
import com.taobao.weex.ui.action.BasicComponentData;
import com.taobao.weex.ui.component.WXComponent;
import com.taobao.weex.ui.component.WXVContainer;

import java.util.HashMap;
import java.util.Map;

import app.eeui.framework.extend.module.eeuiCommon;
import app.eeui.framework.extend.module.eeuiConstants;
import app.eeui.framework.extend.module.eeuiJson;
import app.eeui.framework.extend.module.eeuiParse;
import app.eeui.framework.extend.module.eeuiScreenUtils;
import app.eeui.framework.ui.component.tabbar.bean.TabbarBean;


/**
 * Created by WDM on 2018/3/9.
 */

public class TabbarPage extends WXVContainer<TabbarPageView> {

    private TabbarPageView mView;
    private LinearLayout lView;

    public TabbarPage(WXSDKInstance instance, WXVContainer parent, BasicComponentData basicComponentData) {
        super(instance, parent, basicComponentData);
    }

    @Override
    public void addSubView(View view, int index) {
        if (view == null || lView == null) {
            return;
        }
        ViewGroup parentViewGroup = (ViewGroup) view.getParent();
        if (parentViewGroup != null ) {
            parentViewGroup.removeView(view);
        }
        lView.addView(view, index);
    }

    @Override
    public void remove(WXComponent child, boolean destroy) {
        if (child == null || child.getHostView() == null || lView == null) {
            return;
        }
        lView.removeView(child.getHostView());
        super.remove(child, destroy);
    }

    @Override
    protected TabbarPageView initComponentHostView(@NonNull Context context) {
        if (getParent() instanceof Tabbar) {
            mView = new TabbarPageView(context);

            ViewGroup.LayoutParams mLayoutParams = new ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT);
            lView = new LinearLayout(context);
            lView.setLayoutParams(mLayoutParams);
            lView.setOrientation(LinearLayout.VERTICAL);

            if (getEvents().contains(eeuiConstants.Event.REFRESH_LISTENER)) {
                ScrollView sView = new ScrollView(context);
                sView.setLayoutParams(mLayoutParams);
                sView.addView(lView);
                mView.addView(sView);
                formatAttrs(getAttrs());
                //
                mView.setColorSchemeResources(android.R.color.holo_blue_light, android.R.color.holo_red_light, android.R.color.holo_orange_light, android.R.color.holo_green_light);
                mView.setOnRefreshListener(() -> fireEvent(eeuiConstants.Event.REFRESH_LISTENER, mView.getBarBean().toMap()));
            }else{
                mView.addView(lView);
                formatAttrs(getAttrs());
                //
                mView.setEnabled(false);
            }

            return mView;
        }
        return null;
    }

    @Override
    public ViewGroup.LayoutParams getChildLayoutParams(WXComponent child, View childView, int width, int height, int left, int right, int top, int bottom) {
        ViewGroup.LayoutParams lp = childView == null ? null : childView.getLayoutParams();
        if (lp == null) {
            lp = new FrameLayout.LayoutParams(width, height);
        } else {
            lp.width = width;
            lp.height = height;
        }
        if (lp instanceof ViewGroup.MarginLayoutParams) {
            top = eeuiScreenUtils.weexDp2px(getInstance(), child.getMargin().get(CSSShorthand.EDGE.TOP));
            top = eeuiScreenUtils.weexPx2dp(getInstance(), top, 0);
            ((ViewGroup.MarginLayoutParams) lp).setMargins(left, top, right, bottom);
        }
        return lp;
    }

    private void formatAttrs(Map<String, Object> attr) {
        if (attr != null) {
            TabbarBean barBean = mView.getBarBean();
            for (String key : attr.keySet()) {
                Object value = attr.get(key);
                switch (key) {
                    case "eeui":
                        JSONObject json = eeuiJson.parseObject(eeuiParse.parseStr(value, null));
                        if (json.size() > 0) {
                            Map<String, Object> data = new HashMap<>();
                            for (Map.Entry<String, Object> entry : json.entrySet()) {
                                data.put(entry.getKey(), entry.getValue());
                            }
                            formatAttrs(data);
                        }
                        break;
                }
                barBean = setBarAttr(barBean, key, value);
            }
            mView.setBarBean(barBean);
        }
    }

    public static TabbarBean setBarAttr(TabbarBean barBean, String key, Object value) {
        if (barBean == null) {
            barBean = new TabbarBean();
        }
        switch (eeuiCommon.camelCaseName(key)) {
            case "tabName":
                barBean.setTabName(eeuiParse.parseStr(value, barBean.getTabName()));
                break;

            case "title":
                barBean.setTitle(eeuiParse.parseStr(value, barBean.getTitle()));
                break;

            case "url":
                barBean.setUrl(eeuiParse.parseStr(value, ""));
                break;

            case "unSelectedIcon":
                barBean.setUnSelectedIcon(eeuiParse.parseStr(value, ""));
                break;

            case "selectedIcon":
                barBean.setSelectedIcon(eeuiParse.parseStr(value, ""));
                break;

            case "cache":
                barBean.setCache(eeuiParse.parseLong(value, 0));
                break;

            case "params":
                barBean.setParams(value);
                break;

            case "message":
                barBean.setMessage(eeuiParse.parseInt(value, 0));
                break;

            case "dot":
                barBean.setDot(eeuiParse.parseBool(value, false));
                break;

            case "statusBarColor":
                barBean.setStatusBarColor(eeuiParse.parseStr(value, "#00000000"));
                break;

            case "loading":
                barBean.setLoading(eeuiParse.parseBool(value, true));
                break;

            case "loadingBackground":
                barBean.setLoadingBackground(eeuiParse.parseBool(value, false));
                break;
        }
        return barBean;
    }

    /**
     * 设置下拉刷新状态
     */
    @JSMethod
    public void setRefresh(){
        if (mView == null) {
            return;
        }
        mView.setRefreshing(true);
        fireEvent(eeuiConstants.Event.REFRESH_LISTENER, mView.getBarBean().toMap());
    }

    /**
     * 设置下拉刷新结束
     */
    @JSMethod
    public void refreshEnd(){
        if (mView == null) {
            return;
        }
        mView.setRefreshing(false);
    }
}
