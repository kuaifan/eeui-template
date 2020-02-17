package app.eeui.framework.ui.component.banner;

import android.app.Activity;
import android.content.Context;
import android.os.Handler;
import androidx.annotation.NonNull;
import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;

import com.alibaba.fastjson.JSONObject;
import com.taobao.weex.WXSDKInstance;
import com.taobao.weex.annotation.JSMethod;
import com.taobao.weex.dom.CSSShorthand;
import com.taobao.weex.ui.action.BasicComponentData;
import com.taobao.weex.ui.component.WXComponent;
import com.taobao.weex.ui.component.WXVContainer;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import app.eeui.framework.R;
import app.eeui.framework.extend.module.eeuiCommon;
import app.eeui.framework.extend.module.eeuiConstants;
import app.eeui.framework.extend.module.eeuiJson;
import app.eeui.framework.extend.module.eeuiParse;
import app.eeui.framework.extend.module.eeuiScreenUtils;
import app.eeui.framework.ui.component.banner.view.BannerLayout;

/**
 * Created by WDM on 2018/4/10.
 */
public class Banner extends WXVContainer<ViewGroup> {

    private static final String TAG = "Banner";

    private View mView;

    private BannerLayout v_banner;

    private List<View> banner_views = new ArrayList<>();

    private int addIdentify;

    private Handler mHandler = new Handler();

    public Banner(WXSDKInstance instance, WXVContainer parent, BasicComponentData basicComponentData) {
        super(instance, parent, basicComponentData);
    }

    @Override
    protected ViewGroup initComponentHostView(@NonNull Context context) {
        mView = ((Activity) context).getLayoutInflater().inflate(R.layout.layout_eeui_banner, null);
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
        banner_views.add(view);
        notifyDataSetChanged(true);
    }

    @Override
    public void remove(WXComponent child, boolean destroy) {
        if (child == null || child.getHostView() == null) {
            return;
        }
        banner_views.remove(child.getHostView());
        notifyDataSetChanged(true);
        super.remove(child,destroy);
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

    @Override
    protected boolean setProperty(String key, Object param) {
        return initProperty(key, param) || super.setProperty(key, param);
    }

    private boolean initProperty(String key, Object val) {
        switch (eeuiCommon.camelCaseName(key)) {
            case "eeui":
                JSONObject json = eeuiJson.parseObject(eeuiParse.parseStr(val, ""));
                if (json.size() > 0) {
                    for (Map.Entry<String, Object> entry : json.entrySet()) {
                        initProperty(entry.getKey(), entry.getValue());
                    }
                }
                return true;

            case "autoPlayDuration":
                setAutoPlayDuration(eeuiParse.parseInt(val));
                return true;

            case "scrollDuration":
                setScrollDuration(eeuiParse.parseInt(val));
                return true;

            case "indicatorShow":
                setIndicatorShow(val);
                return true;

            case "indicatorShape":
                setIndicatorShape(eeuiParse.parseInt(val));
                return true;

            case "indicatorPosition":
                setIndicatorPosition(eeuiParse.parseInt(val));
                return true;

            case "indicatorMargin":
                setIndicatorMargin(eeuiParse.parseInt(val));
                return true;

            case "indicatorSpace":
                setIndicatorSpace(eeuiParse.parseInt(val));
                return true;

            case "selectedIndicatorColor":
                setSelectedIndicatorColor(eeuiParse.parseStr(val));
                return true;

            case "unSelectedIndicatorColor":
                setUnSelectedIndicatorColor(eeuiParse.parseStr(val));
                return true;

            case "indicatorWidth":
                setIndicatorWidth(eeuiParse.parseInt(val));
                return true;

            case "indicatorHeight":
                setIndicatorHeight(eeuiParse.parseInt(val));
                return true;

            default:
                return false;
        }
    }

    private void initPagerView() {
        v_banner = mView.findViewById(R.id.v_banner);
        //
        v_banner.setOnBannerItemClickListener(new BannerLayout.OnBannerItemClickListener() {
            @Override
            public void onItemClick(int position) {
                if (getEvents().contains(eeuiConstants.Event.ITEM_CLICK)) {
                    Map<String, Object> data = new HashMap<>();
                    data.put("position", position);
                    fireEvent(eeuiConstants.Event.ITEM_CLICK, data);
                }
            }

            @Override
            public void onLongItemClick(int position) {
                if (getEvents().contains(eeuiConstants.Event.ITEM_LONG_CLICK)) {
                    Map<String, Object> data = new HashMap<>();
                    data.put("position", position);
                    fireEvent(eeuiConstants.Event.ITEM_LONG_CLICK, data);
                }
            }
        });
    }

    private void notifyDataSetChanged(boolean restView) {
        addIdentify++;
        int tempId = addIdentify;
        mHandler.postDelayed(()-> {
            if (tempId == addIdentify) {
                try {
                    v_banner.post(()-> {
                        if (restView) {
                            v_banner.setViews(banner_views);
                            v_banner.post(()-> v_banner.notifyDataSetChanged());
                        }else{
                            v_banner.notifyDataSetChanged();
                        }
                    });
                }catch (NullPointerException ignored) { }
            }
        }, 100);
    }

    /***************************************************************************************************/
    /***************************************************************************************************/
    /***************************************************************************************************/

    /**
     * 开始自动轮播
     */
    @JSMethod
    public void startAutoPlay() {
        v_banner.startAutoPlay();
    }

    /**
     * 停止自动轮播
     */
    @JSMethod
    public void stopAutoPlay() {
        v_banner.stopAutoPlay();
    }

    /**
     * 设置切换间隔时间
     * @param duration
     */
    @JSMethod
    public void setAutoPlayDuration(int duration) {
        v_banner.setAutoPlayDuration(duration);
        notifyDataSetChanged(false);
    }

    /**
     * 设置切换过程时间
     * @param duration
     */
    @JSMethod
    public void setScrollDuration(int duration) {
        v_banner.setScrollDuration(duration);
        notifyDataSetChanged(false);
    }

    /**
     * 设置是否显示指示器
     * @param show
     */
    @JSMethod
    public void setIndicatorShow(Object show) {
        v_banner.setIndicatorShow(eeuiParse.parseBool(show));
        notifyDataSetChanged(false);
    }

    /**
     * 设置指示器形状
     * @param shape
     */
    @JSMethod
    public void setIndicatorShape(int shape) {
        v_banner.setIndicatorShape(shape);
        notifyDataSetChanged(false);
    }

    /**
     * 设置指示器位置
     * @param position
     */
    @JSMethod
    public void setIndicatorPosition(int position) {
        v_banner.setIndicatorPosition(position);
        notifyDataSetChanged(false);
    }

    /**
     * 设置指示器边缘距离
     * @param margin
     */
    @JSMethod
    public void setIndicatorMargin(int margin) {
        v_banner.setIndicatorMargin(eeuiScreenUtils.weexPx2dp(getInstance(), margin));
        notifyDataSetChanged(false);
    }

    /**
     * 设置指示器间距
     * @param space
     */
    @JSMethod
    public void setIndicatorSpace(int space) {
        v_banner.setIndicatorSpace(eeuiScreenUtils.weexPx2dp(getInstance(), space));
        notifyDataSetChanged(false);
    }

    /**
     * 设置指示器已选颜色
     * @param color
     */
    @JSMethod
    public void setSelectedIndicatorColor(String color) {
        v_banner.setSelectedIndicatorColor(eeuiParse.parseColor(color));
        notifyDataSetChanged(false);
    }

    /**
     * 设置指示器未选颜色
     * @param color
     */
    @JSMethod
    public void setUnSelectedIndicatorColor(String color) {
        v_banner.setUnSelectedIndicatorColor(eeuiParse.parseColor(color));
        notifyDataSetChanged(false);
    }

    /**
     * 设置指示器宽
     * @param width
     */
    @JSMethod
    public void setIndicatorWidth(int width) {
        v_banner.setIndicatorWidth(eeuiScreenUtils.weexPx2dp(getInstance(), width));
        notifyDataSetChanged(false);
    }

    /**
     * 设置指示器高
     * @param height
     */
    @JSMethod
    public void setIndicatorHeight(int height) {
        v_banner.setIndicatorHeight(eeuiScreenUtils.weexPx2dp(getInstance(), height));
        notifyDataSetChanged(false);
    }
}
