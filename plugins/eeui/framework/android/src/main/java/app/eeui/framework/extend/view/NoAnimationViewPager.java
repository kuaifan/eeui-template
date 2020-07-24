package app.eeui.framework.extend.view;

import android.content.Context;
import androidx.viewpager.widget.ViewPager;

import android.text.TextUtils;
import android.util.AttributeSet;
import android.view.MotionEvent;
import android.view.View;

import com.taobao.weex.bridge.WXBridgeManager;
import com.taobao.weex.dom.WXEvent;
import com.taobao.weex.ui.component.WXComponent;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import app.eeui.framework.activity.PageActivity;
import app.eeui.framework.extend.bean.PageStatus;
import app.eeui.framework.extend.module.eeuiCommon;
import app.eeui.framework.extend.module.eeuiConstants;
import app.eeui.framework.extend.module.rxtools.tool.RxDataTool;
import app.eeui.framework.extend.view.tablayout.listener.CustomTabEntity;
import app.eeui.framework.ui.component.tabbar.TabbarPageView;
import app.eeui.framework.ui.component.tabbar.bean.WXSDKBean;


public class NoAnimationViewPager extends ViewPager {

    public boolean smoothScroll = false;
    public boolean slideSwitch = true;

    public NoAnimationViewPager(Context context) {
        super(context);
    }

    public NoAnimationViewPager(Context context, AttributeSet attrs) {
        super(context, attrs);
    }


    @Override
    public void setCurrentItem(int item, boolean smoothScroll) {
        super.setCurrentItem(item, smoothScroll);
    }

    @Override
    public void setCurrentItem(int item) {
        super.setCurrentItem(item, smoothScroll);
    }

    @Override
    public boolean onInterceptTouchEvent(MotionEvent event) {
        if (!slideSwitch) {
            return false;
        }
        return super.onInterceptTouchEvent(event);
    }

    @Override
    public boolean onTouchEvent(MotionEvent event) {
        if (event.getAction() == MotionEvent.ACTION_DOWN) {
            performClick();
        }
        if (!slideSwitch) {
            return false;
        }
        return super.onTouchEvent(event);
    }

    @Override
    public boolean performClick() {
        return super.performClick();
    }

    public void setSmoothScroll(boolean smoothScroll) {
        this.smoothScroll = smoothScroll;
    }

    /********************************************************************************/
    /********************************************************************************/
    /********************************************************************************/

    public ArrayList<CustomTabEntity> TabEntity = new ArrayList<>();

    public ArrayList<View> ViewList = new ArrayList<>();

    public Map<String, WXSDKBean> WXSDKList = new HashMap<>();

    /**
     * 获取Tab指定项名字
     * @param position
     * @return
     */
    public String getTabName(int position) {
        if (TabEntity != null && TabEntity.size() > 0) {
            for (int i = 0; i < TabEntity.size(); i++) {
                if (i == position) {
                    return TabEntity.get(i).getTabName();
                }
            }
        }
        return null;
    }

    /**
     * 生命周期（页面）
     * @param position
     * @param status
     * @param isFinal
     */
    public void lifecycleListener(int position, String status, boolean isFinal) {
        if (position < WXSDKList.size()) {
            String getTabName = getTabName(position);
            WXSDKBean sdkBean = WXSDKList.get(getTabName);
            if (sdkBean != null) {
                if (sdkBean.getInstance() != null) {
                    switch (status) {
                        case "WXSDKViewCreated":
                            status = "ready";
                            break;

                        case "__destroy":
                            status = "destroy";
                            break;

                        case "resume":
                        case "pause":
                            break;

                        default:
                            return;
                    }
                    //
                    WXComponent mWXComponent = sdkBean.getInstance().getRootComponent();
                    if (mWXComponent != null) {
                        WXEvent events = mWXComponent.getEvents();
                        boolean hasEvent = events.contains(eeuiConstants.Event.LIFECYCLE);
                        if (hasEvent) {
                            Map<String, Object> retData = new HashMap<>();
                            retData.put("status", status);
                            WXBridgeManager.getInstance().fireEventOnNode(sdkBean.getInstance().getInstanceId(), mWXComponent.getRef(), eeuiConstants.Event.LIFECYCLE, retData, null);
                        }
                        //
                        if (status.equals("pause")) {
                            if (((PageActivity) sdkBean.getInstance().getContext()).isFinishing()) {
                                for (int i = 0; i < WXSDKList.size(); i++) {
                                    lifecycleListener(i, "__destroy", true);
                                }
                            }
                        }
                        //
                        if (!isFinal) {
                            List<View> lists = eeuiCommon.getAllChildViews(mWXComponent.getHostView());
                            for (View mView : lists) {
                                if (mView instanceof NoAnimationViewPager) {
                                    ((NoAnimationViewPager) mView).lifecycleListener(status);
                                }
                            }
                        }
                    }
                    //
                    Map<String, Object> retApp = new HashMap<>();
                    retApp.put("status", status);
                    retApp.put("type", "page");
                    retApp.put("pageType", "tabbar");
                    retApp.put("pageName", sdkBean.getTabName());
                    retApp.put("pageUrl", (sdkBean.getView() instanceof String) ? String.valueOf(sdkBean.getView()) : "");
                    sdkBean.getInstance().fireGlobalEventCallback("__appLifecycleStatus", retApp);
                }
            }
        }
    }

    public void lifecycleListener(int position, String status) {
        lifecycleListener(position, status, false);
    }

    public void lifecycleListener(String status) {
        lifecycleListener(getCurrentItem(), status);
    }

    /**
     * 生命周期（app）
     * @param mPageStatus
     */
    public void appStatusListeners(PageStatus mPageStatus) {
        for (WXSDKBean sdkBean : WXSDKList.values()) {
            if (sdkBean != null) {
                if (TextUtils.isEmpty(mPageStatus.getPageName()) || sdkBean.getTabName().contentEquals(mPageStatus.getPageName())) {
                    if (sdkBean.getInstance() != null) {
                        Map<String, Object> retApp = new HashMap<>();
                        retApp.put("status", mPageStatus.getStatus());
                        retApp.put("type", mPageStatus.getType());
                        retApp.put("pageType", "tabbar");
                        retApp.put("pageName", sdkBean.getTabName());
                        retApp.put("pageUrl", (sdkBean.getView() instanceof String) ? String.valueOf(sdkBean.getView()) : "");
                        if (mPageStatus.getMessage() != null) {
                            retApp.put("message", mPageStatus.getMessage());
                        }
                        sdkBean.getInstance().fireGlobalEventCallback("__appLifecycleStatus", retApp);
                    }
                }
            }
        }
    }
}
