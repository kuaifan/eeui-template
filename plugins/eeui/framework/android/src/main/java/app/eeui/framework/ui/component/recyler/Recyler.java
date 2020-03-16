package app.eeui.framework.ui.component.recyler;

import android.app.Activity;
import android.content.Context;
import android.os.Handler;
import android.os.Looper;
import androidx.annotation.NonNull;
import androidx.swiperefreshlayout.widget.SwipeRefreshLayout;
import androidx.recyclerview.widget.DefaultItemAnimator;
import androidx.recyclerview.widget.GridLayoutManager;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;
import androidx.recyclerview.widget.SimpleItemAnimator;
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
import app.eeui.framework.ui.component.recyler.adapter.RecylerAdapter;
import app.eeui.framework.ui.component.recyler.bean.ViewItem;
import app.eeui.framework.ui.component.recyler.listener.RecylerOnBottomScrollListener;
import app.eeui.framework.ui.component.scrollHeader.ScrollHeaderView;

public class Recyler extends WXVContainer<ViewGroup> implements SwipeRefreshLayout.OnRefreshListener {

    private static final String TAG = "Recyler";

    private View mView;

    private SwipeRefreshLayout v_swipeRefresh;
    private RecyclerView v_recyler;
    private FrameLayout v_header;

    private boolean isSwipeRefresh;
    private boolean isRefreshAuto;

    private int footIdentify;
    private int lastVisibleItem = 0;

    private int refreshIdentify;
    private int refreshStart = 0;
    private int refreshEnd = 0;

    private boolean hasMore = false;
    private boolean isLoading = false;
    private boolean isRefreshing = false;
    private boolean isHeaderFloat = false;

    private GridLayoutManager mLayoutManager;
    private RecylerAdapter mAdapter;
    private Runnable listUpdateRunnable;
    private Handler mHandler = new Handler();
    private ViewGroup headerViewGroup;

    private boolean mShouldScroll;      //目标项是否在最后一个可见项之后
    private int mToPosition;            //记录目标项位置

    public Recyler(WXSDKInstance instance, WXVContainer parent, BasicComponentData basicComponentData) {
        super(instance, parent, basicComponentData);
    }

    @Override
    protected ViewGroup initComponentHostView(@NonNull Context context) {
        mView = ((Activity) context).getLayoutInflater().inflate(R.layout.layout_eeui_recyler, null);
        initPagerView();
        //
        listUpdateRunnable = () -> {
            if (getHostView() != null && mAdapter != null) {
                mAdapter.notifyDataSetChanged();
            }
        };
        //
        formatAttrs(getAttrs());
        if (isRefreshAuto) {
            setRefreshing(true);
        }
        //
        if (getEvents().contains(eeuiConstants.Event.READY)) {
            fireEvent(eeuiConstants.Event.READY, null);
        }
        //
        return (ViewGroup) mView;
    }

    private void formatAttrs(Map<String, Object> attr) {
        if (attr != null) {
            for (String key : attr.keySet()) {
                Object value = attr.get(key);
                switch (eeuiCommon.camelCaseName(key)) {
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

                    case "refreshAuto":
                        isRefreshAuto = eeuiParse.parseBool(value);
                        break;
                }
            }
        }
    }

    @Override
    public void addSubView(View view, int index) {
        if (view == null || mAdapter == null) {
            return;
        }
        if (view instanceof ScrollHeaderView) {
            ViewGroup parentViewGroup = (ViewGroup) view.getParent();
            if (parentViewGroup != null ) {
                parentViewGroup.removeView(view);
            }
            ScrollHeaderView temp = new ScrollHeaderView(getContext());
            temp.addView(view);
            temp.setLayoutParams(view.getLayoutParams());
            mAdapter.updateList(index, new ViewItem(temp), hasMore);
            isHeaderFloat = true;
        }else{
            mAdapter.updateList(index, new ViewItem(view), hasMore);
        }
        mAdapter.notifyItemInserted(index);
        notifyUpdateFoot();
    }

    @Override
    public void remove(WXComponent child, boolean destroy) {
        if (child == null || child.getHostView() == null || mAdapter == null) {
            return;
        }
        View view = child.getHostView();
        if (view instanceof ScrollHeaderView) {
            view = (View) view.getParent();
            if (view == v_header) {
                view = headerViewGroup;
            }
        }
        mAdapter.removeList(view, hasMore);
        removeHeaderIndex(view);
        notifyUpdateList();
        super.remove(child, destroy);
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
    public void destroy() {
        if (getHostView() != null) {
            getHostView().removeCallbacks(listUpdateRunnable);
        }
        super.destroy();
    }

    @Override
    public void onRefresh() {
        isLoading = true;
        isRefreshing = true;
        v_swipeRefresh.setRefreshing(true);
        if (getEvents().contains(eeuiConstants.Event.REFRESH_LISTENER)) {
            Map<String, Object> data = new HashMap<>();
            data.put("realLastPosition", mAdapter.getRealLastPosition());
            data.put("lastVisibleItem", lastVisibleItem);
            fireEvent(eeuiConstants.Event.REFRESH_LISTENER, data);
        }
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

            case "pullTips":
                mAdapter.setPullTips(eeuiParse.parseBool(val, true) && getEvents().contains(eeuiConstants.Event.PULLLOAD_LISTENER));
                return true;

            case "pullTipsDefault":
                mAdapter.setPullTipsDefault(eeuiParse.parseStr(val, ""));
                return true;

            case "pullTipsLoad":
                mAdapter.setPullTipsLoad(eeuiParse.parseStr(val, ""));
                return true;

            case "pullTipsNo":
                mAdapter.setPullTipsNo(eeuiParse.parseStr(val, ""));
                return true;

            case "itemDefaultAnimator":
                itemDefaultAnimator(eeuiParse.parseBool(val, false));
                return true;

            case "scrollBarEnabled":
                scrollBarEnabled(eeuiParse.parseBool(val, false));
                return true;

            default:
                return false;
        }
    }

    private void initPagerView() {
        v_swipeRefresh = mView.findViewById(R.id.v_swipeRefresh);
        v_recyler = mView.findViewById(R.id.v_recyler);
        v_header = mView.findViewById(R.id.v_header);
        //
        v_swipeRefresh.setColorSchemeResources(android.R.color.holo_blue_light, android.R.color.holo_red_light, android.R.color.holo_orange_light, android.R.color.holo_green_light);
        v_swipeRefresh.setOnRefreshListener(this);
        if (getEvents().contains(eeuiConstants.Event.REFRESH_LISTENER)) {
            isSwipeRefresh = true;
            v_swipeRefresh.setEnabled(true);
        }else{
            isSwipeRefresh = false;
            v_swipeRefresh.setEnabled(false);
        }
        refreshStart = v_swipeRefresh.getProgressViewStartOffset();
        refreshEnd = v_swipeRefresh.getProgressViewEndOffset();
        //
        mAdapter = new RecylerAdapter(getContext());
        mLayoutManager = new GridLayoutManager(getContext(), 1);
        v_recyler.setHasFixedSize(true);
        v_recyler.setLayoutManager(mLayoutManager);
        v_recyler.setAdapter(mAdapter);
        v_recyler.setItemAnimator(new DefaultItemAnimator());
        itemDefaultAnimator(false);
        scrollBarEnabled(false);
        v_recyler.addOnScrollListener(new RecylerOnBottomScrollListener() {
            @Override
            public void onScrollStateChanged(RecyclerView recyclerView, int newState) {
                super.onScrollStateChanged(recyclerView, newState);
                if (mShouldScroll && RecyclerView.SCROLL_STATE_IDLE == newState) {
                    mShouldScroll = false;
                    smoothMoveToPosition(mToPosition);
                }
                if (newState == RecyclerView.SCROLL_STATE_IDLE) {
                    if (!isLoading && !mAdapter.isFadeFooter() && lastVisibleItem + 1 == mAdapter.getItemCount()) {
                        loadData();
                    }
                    if (!isLoading && mAdapter.isFadeFooter() && lastVisibleItem + 2 == mAdapter.getItemCount()) {
                        loadData();
                    }
                }
                if (getEvents().contains(eeuiConstants.Event.SCROLL_STATE_CHANGED)) {
                    Map<String, Object> data = new HashMap<>();
                    data.put("x", recyclerView.computeHorizontalScrollOffset());
                    data.put("y", recyclerView.computeVerticalScrollOffset());
                    data.put("newState", newState);
                    fireEvent(eeuiConstants.Event.SCROLL_STATE_CHANGED, data);
                }
            }

            @Override
            public void onScrolled(RecyclerView recyclerView, int dx, int dy) {
                super.onScrolled(recyclerView, dx, dy);
                loadHeaderIndex(mLayoutManager.findFirstVisibleItemPosition());
                lastVisibleItem = mLayoutManager.findLastVisibleItemPosition();
                if (isSwipeRefresh) {
                    boolean isFirst = mLayoutManager.findFirstCompletelyVisibleItemPosition() == 0;
                    if (isFirst && !isRefreshing && v_swipeRefresh.isRefreshing()) {
                        v_swipeRefresh.setRefreshing(false);
                    }
                    v_swipeRefresh.setEnabled(isFirst);
                }
                if (getEvents().contains(eeuiConstants.Event.SCROLLED)) {
                    Map<String, Object> data = new HashMap<>();
                    data.put("x", recyclerView.computeHorizontalScrollOffset());
                    data.put("y", recyclerView.computeVerticalScrollOffset());
                    data.put("dx", dx);
                    data.put("dy", dy);
                    fireEvent(eeuiConstants.Event.SCROLLED, data);
                }
            }

        });
        mAdapter.setOnItemClickListener(new RecylerAdapter.OnItemClickListener() {
            @Override
            public void onClick(int position) {
                if (getEvents().contains(eeuiConstants.Event.ITEM_CLICK)) {
                    Map<String, Object> data = new HashMap<>();
                    data.put("position", position);
                    fireEvent(eeuiConstants.Event.ITEM_CLICK, data);
                }
            }

            @Override
            public void onLongClick(int position) {
                if (getEvents().contains(eeuiConstants.Event.ITEM_LONG_CLICK)) {
                    Map<String, Object> data = new HashMap<>();
                    data.put("position", position);
                    fireEvent(eeuiConstants.Event.ITEM_LONG_CLICK, data);
                }
            }
        });
        //
        mAdapter.setPullTips(getEvents().contains(eeuiConstants.Event.PULLLOAD_LISTENER));
    }

    private void notifyUpdateList() {
        if (getHostView() == null || listUpdateRunnable == null) {
            return;
        }
        if (Looper.getMainLooper().getThread().getId() != Thread.currentThread().getId()) {
            getHostView().removeCallbacks(listUpdateRunnable);
            getHostView().post(listUpdateRunnable);
        } else {
            listUpdateRunnable.run();
        }
    }

    private void notifyUpdateFoot() {
        footIdentify++;
        int tempId = footIdentify;
        mHandler.postDelayed(()-> {
            if (tempId == footIdentify) {
                v_recyler.post(()-> {
                    if (getHostView() != null && mAdapter != null) {
                        mAdapter.notifyItemChanged(mAdapter.getItemCount() - 1);
                        loadHeaderIndex(mLayoutManager.findFirstVisibleItemPosition());
                    }
                });
            }
        }, 100);
    }

    /**
     * 加载数据
     */
    private void loadData() {
        isLoading = true;
        if (hasMore) {
            if (getEvents().contains(eeuiConstants.Event.PULLLOAD_LISTENER)) {
                Map<String, Object> data = new HashMap<>();
                data.put("realLastPosition", mAdapter.getRealLastPosition());
                data.put("lastVisibleItem", lastVisibleItem);
                fireEvent(eeuiConstants.Event.PULLLOAD_LISTENER, data);
            }
        }else{
            mAdapter.updateList(-1, null, false);
            notifyUpdateFoot();
        }
    }

    /**
     * 顶部悬浮相关
     * @param firstPos
     */
    private void loadHeaderIndex(int firstPos) {
        if (!isHeaderFloat) {
            return;
        }
        ViewItem item = null;
        int index;
        for (index = mAdapter.getItemCount() - 1; index >= 0; --index) {
            if (index > firstPos) {
                continue;
            }
            ViewItem temp = mAdapter.getItemView(index);
            if (temp.isScrollHeader()) {
                item = temp;
                break;
            }
        }
        if (item == null) {
            removeHeaderIndex();
            return;
        }
        if (item.getView() instanceof ScrollHeaderView && ((ScrollHeaderView) item.getView()).getChildCount() > 0) {
            removeHeaderIndex();
            headerViewGroup = (ViewGroup) item.getView();
            if (index == 0 && !item.isPost()) {
                ViewItem finalItem = item;
                headerViewGroup.post(() -> {
                    for (int i = 0; i < headerViewGroup.getChildCount(); i++) {
                        View temp = headerViewGroup.getChildAt(i);
                        if (temp instanceof ScrollHeaderView) {
                            ((ScrollHeaderView) temp).stateChanged("float");
                        }
                        headerViewGroup.removeView(temp);
                        v_header.addView(temp);
                    }
                    finalItem.setPost(true);
                });
            } else {
                for (int i = 0; i < headerViewGroup.getChildCount(); i++) {
                    View temp = headerViewGroup.getChildAt(i);
                    if (temp instanceof ScrollHeaderView) {
                        ((ScrollHeaderView) temp).stateChanged("float");
                    }
                    headerViewGroup.removeView(temp);
                    v_header.addView(temp);
                }
            }
            notifyHeaderIndex();
        }
    }

    /**
     * 顶部悬浮相关
     */
    private void removeHeaderIndex() {
        if (!isHeaderFloat) {
            return;
        }
        if (headerViewGroup == null) {
            return;
        }
        for (int i = 0 ; i < v_header.getChildCount(); i++) {
            View temp = v_header.getChildAt(i);
            if (temp instanceof ScrollHeaderView) {
                ((ScrollHeaderView) temp).stateChanged("static");
            }
            v_header.removeView(temp);
            headerViewGroup.addView(temp);
        }
        headerViewGroup = null;
        notifyHeaderIndex();
    }

    /**
     * 顶部悬浮相关
     * @param view
     */
    private void removeHeaderIndex(View view) {
        if (!isHeaderFloat) {
            return;
        }
        if (view == headerViewGroup) {
            removeHeaderIndex();
            loadHeaderIndex(mLayoutManager.findFirstVisibleItemPosition());
        }
    }

    /**
     * 顶部悬浮相关
     */
    private void notifyHeaderIndex() {
        if (isSwipeRefresh) {
            return;
        }
        refreshIdentify++;
        int tempId = refreshIdentify;
        mHandler.postDelayed(()-> {
            if (tempId == refreshIdentify) {
                v_header.post(()-> {
                    int h = v_header.getMeasuredHeight();
                    v_swipeRefresh.setProgressViewOffset(false, refreshStart + h, refreshStart + refreshEnd + h);
                });
            }
        }, 300);
    }

    /**
     * 滑动到指定位置，并指定位置在顶部
     * @param position
     */
    private void smoothMoveToPosition(final int position) {
        // 第一个可见位置
        int firstItem = v_recyler.getChildLayoutPosition(v_recyler.getChildAt(0));
        // 最后一个可见位置
        int lastItem = v_recyler.getChildLayoutPosition(v_recyler.getChildAt(v_recyler.getChildCount() - 1));
        if (position < firstItem) {
            // 第一种可能:跳转位置在第一个可见位置之前
            v_recyler.smoothScrollToPosition(position);
        } else if (position <= lastItem) {
            // 第二种可能:跳转位置在第一个可见位置之后
            int movePosition = position - firstItem;
            if (movePosition >= 0 && movePosition < v_recyler.getChildCount()) {
                int top = v_recyler.getChildAt(movePosition).getTop();
                v_recyler.smoothScrollBy(0, top);
            }
        } else {
            // 第三种可能:跳转位置在最后可见项之后
            v_recyler.smoothScrollToPosition(position);
            mToPosition = position;
            mShouldScroll = true;
        }
    }

    /***************************************************************************************************/
    /***************************************************************************************************/
    /***************************************************************************************************/

    /**
     * 设置下拉刷新状态
     * @param var
     */
    @JSMethod
    public void setRefreshing(boolean var){
        if (var) {
            if (!v_swipeRefresh.isRefreshing()) {
                onRefresh();
            }
        }else{
            isLoading = false;
            v_swipeRefresh.post(()-> {
                isRefreshing = false;
                v_swipeRefresh.setRefreshing(false);
            });
        }
    }

    /**
     * 下拉刷新结束标记
     */
    @JSMethod
    public void refreshed() {
        isLoading = false;
        v_swipeRefresh.post(()-> {
            isRefreshing = false;
            v_swipeRefresh.setRefreshing(false);
        });
    }

    /**
     * 设置下拉刷新是否可用
     */
    @JSMethod
    public void refreshEnabled(boolean enabled) {
        isSwipeRefresh = enabled;
        v_swipeRefresh.setEnabled(enabled);
    }

    /**
     * 设置是否有上拉加载更多的数据
     * @param var
     */
    @JSMethod
    public void setHasMore(boolean var){
        hasMore = var;
        if (mAdapter != null) {
            mAdapter.updateList(-1, null, hasMore);
            notifyUpdateFoot();
        }
    }

    /**
     * 上拉加载结束标记
     */
    @JSMethod
    public void pullloaded() {
        isLoading = false;
    }

    /**
     * 打开关闭局部刷新默认动画
     */
    @JSMethod
    public void itemDefaultAnimator(boolean open) {
        if (v_recyler != null) {
            RecyclerView.ItemAnimator m = v_recyler.getItemAnimator();
            if (m == null) {
                return;
            }
            if (open) {
                m.setAddDuration(120);
                m.setChangeDuration(250);
                m.setMoveDuration(250);
                m.setRemoveDuration(120);
                ((SimpleItemAnimator) m).setSupportsChangeAnimations(true);
            }else{
                m.setAddDuration(0);
                m.setChangeDuration(0);
                m.setMoveDuration(0);
                m.setRemoveDuration(0);
                ((SimpleItemAnimator) m).setSupportsChangeAnimations(false);
            }
        }
    }

    /**
     * 显隐滚动条
     * @param enabled
     */
    @JSMethod
    public void scrollBarEnabled(boolean enabled) {
        if (v_recyler != null) {
            v_recyler.setVerticalScrollBarEnabled(enabled);
        }
    }

    /**
     * 滚动到指定位置
     */
    @JSMethod
    public void scrollToPosition(int position) {
        if (v_recyler != null && mAdapter != null) {
            if (position == -1) {
                position = mAdapter.getItemCount() - 1;
            }
            v_recyler.scrollToPosition(position);
            //
            LinearLayoutManager mLayoutManager = (LinearLayoutManager) v_recyler.getLayoutManager();
            if (mLayoutManager != null) {
                mLayoutManager.scrollToPositionWithOffset(position, 0);
            }
        }
    }

    /**
     * 平滑滚动到指定位置
     */
    @JSMethod
    public void smoothScrollToPosition(int position) {
        if (v_recyler != null && mAdapter != null) {
            if (position == -1) {
                position = mAdapter.getItemCount() - 1;
            }
            smoothMoveToPosition(position);
        }
    }
}
