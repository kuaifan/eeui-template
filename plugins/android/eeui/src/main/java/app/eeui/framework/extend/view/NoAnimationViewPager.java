package app.eeui.framework.extend.view;

import android.content.Context;
import android.support.v4.view.ViewPager;
import android.util.AttributeSet;
import android.view.View;

import com.taobao.weex.bridge.WXBridgeManager;
import com.taobao.weex.dom.WXEvent;
import com.taobao.weex.ui.component.WXComponent;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import app.eeui.framework.extend.module.eeuiCommon;
import app.eeui.framework.extend.module.eeuiConstants;
import app.eeui.framework.extend.view.tablayout.listener.CustomTabEntity;
import app.eeui.framework.ui.component.tabbar.bean.WXSDKBean;


public class NoAnimationViewPager extends ViewPager {

    public boolean smoothScroll = false;

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
     * 生命周期
     * @param position
     * @param status
     */
    public void lifecycleListener(int position, String status) {
        if (position < WXSDKList.size()) {
            String getTabName = getTabName(position);
            WXSDKBean sdkBean = WXSDKList.get(getTabName);
            if (sdkBean != null) {
                if (sdkBean.getInstance() != null) {
                    switch (status) {
                        case "WXSDKViewCreated":
                            status = "ready";
                            break;

                        case "resume":
                        case "pause":
                            break;

                        default:
                            return;
                    }
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
                        List<View> lists = eeuiCommon.getAllChildViews(mWXComponent.getHostView());
                        for(View mView: lists) {
                            if (mView instanceof NoAnimationViewPager) {
                                ((NoAnimationViewPager) mView).lifecycleListener(status);
                            }
                        }
                    }
                }
            }
        }
    }

    public void lifecycleListener(String status) {
        lifecycleListener(getCurrentItem(), status);
    }
}
