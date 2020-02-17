package app.eeui.framework.ui.component.grid;

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

import java.util.HashMap;
import java.util.Map;

import app.eeui.framework.R;
import app.eeui.framework.extend.module.eeuiCommon;
import app.eeui.framework.extend.module.eeuiConstants;
import app.eeui.framework.extend.module.eeuiJson;
import app.eeui.framework.extend.module.eeuiParse;
import app.eeui.framework.extend.module.eeuiScreenUtils;
import app.eeui.framework.ui.component.grid.view.GridPager;

public class Grid extends WXVContainer<ViewGroup> {

    private static final String TAG = "Grid";

    private View mView;

    private GridPager v_gridPager;

    private Handler mHandler = new Handler();

    private int addIdentify;

    public Grid(WXSDKInstance instance, WXVContainer parent, BasicComponentData basicComponentData) {
        super(instance, parent, basicComponentData);
    }

    @Override
    protected ViewGroup initComponentHostView(@NonNull Context context) {
        mView = ((Activity) context).getLayoutInflater().inflate(R.layout.layout_eeui_grid, null);
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
        v_gridPager.addData(view);
        notifyDataSetChanged();
    }

    @Override
    public void remove(WXComponent child, boolean destroy) {
        if (child == null || child.getHostView() == null) {
            return;
        }
        v_gridPager.removeData(child.getHostView());
        notifyDataSetChanged();
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

            case "row":
                setRowSize(eeuiParse.parseInt(val, 3));
                return true;

            case "columns":
                setColumnsSize(eeuiParse.parseInt(val, 3));
                return true;

            case "divider":
                setDivider(eeuiParse.parseBool(val, true));
                return true;

            case "dividerColor":
                setDividerColor(eeuiParse.parseStr(val, "#e8e8e8"));
                return true;

            case "dividerWidth":
                setDividerWidth(eeuiParse.parseInt(val, 1));
                return true;

            case "indicatorShow":
                setIndicatorShow(val);
                return true;

            case "indicatorShape":
                setIndicatorShape(eeuiParse.parseInt(val));
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

    private void notifyDataSetChanged() {
        addIdentify++;
        int tempId = addIdentify;
        mHandler.postDelayed(()-> {
            if (tempId == addIdentify) {
                v_gridPager.post(()-> {
                    if (getHostView() != null && v_gridPager != null) {
                        v_gridPager.notifyDataSetChanged();
                    }
                });
            }
        }, 100);
    }

    private void initPagerView() {
        v_gridPager = mView.findViewById(R.id.v_gridPager);
        v_gridPager.setOnPageItemClickListener(new GridPager.OnPageItemClickListener() {
            @Override
            public void onClick(int pos, int position, int index) {
                if (getEvents().contains(eeuiConstants.Event.ITEM_CLICK)) {
                    Map<String, Object> data = new HashMap<>();
                    data.put("page", pos);
                    data.put("position", position);
                    data.put("index", index);
                    fireEvent(eeuiConstants.Event.ITEM_CLICK, data);
                }
            }

            @Override
            public void onLongClick(int pos, int position, int index) {
                if (getEvents().contains(eeuiConstants.Event.ITEM_LONG_CLICK)) {
                    Map<String, Object> data = new HashMap<>();
                    data.put("page", pos);
                    data.put("position", position);
                    data.put("index", index);
                    fireEvent(eeuiConstants.Event.ITEM_LONG_CLICK, data);
                }
            }
        });
    }

    /***************************************************************************************************/
    /***************************************************************************************************/
    /***************************************************************************************************/

    /**
     * 设置每页行数
     * @param var
     */
    @JSMethod
    public void setRowSize(int var) {
        v_gridPager.setRowSize(var);
        notifyDataSetChanged();
    }

    /**
     * 设置每页列数
     * @param var
     */
    @JSMethod
    public void setColumnsSize(int var) {
        v_gridPager.setColumnsSize(var);
        notifyDataSetChanged();
    }

    /**
     * 设置是否显示分隔线
     * @param var
     */
    @JSMethod
    public void setDivider(boolean var) {
        v_gridPager.setDivider(var);
        notifyDataSetChanged();
    }

    /**
     * 设置分隔线颜色
     * @param var
     */
    @JSMethod
    public void setDividerColor(String var) {
        v_gridPager.setDividerColor(eeuiParse.parseColor(var));
        notifyDataSetChanged();
    }

    /**
     * 设置分隔线尺寸
     * @param var
     */
    @JSMethod
    public void setDividerWidth(int var) {
        v_gridPager.setDividerWidth(eeuiScreenUtils.weexPx2dp(getInstance(), var, 1));
        notifyDataSetChanged();
    }

    /**
     * 设置当前页
     * @param var
     */
    @JSMethod
    public void setCurrentIndex(int var) {
        v_gridPager.setCurIndex(var);
    }

    /**
     * 获取当前页
     * @return
     */
    @JSMethod(uiThread = false)
    public int getCurrentIndex() {
        return v_gridPager.getCurIndex();
    }

    /**
     * 设置是否显示指示器
     * @param show
     */
    @JSMethod
    public void setIndicatorShow(Object show) {
        v_gridPager.setIndicatorShow(eeuiParse.parseBool(show));
        notifyDataSetChanged();
    }

    /**
     * 设置指示器形状
     * @param shape
     */
    @JSMethod
    public void setIndicatorShape(int shape) {
        v_gridPager.setIndicatorShape(shape);
        notifyDataSetChanged();
    }

    /**
     * 设置指示器间距
     * @param space
     */
    @JSMethod
    public void setIndicatorSpace(int space) {
        v_gridPager.setIndicatorSpace(eeuiScreenUtils.weexPx2dp(getInstance(), space));
        notifyDataSetChanged();
    }

    /**
     * 设置指示器未选颜色
     * @param indicatorUnSelectedColor
     */
    @JSMethod
    public void setUnSelectedIndicatorColor(String indicatorUnSelectedColor) {
        v_gridPager.setUnSelectedIndicatorColor(eeuiParse.parseColor(indicatorUnSelectedColor));
        notifyDataSetChanged();
    }

    /**
     * 设置指示器已选颜色
     * @param indicatorSelectedColor
     */
    @JSMethod
    public void setSelectedIndicatorColor(String indicatorSelectedColor) {
        v_gridPager.setSelectedIndicatorColor(eeuiParse.parseColor(indicatorSelectedColor));
        notifyDataSetChanged();
    }

    /**
     * 设置指示器宽度
     * @param indicatorWidth
     */
    @JSMethod
    public void setIndicatorWidth(int indicatorWidth) {
        v_gridPager.setIndicatorWidth(eeuiScreenUtils.weexPx2dp(getInstance(), indicatorWidth, 6));
        notifyDataSetChanged();
    }

    /**
     * 设置指示器高度
     * @param indicatorHeight
     */
    @JSMethod
    public void setIndicatorHeight(int indicatorHeight) {
        v_gridPager.setIndicatorHeight(eeuiScreenUtils.weexPx2dp(getInstance(), indicatorHeight, 6));
        notifyDataSetChanged();
    }
}
