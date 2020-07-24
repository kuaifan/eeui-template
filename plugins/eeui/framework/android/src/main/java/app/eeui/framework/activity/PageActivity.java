package app.eeui.framework.activity;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.content.res.TypedArray;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Color;
import android.graphics.drawable.Drawable;
import android.os.Build;
import android.os.Bundle;
import android.os.Handler;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.swiperefreshlayout.widget.SwipeRefreshLayout;
import androidx.appcompat.app.AppCompatActivity;
import android.text.TextUtils;
import android.util.AndroidRuntimeException;
import android.util.Log;
import android.util.TypedValue;
import android.view.Gravity;
import android.view.View;
import android.view.ViewGroup;
import android.view.Window;
import android.view.WindowManager;
import android.webkit.WebView;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.SeekBar;
import android.widget.TextView;
import android.widget.Toast;

import com.alibaba.fastjson.JSON;
import com.alibaba.fastjson.JSONArray;
import com.alibaba.fastjson.JSONObject;
import com.gyf.immersionbar.ImmersionBar;
import com.rabtman.wsmanager.WsManager;
import com.rabtman.wsmanager.listener.WsStatusListener;
import com.taobao.weex.IWXRenderListener;
import com.taobao.weex.WXSDKInstance;
import com.taobao.weex.bridge.JSCallback;
import com.taobao.weex.bridge.ResultCallback;
import com.taobao.weex.bridge.WXBridgeManager;
import com.taobao.weex.common.OnWXScrollListener;
import com.taobao.weex.common.WXRenderStrategy;
import com.taobao.weex.dom.WXEvent;
import com.taobao.weex.ui.component.WXComponent;

import java.io.IOException;
import java.io.InputStream;
import java.io.UnsupportedEncodingException;
import java.net.MalformedURLException;
import java.net.URL;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.Timer;
import java.util.TimerTask;
import java.util.concurrent.TimeUnit;

import app.eeui.framework.BuildConfig;
import app.eeui.framework.R;
import app.eeui.framework.extend.bean.PageBean;
import app.eeui.framework.extend.bean.PageStatus;
import app.eeui.framework.extend.integration.actionsheet.ActionItem;
import app.eeui.framework.extend.integration.actionsheet.ActionSheet;
import app.eeui.framework.extend.integration.glide.Glide;
import app.eeui.framework.extend.integration.glide.load.DataSource;
import app.eeui.framework.extend.integration.glide.load.engine.DiskCacheStrategy;
import app.eeui.framework.extend.integration.glide.load.engine.GlideException;
import app.eeui.framework.extend.integration.glide.request.RequestListener;
import app.eeui.framework.extend.integration.glide.request.RequestOptions;
import app.eeui.framework.extend.integration.glide.request.target.SimpleTarget;
import app.eeui.framework.extend.integration.glide.request.target.Target;
import app.eeui.framework.extend.integration.glide.request.transition.Transition;
import app.eeui.framework.extend.integration.iconify.widget.IconTextView;
import app.eeui.framework.extend.integration.statusbarutil.StatusBarUtil;
import app.eeui.framework.extend.integration.swipebacklayout.BGAKeyboardUtil;
import app.eeui.framework.extend.integration.swipebacklayout.BGASwipeBackHelper;
import app.eeui.framework.extend.module.eeuiAlertDialog;
import app.eeui.framework.extend.module.eeuiBase;
import app.eeui.framework.extend.module.eeuiCommon;
import app.eeui.framework.extend.module.eeuiConstants;
import app.eeui.framework.extend.module.eeuiDebug;
import app.eeui.framework.extend.module.eeuiIhttp;
import app.eeui.framework.extend.module.eeuiJson;
import app.eeui.framework.extend.module.eeuiMap;
import app.eeui.framework.extend.module.eeuiPage;
import app.eeui.framework.extend.module.eeuiParse;
import app.eeui.framework.extend.module.eeuiScreenUtils;
import app.eeui.framework.extend.module.eeuiVersionUpdate;
import app.eeui.framework.extend.module.http.HttpResponseParser;
import app.eeui.framework.extend.module.utilcode.util.KeyboardUtils;
import app.eeui.framework.extend.module.utilcode.util.PermissionUtils;
import app.eeui.framework.extend.module.utilcode.util.ScreenUtils;
import app.eeui.framework.extend.module.utilcode.util.SizeUtils;
import app.eeui.framework.extend.view.ExtendWebView;
import app.eeui.framework.extend.view.FloatDragView;
import app.eeui.framework.extend.view.SwipeCaptchaView;
import app.eeui.framework.ui.eeui;
import okhttp3.OkHttpClient;
import okhttp3.Response;

import static android.widget.Toast.LENGTH_SHORT;

public class PageActivity extends AppCompatActivity {

    private static final String TAG = "PageActivity";

    private static boolean hideDev = false;

    private eeui eeuiObj;
    private Handler mHandler = new Handler();

    public String identify;
    private PageBean mPageInfo;
    private String lifecycleLastStatus;
    private boolean isCancelColorForSwipeBack = false;

    private long startLoadTime = 0;
    private long pauseTimeStart = 0;
    private long pauseTimeSecond = 0;

    private Map<String, OnBackPressed> mOnBackPresseds = new HashMap<>();
    public interface OnBackPressed { boolean onBackPressed(); }

    private OnRefreshListener mOnRefreshListener;
    public interface OnRefreshListener { void refresh(String pageName); }

    private Map<String, JSCallback> mOnPageStatusListeners = new HashMap<>();
    private List<ResultCallback<PageStatus>> mOnAppStatusListeners = new LinkedList<>();
    private static List<ResultCallback<String>> tabViewDebug = new LinkedList<>();

    //模板部分
    private ViewGroup mBody, mWeb, mAuto, mError;
    private TextView mErrorCode;
    private ViewGroup mWeexView;
    private FrameLayout mWeexProgress;
    private ImageView mWeexProgressBg;
    private SwipeRefreshLayout mWeexSwipeRefresh;
    private ExtendWebView mWebView;
    private WXSDKInstance mWXSDKInstance;
    private BGASwipeBackHelper mSwipeBackHelper;
    private String mErrorMsg;
    private View mPageInfoView;
    private View mPageLogView;
    private View mPageVersionUpdateView;

    //申请权限部分
    private PermissionUtils mPermissionInstance;

    //滑动验证码部分
    private SwipeCaptchaView v_swipeCaptchaView;
    private SeekBar v_swipeDragBar;
    private int v_swipeNum;

    //标题栏部分
    private LinearLayout titleBar, titleBarLeft, titleBarMiddle, titleBarRight;
    private TextView titleBarTitle, titleBarSubtitle;
    private String navigationBarBackgroundColor = null;
    private boolean titleBarLeftNull = true;

    /****************************************************************************************************/
    /****************************************************************************************************/
    /****************************************************************************************************/

    /**
     * 申请权限专用
     * @param context
     */
    public static void startPermission(final Context context) {
        PageBean mBean = new PageBean();
        mBean.setPageType("permission");
        mBean.setTranslucent(true);
        eeuiPage.openWin(context, mBean);
    }

    /**
     * 滑动验证码专用
     * @param context
     * @param img
     * @param callback
     */
    public static void startSwipeCaptcha(Context context, String img, JSCallback callback) {
        PageBean mBean = new PageBean();
        mBean.setUrl(img);
        mBean.setPageType("swipeCaptcha");
        mBean.setTranslucent(true);
        mBean.setCallback(callback);
        eeuiPage.openWin(context, mBean);
    }

    /**
     * 透明页面专用专用
     * @param context
     * @param callback
     */
    public static void startTransparentPage(Context context, JSCallback callback) {
        PageBean mBean = new PageBean();
        mBean.setPageType("transparentPage");
        mBean.setTranslucent(true);
        mBean.setCallback(callback);
        eeuiPage.openWin(context, mBean);
    }

    /****************************************************************************************************/
    /****************************************************************************************************/
    /****************************************************************************************************/

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        Intent intent = getIntent();
        identify = eeuiCommon.randomString(16);
        mPageInfo = eeuiPage.getPageBean(intent.getStringExtra("name"));

        if (mPageInfo == null) {
            mPageInfo = new PageBean();
        } else {
            setPageStatusListener("__" + mPageInfo.getPageName(), mPageInfo.getCallback());
        }

        switch (mPageInfo.getPageType()) {
            case "permission":
                mPermissionInstance = PermissionUtils.getInstance();
                if (mPermissionInstance.getThemeCallback() != null) {
                    mPermissionInstance.getThemeCallback().onActivityCreate(this);
                }
                break;

            case "swipeCaptcha":

            case "transparentPage":
                break;

            default:
                initSwipeBackFinish();
                break;
        }

        super.onCreate(savedInstanceState);
        try{ getWindow().requestFeature(Window.FEATURE_NO_TITLE); }catch (AndroidRuntimeException ignored) { }
        if (getSupportActionBar() != null){ getSupportActionBar().hide(); }

        if (mPageInfo.getPageName() != null) {
            mPageInfo.setContext(this);
            eeuiPage.setPageBean(mPageInfo.getPageName(), mPageInfo);
        }

        switch (mPageInfo.getPageType()) {
            case "permission":
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                    if (mPermissionInstance.rationale(this)) {
                        finish();
                        return;
                    }
                    if (mPermissionInstance.getPermissionsRequest() != null) {
                        int size = mPermissionInstance.getPermissionsRequest().size();
                        requestPermissions(mPermissionInstance.getPermissionsRequest().toArray(new String[size]), 1);
                    }
                }
                ImmersionBar.with(this).init();
                break;

            case "swipeCaptcha":
                setContentView(R.layout.activity_page_swipe_captcha);
                initSwipeCaptchaPageView();
                ImmersionBar.with(this).init();
                break;

            case "transparentPage":
                setContentView(R.layout.activity_page_transparent);
                ImmersionBar.with(this).init();
                break;

            default:
                setContentView(R.layout.activity_page);
                if (mPageInfo.getUrl() == null || mPageInfo.getUrl().isEmpty()) {
                    finish();
                    return;
                }
                initDefaultPage();
                break;
        }
        setupNaviBar();
        invokeAndKeepAlive("create", null);
    }

    @Override
    public void finish(){
        super.finish();
        if (!mPageInfo.isAnimatedClose()) {
            this.overridePendingTransition(0, 0);
        }else{
            if ("present".contentEquals(mPageInfo.getAnimatedType())) {
                this.overridePendingTransition(R.anim.slide_in_top, R.anim.slide_out_bottom);
            }else if ("push".contentEquals(mPageInfo.getAnimatedType())) {
                this.overridePendingTransition(R.anim.slide_in_left, R.anim.slide_out_right);
            }
        }
    }

    @Override
    public void onStart() {
        super.onStart();
        if (mWXSDKInstance != null) {
            mWXSDKInstance.onActivityStart();
        }
        invokeAndKeepAlive("start", null);
    }

    @Override
    public void onResume() {
        super.onResume();
        if (mWXSDKInstance != null) {
            mWXSDKInstance.onActivityResume();
        }
        if (!"".equals(mPageInfo.getResumeUrl())) {
            mPageInfo.setUrl(mPageInfo.getResumeUrl());
            mPageInfo.setResumeUrl("");
            reload();
        }
        invokeAndKeepAlive("resume", null);
    }

    @Override
    public void onPause() {
        super.onPause();
        if (mWXSDKInstance != null) {
            mWXSDKInstance.onActivityPause();
        }
        if (isFinishing()) {
            if (mPageInfo != null) {
                eeuiPage.removePageBean(mPageInfo.getPageName());
                if (mPageInfo.isSwipeBack()) {
                    KeyboardUtils.unregisterSoftInputChangedListener(this);
                }
            }
            eeui.finishingNumber++;
        }
        invokeAndKeepAlive("pause", null);
    }

    @Override
    public void onStop() {
        super.onStop();
        if (mWXSDKInstance != null) {
            mWXSDKInstance.onActivityStop();
        }
        invokeAndKeepAlive("stop", null);
    }

    @Override
    public void onRestart() {
        super.onRestart();
        invokeAndKeepAlive("restart", null);
    }

    @Override
    public void onRequestPermissionsResult(int requestCode, @NonNull String[] permissions, @NonNull int[] grantResults) {
        if (mPermissionInstance != null) {
            mPermissionInstance.onRequestPermissionsResult(this);
            finish();
        }else{
            if (mWXSDKInstance != null) {
                mWXSDKInstance.onRequestPermissionsResult(requestCode, permissions, grantResults);
            }
            super.onRequestPermissionsResult(requestCode, permissions, grantResults);
        }
    }

    @Override
    public void onActivityResult(int requestCode, int resultCode, Intent data) {
        if (mWXSDKInstance != null) {
            mWXSDKInstance.onActivityResult(requestCode, resultCode, data);
        }
        //
        Map<String, Object> retData = new HashMap<>();
        retData.put("requestCode", requestCode);
        retData.put("resultCode", resultCode);
        retData.put("resultData", data);
        invokeAndKeepAlive("activityResult", retData);
        //
        super.onActivityResult(requestCode, resultCode, data);
    }

    @Override
    public void onDestroy() {
        if (mWXSDKInstance != null) {
            mWXSDKInstance.onActivityDestroy();
        }
        if (mWebView != null) {
            mWebView.onDestroy();
        }
        if (BuildConfig.DEBUG) {
            if (eeui.getActivityList().size() == 1) {
                eeuiCommon.setVariate("__system:deBugSocket:Init", 0);
                if (PageActivity.hideDev) {
                    PageActivity.hideDev = false;
                }
            }
            closeConsole();
        }
        identify = "";
        invoke("destroy", null);
        super.onDestroy();
        //
        eeui.finishingNumber--;
        Log.d("gggggggg", "onDestroy: " + (mPageInfo == null ? "" : mPageInfo.getPageName()));
    }

    @Override
    public void onBackPressed() {
        // 正在滑动返回的时候取消返回按钮事件
        if (mSwipeBackHelper != null) {
            if (mSwipeBackHelper.isSliding()) {
                return;
            }
        }
        if (mWebView != null) {
            if (mWebView.canGoBack()) {
                mWebView.goBack();
                return;
            }
        }
        if (mPageInfoView != null) {
            mBody.removeView(mPageInfoView);
            mPageInfoView = null;
            return;
        }
        if (!mPageInfo.isBackPressedClose()) {
            return;
        }
        if (mOnBackPresseds != null) {
            for (String name : mOnBackPresseds.keySet()) {
                OnBackPressed pressed = mOnBackPresseds.get(name);
                if (pressed != null && pressed.onBackPressed()) {
                    return;
                }
            }
        }
        BGAKeyboardUtil.closeKeyboard(this);
        super.onBackPressed();
    }

    /****************************************************************************************************/
    /****************************************************************************************************/
    /****************************************************************************************************/

    /**
     * 初始化滑动验证视图
     */
    private void initSwipeCaptchaPageView() {
        v_swipeCaptchaView = findViewById(R.id.v_swipeCaptchaView);
        v_swipeDragBar = findViewById(R.id.v_swipeDragBar);
        //
        int bodyWidth = (int) (ScreenUtils.getScreenWidth() * 0.8f);
        eeuiCommon.setViewWidthHeight(findViewById(R.id.v_swipeBody), bodyWidth, -1);
        findViewById(R.id.v_swipeClose).setOnClickListener(view -> finish());
        //
        v_swipeCaptchaView.setOnCaptchaMatchCallback(new SwipeCaptchaView.OnCaptchaMatchCallback() {
            @Override
            public void matchSuccess(SwipeCaptchaView mSwipeCaptchaView) {
                invokeAndKeepAlive("success", null);
                //
                v_swipeDragBar.setEnabled(false);
                mHandler.postDelayed(()-> finish(), 300);
            }

            @Override
            public void matchFailed(SwipeCaptchaView mSwipeCaptchaView) {
                invokeAndKeepAlive("failed", null);
                //
                if (v_swipeNum > 1) {
                    v_swipeNum = 0;
                    mSwipeCaptchaView.createCaptcha();
                }else{
                    v_swipeNum++;
                    mSwipeCaptchaView.resetCaptcha();
                }
                v_swipeDragBar.setProgress(0);
            }
        });
        v_swipeDragBar.setOnSeekBarChangeListener(new SeekBar.OnSeekBarChangeListener() {
            @Override
            public void onProgressChanged(SeekBar seekBar, int progress, boolean fromUser) {
                v_swipeCaptchaView.setCurrentSwipeValue(progress);
            }

            @Override
            public void onStartTrackingTouch(SeekBar seekBar) {
                v_swipeDragBar.setMax(v_swipeCaptchaView.getMaxSwipeValue());
            }

            @Override
            public void onStopTrackingTouch(SeekBar seekBar) {
                v_swipeCaptchaView.matchCaptcha();
            }
        });
        //
        Glide.with(this)
                .asBitmap()
                .load(mPageInfo.getUrl() != null && !mPageInfo.getUrl().isEmpty() ? mPageInfo.getUrl() : R.drawable.swipecaptcha_bg)
                .into(new SimpleTarget<Bitmap>() {
                    @Override
                    public void onResourceReady(Bitmap resource, Transition<? super Bitmap> transition) {
                        ViewGroup.LayoutParams params = v_swipeCaptchaView.getLayoutParams();
                        params.width = bodyWidth - SizeUtils.dp2px(28);
                        params.height = (int) eeuiCommon.scaleHeight(params.width, resource.getWidth(), resource.getHeight());
                        v_swipeCaptchaView.setLayoutParams(params);
                        //
                        v_swipeCaptchaView.setImageBitmap(resource);
                        v_swipeCaptchaView.createCaptcha();
                    }
                });
    }

    /**
     * 初始化默认页
     */
    private void initDefaultPage() {
        mBody = findViewById(R.id.v_body);
        mError = findViewById(R.id.v_error);
        mErrorCode = findViewById(R.id.v_error_code);
        //
        findViewById(R.id.v_refresh).setOnClickListener(view -> reload());
        findViewById(R.id.v_back).setOnClickListener(view -> finish());
        //
        TextView errorInfo = findViewById(R.id.v_error_info);
        if (BuildConfig.DEBUG) {
            errorInfo.setOnClickListener(view -> showPageInfo(mErrorMsg));
        }else{
            errorInfo.setText("抱歉！页面出现错误了");
        }
        //
        mSwipeBackHelper.setSwipeBackEnable(mPageInfo.isSwipeBack());
        mBody.setBackgroundColor(Color.parseColor(mPageInfo.getBackgroundColor()));
        //
        initStatusBar();
        initDefaultPageView();
    }

    /**
     * 初始化默认视图
     */
    private void initStatusBar() {
        if ("immersion".equals(mPageInfo.getStatusBarType())) {
            //沉浸式
            if (mPageInfo.getSoftInputMode().equals("auto")) {
                mPageInfo.setSoftInputMode("nothing");
            }
            ImmersionBar iBar = ImmersionBar.with(this);
            if (mPageInfo.getStatusBarStyle() != null) {
                iBar.statusBarDarkFont(!mPageInfo.getStatusBarStyle());
            }
            iBar.keyboardEnable(true);
            iBar.keyboardMode(this.convertSoftInputMode(mPageInfo.getSoftInputMode()));
            iBar.init();
            return;
        }
        if ("fullscreen".equals(mPageInfo.getStatusBarType())) {
            //全屏
            getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN, WindowManager.LayoutParams.FLAG_FULLSCREEN);
            if (mPageInfo.getSoftInputMode().equals("auto")) {
                mPageInfo.setSoftInputMode("nothing");
            }
        } else {
            //默认
            if (mPageInfo.isSwipeBack() && mPageInfo.isSwipeColorBack() && Build.VERSION.SDK_INT > Build.VERSION_CODES.KITKAT) {
                StatusBarUtil.setColorForSwipeBack(this, Color.parseColor(mPageInfo.getStatusBarColor()), mPageInfo.getStatusBarAlpha());
                KeyboardUtils.registerSoftInputChangedListener(this, (int height) -> {
                    if (KeyboardUtils.isSoftInputVisible(this)) {
                        KeyboardUtils.unregisterSoftInputChangedListener(this);
                        isCancelColorForSwipeBack = true;
                        StatusBarUtil.cancelColorForSwipeBack(this);
                        StatusBarUtil.setColor(this, Color.parseColor(mPageInfo.getStatusBarColor()), mPageInfo.getStatusBarAlpha());
                        if (mPageInfo.getStatusBarStyle() != null) {
                            if (mPageInfo.getStatusBarStyle()) {
                                StatusBarUtil.setDarkMode(this, isCancelColorForSwipeBack);
                            } else {
                                StatusBarUtil.setLightMode(this, isCancelColorForSwipeBack);
                            }
                        }
                    }
                });
            } else {
                isCancelColorForSwipeBack = true;
                StatusBarUtil.setColor(this, Color.parseColor(mPageInfo.getStatusBarColor()), mPageInfo.getStatusBarAlpha());
            }
        }
        //
        if (mPageInfo.getStatusBarStyle() != null) {
            if (mPageInfo.getStatusBarStyle()) {
                StatusBarUtil.setDarkMode(this, isCancelColorForSwipeBack);
            } else {
                StatusBarUtil.setLightMode(this, isCancelColorForSwipeBack);
            }
        }
        getWindow().setSoftInputMode(this.convertSoftInputMode((mPageInfo.getSoftInputMode())));
    }

    /**
     * 初始化默认视图
     */
    private void initDefaultPageView() {
        switch (mPageInfo.getPageType()) {
            case "web":
                mWeb = findViewById(R.id.v_web);
                mWeb.setVisibility(View.VISIBLE);
                //
                mWebView = new ExtendWebView(this, null);
                ViewGroup parentViewGroup = (ViewGroup) mWebView.getParent();
                if (parentViewGroup != null ) {
                    parentViewGroup.removeView(mWebView);
                }
                mWeb.addView(mWebView, new LinearLayout.LayoutParams(LinearLayout.LayoutParams.MATCH_PARENT, LinearLayout.LayoutParams.MATCH_PARENT));
                //
                mWebView.setProgressbarVisibility(mPageInfo.isLoading());
                mWebView.setOnStatusClient(new ExtendWebView.StatusCall() {
                    @Override
                    public void onStatusChanged(WebView view, String status) {
                        Map<String, Object> retData = new HashMap<>();
                        retData.put("webStatus", status);
                        invokeAndKeepAlive("statusChanged", retData);
                    }

                    @Override
                    public void onErrorChanged(WebView view, int errorCode, String description, String failingUrl) {
                        Map<String, Object> retData = new HashMap<>();
                        retData.put("webStatus", "error");
                        retData.put("errCode", errorCode);
                        retData.put("errMsg", description);
                        retData.put("errUrl", failingUrl);
                        invokeAndKeepAlive("errorChanged", retData);
                    }

                    @Override
                    public void onTitleChanged(WebView view, String title) {
                        Map<String, Object> retData = new HashMap<>();
                        retData.put("webStatus", "title");
                        retData.put("title", title);
                        invokeAndKeepAlive("titleChanged", retData);
                    }

                    @Override
                    public void onUrlChanged(WebView view, String url) {
                        Map<String, Object> retData = new HashMap<>();
                        retData.put("webStatus", "url");
                        retData.put("url", url);
                        invokeAndKeepAlive("titleChanged", retData);
                    }
                });
                mWebView.loadUrl(mPageInfo.getUrl());
                break;

            case "app":
            case "weex":
                mWeexView = findViewById(R.id.v_weexview);
                mWeexProgress = findViewById(R.id.v_weexprogress);
                mWeexProgressBg = findViewById(R.id.v_weexprogressbg);

                mWeexSwipeRefresh = findViewById(R.id.v_weexswiperefresh);
                mWeexSwipeRefresh.setVisibility(View.VISIBLE);
                mWeexSwipeRefresh.setColorSchemeResources(android.R.color.holo_blue_light, android.R.color.holo_red_light, android.R.color.holo_orange_light, android.R.color.holo_green_light);
                mWeexSwipeRefresh.setOnRefreshListener(() -> {
                    if (mOnRefreshListener != null) mOnRefreshListener.refresh(mPageInfo.getPageName());
                });
                mWeexSwipeRefresh.setEnabled(mOnRefreshListener != null);

                weexLoad();
                break;

            case "auto":
                if (mPageInfo.getUrl().endsWith(".bundle.wx")) {
                    mPageInfo.setPageType("app");
                    initDefaultPageView();
                    break;
                }
                if (mPageInfo.getUrl().contains("?_wx_tpl=")) {
                    String outurl = eeuiCommon.getMiddle(mPageInfo.getUrl(), "?_wx_tpl=", null);
                    try {
                        outurl = java.net.URLDecoder.decode(outurl, "UTF-8");
                    } catch (UnsupportedEncodingException e) {
                        e.printStackTrace();
                    }
                    mPageInfo.setPageType("app");
                    mPageInfo.setUrl(outurl);
                    initDefaultPageView();
                    break;
                }
                mAuto = findViewById(R.id.v_auto);
                mAuto.setVisibility(View.VISIBLE);
                eeuiIhttp.get("pageAuto", mPageInfo.getUrl(), null, new eeuiIhttp.ResultCallback() {
                    @Override
                    public void progress(long total, long current, boolean isDownloading) {

                    }

                    @Override
                    public void success(HttpResponseParser resData, boolean isCache) {
                        String html = "";
                        if (!TextUtils.isEmpty(resData.getBody())) {
                            String[] temp = resData.getBody().split("\n");
                            if (temp.length > 0) {
                                html = temp[0];
                                html = html.replaceAll(" ", "");
                            }
                        }
                        mPageInfo.setPageType(html.startsWith("//{\"framework\":\"Vue\"") ? "app" : "web");
                        initDefaultPageView();
                        mAuto.setVisibility(View.GONE);
                    }

                    @Override
                    public void error(String error, int errCode) {
                        finish();
                    }

                    @Override
                    public void complete() {

                    }
                });
                break;

            default:
                finish();
        }
    }

    /****************************************************************************************************/
    /****************************************************************************************************/
    /****************************************************************************************************/

    /**
     * SwipeBack
     * 初始化滑动返回
     */
    private void initSwipeBackFinish() {
        mSwipeBackHelper = new BGASwipeBackHelper(this, swipeBackDelegate());
        // 设置滑动返回是否可用。默认值为 true
        mSwipeBackHelper.setSwipeBackEnable(true);
        // 设置是否仅仅跟踪左侧边缘的滑动返回。默认值为 true
        mSwipeBackHelper.setIsOnlyTrackingLeftEdge(!mPageInfo.isSwipeFullBack());
        // 设置是否是微信滑动返回样式。默认值为 true
        mSwipeBackHelper.setIsWeChatStyle(true);
        // 设置阴影资源 id。默认值为 R.drawable.bga_sbl_shadow
        mSwipeBackHelper.setShadowResId(R.drawable.bga_sbl_shadow);
        // 设置是否显示滑动返回的阴影效果。默认值为 true
        mSwipeBackHelper.setIsNeedShowShadow(true);
        // 设置阴影区域的透明度是否根据滑动的距离渐变。默认值为 true
        mSwipeBackHelper.setIsShadowAlphaGradient(true);
        // 设置触发释放后自动滑动返回的阈值，默认值为 0.3f
        mSwipeBackHelper.setSwipeBackThreshold(0.3f);
        // 设置底部导航条是否悬浮在内容上，默认值为 false
        mSwipeBackHelper.setIsNavigationBarOverlap(false);
    }

    /**
     * SwipeBack
     * @return
     */
    private BGASwipeBackHelper.Delegate swipeBackDelegate() {
        return new BGASwipeBackHelper.Delegate() {
            /**
             * SwipeBack
             * 是否支持滑动返回
             * @return
             */
            @Override
            public boolean isSupportSwipeBack() {
                return true;
            }

            /**
             * SwipeBack
             * 正在滑动返回
             * @param slideOffset 从 0 到 1
             */
            @Override
            public void onSwipeBackLayoutSlide(float slideOffset) {
            }

            /**
             * SwipeBack
             * 没达到滑动返回的阈值，取消滑动返回动作，回到默认状态
             */
            @Override
            public void onSwipeBackLayoutCancel() {
            }

            /**
             * SwipeBack
             * 滑动返回执行完毕，销毁当前 Activity
             */
            @Override
            public void onSwipeBackLayoutExecuted() {
                if (mSwipeBackHelper != null) {
                    mSwipeBackHelper.swipeBackward();
                }
            }
        };
    }

    /****************************************************************************************************/
    /****************************************************************************************************/
    /****************************************************************************************************/

    /**
     * Weex
     */
    private void weexLoad() {
        if (mPageInfo.isLoading()) {
            mWeexProgress.setVisibility(View.INVISIBLE);
            mHandler.postDelayed(()-> mWeexProgress.post(()->{
                if (mWeexProgress.getVisibility() == View.INVISIBLE) {
                    mWeexProgress.setVisibility(View.VISIBLE);
                    if (!mPageInfo.isTranslucent() && mPageInfo.isLoadingBackground()) {
                        mWeexProgressBg.setVisibility(View.VISIBLE);
                    }
                }
            }), 100);
        }
        //
        weexCreateInstance();
        mWXSDKInstance.onActivityCreate();
        eeuiPage.cachePage(this, eeuiBase.config.verifyFile(mPageInfo.getUrl()), mPageInfo.getCache(), mPageInfo.getParams(), new eeuiPage.OnCachePageCallback() {
            @Override
            public void success(Map<String, Object> resParams, String newUrl) {
                mWXSDKInstance.renderByUrl(mPageInfo.getPageName(), newUrl, resParams, null, WXRenderStrategy.APPEND_ASYNC);
            }

            @Override
            public void error(Map<String, Object> resParams, String newUrl) {
                Map<String, Object> retData = new HashMap<>();
                retData.put("errCode", -5202);
                retData.put("errMsg", "加载页面失败或不存在！");
                retData.put("errUrl", newUrl);
                invokeAndKeepAlive("error", retData);
                //
                mError.setVisibility(View.VISIBLE);
                mErrorCode.setText(String.valueOf(-5202));
                mErrorMsg = "加载页面失败或不存在！";
                //
                eeuiDebug.addDebug("error", mErrorMsg + " (errCode:" + mErrorCode.getText() + ")", mPageInfo.getUrl());
            }
        });
    }

    /**
     * Weex
     */
    private void weexCreateInstance() {
        if (mWXSDKInstance != null) {
            mWXSDKInstance.registerRenderListener(null);
            mWXSDKInstance.registerOnWXScrollListener(null);
            mWXSDKInstance.destroy();
            mWXSDKInstance = null;
        }
        mWXSDKInstance = new WXSDKInstance(this);
        mWXSDKInstance.registerRenderListener(weexIWXRenderListener());
        mWXSDKInstance.registerOnWXScrollListener(weexOnWXScrollListener());
    }

    /**
     * Weex
     * @return
     */
    private IWXRenderListener weexIWXRenderListener() {
        return new IWXRenderListener() {
            @Override
            public void onViewCreated(WXSDKInstance instance, View view) {
                if (mWeexView != null) {
                    mWeexView.removeAllViews();
                    mWeexView.addView(view);
                }
                invokeAndKeepAlive("viewCreated", null);
            }

            @Override
            public void onRenderSuccess(WXSDKInstance instance, int width, int height) {
                if (mWeexProgress != null) {
                    mWeexProgress.setVisibility(View.GONE);
                }
                invokeAndKeepAlive("renderSuccess", null);
            }

            @Override
            public void onRefreshSuccess(WXSDKInstance instance, int width, int height) {
                if (mWeexProgress != null) {
                    mWeexProgress.setVisibility(View.GONE);
                }
            }

            /**
             * Weex
             * @param instance
             * @param errCode
             * @param errMsg
             */
            @Override
            public void onException(WXSDKInstance instance, String errCode, String errMsg) {
                if (mWeexProgress != null) {
                    mWeexProgress.setVisibility(View.GONE);
                }
                if (errCode == null) {
                    errCode = "";
                }
                //
                Map<String, Object> retData = new HashMap<>();
                retData.put("errCode", errCode);
                retData.put("errMsg", errMsg);
                retData.put("errUrl", instance.getBundleUrl() == null ? "" : instance.getBundleUrl());
                invokeAndKeepAlive("error", retData);
                //
                mError.setVisibility(View.VISIBLE);
                mErrorCode.setText(errCode);
                mErrorMsg = errMsg;
                //
                eeuiDebug.addDebug("error", mErrorMsg + " (errCode:" + mErrorCode.getText() + ")", mPageInfo.getUrl());
            }
        };
    }

    /**
     * Weex
     * @return
     */
    private OnWXScrollListener weexOnWXScrollListener() {
        return new OnWXScrollListener() {
            @Override
            public void onScrolled(View view, int x, int y) {

            }

            @Override
            public void onScrollStateChanged(View view, int x, int y, int newState) {
                if (mOnRefreshListener != null) {
                    if (y == 0) {
                        mWeexSwipeRefresh.setEnabled(true);
                    }else{
                        mWeexSwipeRefresh.setEnabled(false);
                    }
                }
            }
        };
    }

    /****************************************************************************************************/
    /****************************************************************************************************/
    /****************************************************************************************************/

    private void invoke(String status, Map<String, Object> retData) {
        if (status.equals(lifecycleLastStatus)) {
            return;
        }
        lifecycleLastStatus = status;
        lifecycleListener(status);
        //
        if (mOnPageStatusListeners.size() > 0) {
            if (retData == null) {
                retData = new HashMap<>();
            }
            retData.put("pageName", mPageInfo.getPageName());
            retData.put("status", status);
            for (String name : mOnPageStatusListeners.keySet()) {
                JSCallback call = mOnPageStatusListeners.get(name);
                if (call != null) {
                    call.invoke(retData);
                }
            }
        }
    }

    private void invokeAndKeepAlive(String status, Map<String, Object> retData) {
        if (status.equals(lifecycleLastStatus)) {
            return;
        }
        lifecycleLastStatus = status;
        lifecycleListener(status);
        //
        if ("viewCreated".contentEquals(status)) {
            mPageInfo.setLoadTime(eeuiCommon.timeStamp());
        }
        //
        if (mOnPageStatusListeners.size() > 0) {
            for (String name : mOnPageStatusListeners.keySet()) {
                JSCallback call = mOnPageStatusListeners.get(name);
                if (call != null) {
                    if (retData == null) retData = new HashMap<>();
                    retData.put("pageName", mPageInfo.getPageName());
                    retData.put("status", status);
                    call.invokeAndKeepAlive(retData);
                }
            }
        }
        if (status.equals("success") && eeuiJson.getBoolean(mPageInfo.getOtherObject(), "successClose")) {
            finish();
        }
        //
        switch (status) {
            case "create":
                deBugButtonCreate();
                break;

            case "resume":
                deBugButtonRefresh(0);
                break;

            case "error":
            case "viewCreated":
                mHandler.postDelayed(this::deBugSocketInit, 300);
                break;
        }
    }

    private void lifecycleListener(String status) {
        if (mWXSDKInstance != null) {
            switch (status) {
                case "viewCreated":
                    status = "ready";
                    if (startLoadTime == 0) {
                        startLoadTime = eeuiCommon.timeStamp();
                    }
                    break;

                case "resume":
                case "pause":
                    if (isFinishing()) {
                        durationTime();
                    }
                    if ("pause".equals(status)) {
                        pauseTimeStart = eeuiCommon.timeStamp();
                    } else if (pauseTimeStart > 0) {
                        pauseTimeSecond += Math.max(eeuiCommon.timeStamp() - pauseTimeStart, 0);
                    }
                    break;

                default:
                    return;
            }
            //
            WXComponent mWXComponent = mWXSDKInstance.getRootComponent();
            if (mWXComponent != null) {
                WXEvent events = mWXComponent.getEvents();
                boolean hasEvent = events.contains(eeuiConstants.Event.LIFECYCLE);
                if (hasEvent) {
                    Map<String, Object> retData = new HashMap<>();
                    retData.put("status", status);
                    WXBridgeManager.getInstance().fireEventOnNode(mWXSDKInstance.getInstanceId(), mWXComponent.getRef(), eeuiConstants.Event.LIFECYCLE, retData, null);
                    //
                    Map<String, Object> retAgain = new HashMap<>();
                    switch (status) {
                        case "ready": {
                            retAgain.put("status", "resume");
                            WXBridgeManager.getInstance().fireEventOnNode(mWXSDKInstance.getInstanceId(), mWXComponent.getRef(), eeuiConstants.Event.LIFECYCLE, retAgain, null);
                            break;
                        }
                        case "pause": {
                            if (isFinishing()) {
                                retAgain.put("status", "destroy");
                                WXBridgeManager.getInstance().fireEventOnNode(mWXSDKInstance.getInstanceId(), mWXComponent.getRef(), eeuiConstants.Event.LIFECYCLE, retAgain, null);
                            }
                            break;
                        }
                    }
                }
            }
            //
            Map<String, Object> retApp = new HashMap<>();
            retApp.put("status", status);
            retApp.put("type", "page");
            retApp.put("pageType", getPageInfo().getPageType());
            retApp.put("pageName", getPageInfo().getPageName());
            retApp.put("pageUrl", getPageInfo().getUrl());
            mWXSDKInstance.fireGlobalEventCallback("__appLifecycleStatus", retApp);
            //
            Map<String, Object> retAgain = new HashMap<>();
            switch (status) {
                case "ready": {
                    retAgain.putAll(retApp);
                    retAgain.put("status", "resume");
                    mWXSDKInstance.fireGlobalEventCallback("__appLifecycleStatus", retAgain);
                    break;
                }
                case "pause": {
                    if (isFinishing()) {
                        retAgain.putAll(retApp);
                        retAgain.put("status", "destroy");
                        mWXSDKInstance.fireGlobalEventCallback("__appLifecycleStatus", retAgain);
                    }
                    break;
                }
            }
        }
    }

    private void durationTime() {
        long timeStamp = eeuiCommon.timeStamp();
        long duration = timeStamp - startLoadTime - pauseTimeSecond;
        String url = mPageInfo.getUrl();
        if (url.startsWith("file://")) {
            url = eeuiCommon.getMiddle(url, "eeui", null);
        }
        if (duration > 0) {
            JSONObject obj = new JSONObject();
            obj.put("s", startLoadTime);
            obj.put("d", duration);
            obj.put("p", pauseTimeSecond);
            obj.put("u", url);
            long submitTime = eeuiParse.parseLong(eeuiCommon.getCaches(this, "__system:pageDurationSubmitTime", 0));
            JSONArray data = eeuiJson.parseArray(eeuiCommon.getCaches(this, "__system:pageDurationData", null));
            data.add(obj);
            //
            if (timeStamp - submitTime >= 60 || data.size() > 50 || mPageInfo.isFirstPage()) {
                eeuiCommon.setCaches(this, "__system:pageDurationSubmitTime", timeStamp, 60);
                durationSubmit(data);
                data = new JSONArray();
            }
            eeuiCommon.setCaches(this, "__system:pageDurationData", data, 0);
        }
    }

    private void durationSubmit(JSONArray array) {
        if (array.size() == 0) {
            return;
        }
        String appkey = eeuiBase.config.getString("appKey", "");
        if (appkey.length() == 0) {
            return;
        }
        Map<String, Object> data = new HashMap<>();
        data.put("setting:timeout", 30000);
        data.put("firstpage", mPageInfo.isFirstPage() ? 1 : 0);
        data.put("data", array.toJSONString());
        data.put("appkey", appkey);
        data.put("package", eeui.getApplication().getPackageName());
        data.put("version", eeuiCommon.getLocalVersion(eeui.getApplication()));
        data.put("versionName", eeuiCommon.getLocalVersionName(eeui.getApplication()));
        data.put("screenWidth", ScreenUtils.getScreenWidth());
        data.put("screenHeight", ScreenUtils.getScreenHeight());
        data.put("platform", "android");
        data.put("debug", BuildConfig.DEBUG ? 1 : 0);
        eeuiIhttp.post("duration", eeuiBase.cloud.getUrl("duration"), data, new eeuiIhttp.ResultCallback() {
            @Override
            public void progress(long total, long current, boolean isDownloading) {

            }

            @Override
            public void success(HttpResponseParser resData, boolean isCache) {
                JSONObject json = eeuiJson.parseObject(resData.getBody());
                if (json.getIntValue("ret") == 1) {
                    JSONObject retData = json.getJSONObject("data");
                    eeuiBase.cloud.checkUpdateLists(retData.getJSONArray("uplists"), 0);
                    eeuiVersionUpdate.checkUpdate(retData.getJSONObject("version_update"));
                }
            }

            @Override
            public void error(String error, int errCode) {

            }

            @Override
            public void complete() {

            }
        });
    }

    /****************************************************************************************************/
    /****************************************************************************************************/
    /****************************************************************************************************/

    /**
     * 添加app状态监听
     * @param callback
     */
    public void setAppStatusListeners(ResultCallback<PageStatus> callback) {
        mOnAppStatusListeners.add(callback);
    }

    /**
     * 移除app状态监听
     * @param callback
     */
    public void removeAppStatusListeners(ResultCallback<PageStatus> callback) {
        mOnAppStatusListeners.remove(callback);
    }

    /**
     * 触发app状态
     * @param mPageStatus
     */
    public void onAppStatusListener(PageStatus mPageStatus)
    {
        if (TextUtils.isEmpty(mPageStatus.getPageName()) || getPageInfo().getPageName().contentEquals(mPageStatus.getPageName())) {
            if (mWXSDKInstance != null) {
                Map<String, Object> retApp = new HashMap<>();
                retApp.put("status", mPageStatus.getStatus());
                retApp.put("type", mPageStatus.getType());
                retApp.put("pageType", getPageInfo().getPageType());
                retApp.put("pageName", getPageInfo().getPageName());
                retApp.put("pageUrl", getPageInfo().getUrl());
                if (mPageStatus.getMessage() != null) {
                    retApp.put("message", mPageStatus.getMessage());
                }
                mWXSDKInstance.fireGlobalEventCallback("__appLifecycleStatus", retApp);
            }
        }
        //
        for (int i = 0; i < mOnAppStatusListeners.size(); i++) {
            ResultCallback<PageStatus> call = mOnAppStatusListeners.get(i);
            if (call != null) {
                call.onReceiveResult(mPageStatus);
            }
        }
    }

    /****************************************************************************************************/
    /****************************************************************************************************/
    /****************************************************************************************************/

    /**
     * 获取页面详情
     * @return
     */
    public PageBean getPageInfo() {
        return mPageInfo;
    }

    /**
     * 设置地址
     * @param url
     */
    public void setPageUrl(String url) {
        if (mPageInfo != null) {
            mPageInfo.setUrl(eeuiPage.rewriteUrl(this, url));
        }
    }

    /**
     * 刷新页面
     */
    public void reload() {
        if (mError != null) {
            mError.setVisibility(View.GONE);
        }
        identify = eeuiCommon.randomString(16);
        //
        if (titleBar != null) {
            hideNavigation();
            titleBarLeftNull = true;
            titleBarLeft.removeAllViews();
            titleBarRight.removeAllViews();
            titleBarTitle.setVisibility(View.GONE);
            titleBarSubtitle.setVisibility(View.GONE);
            setupNaviBar();
        }
        //
        switch (mPageInfo.getPageType()) {
            case "web":
                mWebView.loadUrl(mPageInfo.getUrl());
                break;

            case "app":
            case "weex":
                weexLoad();
                break;
        }
    }

    /**
     * 设置键盘弹出方式
     * @param mode
     */
    public void setSoftInputMode(String mode) {
        if (mPageInfo == null || mode == null) {
            return;
        }
        mPageInfo.setSoftInputMode(mode);
        initStatusBar();
    }

    /**
     * 设置是否允许滑动返回
     * @param var
     */
    public void setSwipeBackEnable(Boolean var) {
        if (mPageInfo == null || mSwipeBackHelper == null) {
            return;
        }
        mPageInfo.setSwipeBack(var);
        mSwipeBackHelper.setSwipeBackEnable(var);
    }

    /**
     * 设置是否支持全屏滑动返回
     * @param var
     */
    public void setSwipeFullBackEnable(Boolean var) {
        if (mPageInfo == null || mSwipeBackHelper == null) {
            return;
        }
        mPageInfo.setSwipeFullBack(var);
        mSwipeBackHelper.setIsOnlyTrackingLeftEdge(!var);
    }

    /**
     * 跳过禁止返回键关闭直接关闭
     */
    public void onBackPressedSkipBackPressedClose() {
        mPageInfo.setBackPressedClose(true);
        onBackPressed();
    }

    /**
     * 拦截返回按键事件
     * @param key
     * @param mOnBackPressed
     */
    public void setOnBackPressed(String key, OnBackPressed mOnBackPressed) {
        this.mOnBackPresseds.put(key, mOnBackPressed);
    }

    /**
     * 监听下拉刷新事件
     * @param mOnRefreshListener
     */
    public void setOnRefreshListener(OnRefreshListener mOnRefreshListener){
        this.mOnRefreshListener = mOnRefreshListener;
        if (mWeexSwipeRefresh != null) {
            mWeexSwipeRefresh.setEnabled(mOnRefreshListener != null);
        }
    }

    /**
     * 设置下拉刷新状态
     * @param refreshing
     */
    public void setRefreshing(boolean refreshing){
        if (mWeexSwipeRefresh != null) {
            mWeexSwipeRefresh.setRefreshing(refreshing);
        }
    }

    /**
     * 监听页面状态
     * @param listenerName
     * @param mOnPageStatusListener
     */
    public void setPageStatusListener(String listenerName, JSCallback mOnPageStatusListener){
        if (listenerName == null) {
            listenerName = eeuiCommon.randomString(8);
        }
        if (mOnPageStatusListener != null) {
            this.mOnPageStatusListeners.put(listenerName, mOnPageStatusListener);
        }
    }

    /**
     * 取消监听页面状态
     * @param listenerName
     */
    public void clearPageStatusListener(String listenerName){
        if (listenerName == null) {
            return;
        }
        this.mOnPageStatusListeners.remove(listenerName);
    }

    /**
     * 手动执行(触发)页面状态
     * @param listenerName
     * @param status
     */
    public void onPageStatusListener(String listenerName, String status, Object extra) {
        Map<String, Object> retData = new HashMap<>();
        retData.put("extra", extra);
        if (listenerName == null || listenerName.isEmpty()) {
            invokeAndKeepAlive(status, retData);
            return;
        }
        JSCallback callback = this.mOnPageStatusListeners.get(listenerName);
        if (callback != null) {
            retData.put("pageName", mPageInfo.getPageName());
            retData.put("status", status);
            callback.invokeAndKeepAlive(retData);
        }
    }

    /**
     * 修改状态栏字体颜色风格
     * @param isLight
     */
    public void setStatusBarStyle(boolean isLight) {
        if (mPageInfo == null) {
            return;
        }
        mPageInfo.setStatusBarStyle(isLight);
        //
        if (mPageInfo.getStatusBarStyle()) {
            StatusBarUtil.setDarkMode(this, isCancelColorForSwipeBack);
        } else {
            StatusBarUtil.setLightMode(this, isCancelColorForSwipeBack);
        }
    }

    /**
     * 转换键盘类型
     * @param mode
     * @return
     */
    private int convertSoftInputMode(String mode) {
        int keyboardMode = 0;
        switch (mode) {
            case "resize":
                keyboardMode = WindowManager.LayoutParams.SOFT_INPUT_ADJUST_RESIZE;
                break;
            case "pan":
                keyboardMode = WindowManager.LayoutParams.SOFT_INPUT_ADJUST_PAN;
                break;
            case "nothing":
                keyboardMode = WindowManager.LayoutParams.SOFT_INPUT_ADJUST_NOTHING;
                break;
            case "auto":
                keyboardMode = WindowManager.LayoutParams.SOFT_INPUT_ADJUST_UNSPECIFIED;
                break;
        }
        return keyboardMode;
    }

    /**
     * 是否是字体
     * @param var
     * @return
     */
    private boolean isFontIcon(String var) {
        return var != null && !var.contains("//") && !var.startsWith("data:") && !var.endsWith(".png") && !var.endsWith(".jpg") && !var.endsWith(".jpeg") && !var.endsWith(".gif");
    }

    /**
     * 页面名称设置标题栏
     */
    private void setupNaviBar() {
        if (mPageInfo.getPageTitle() != null && !mPageInfo.getPageTitle().isEmpty()) {
            setNavigationTitle(mPageInfo.getPageTitle(), null);
        }
    }

    /**
     * 标题栏组件初始化
     */
    private void navigationInit() {
        if (titleBar == null) {
            titleBar = findViewById(R.id.titleBar);
            titleBarLeft = findViewById(R.id.titleBarLeft);
            titleBarMiddle = findViewById(R.id.titleBarMiddle);
            titleBarRight = findViewById(R.id.titleBarRight);
            titleBarTitle = findViewById(R.id.titleBarTitle);
            titleBarSubtitle = findViewById(R.id.titleBarSubtitle);
        }
    }

    /**
     * 设置页面标题栏标题
     * @param params
     * @param callback
     */
    public void setNavigationTitle(Object params, ResultCallback<JSONObject> callback) {
        if ("fullscreen".equals(mPageInfo.getStatusBarType()) || "immersion".equals(mPageInfo.getStatusBarType())) {
            return;
        }
        navigationInit();
        JSONObject item = new JSONObject();
        if (params instanceof String) {
            item.put("title", params);
        } else {
            item = eeuiJson.parseObject(params);
        }

        JSONObject defaultStyles = eeuiBase.config.getObject("navigationBarStyle");
        String title = eeuiJson.getString(item, "title", eeuiJson.getString(defaultStyles, "title", ""));
        String titleColor = eeuiJson.getString(item, "titleColor", eeuiJson.getString(defaultStyles, "titleColor", ""));
        float titleSize = eeuiJson.getFloat(item, "titleSize", eeuiJson.getFloat(defaultStyles, "titleSize", 32f));
        boolean titleBold = eeuiJson.getBoolean(item, "titleBold", eeuiJson.getBoolean(defaultStyles, "titleBold", false));
        String subtitle = eeuiJson.getString(item, "subtitle", eeuiJson.getString(defaultStyles, "subtitle", ""));
        String subtitleColor = eeuiJson.getString(item, "subtitleColor", eeuiJson.getString(defaultStyles, "subtitleColor", ""));
        float subtitleSize = eeuiJson.getFloat(item, "subtitleSize", eeuiJson.getFloat(defaultStyles, "subtitleSize", 24f));
        navigationBarBackgroundColor = eeuiJson.getString(item, "backgroundColor", (!mPageInfo.getStatusBarColor().equals("") ? mPageInfo.getStatusBarColor() : eeuiJson.getString(defaultStyles, "backgroundColor", "#3EB4FF")));

        titleBar.setBackgroundColor(Color.parseColor(navigationBarBackgroundColor));

        float titleBarHeight = eeuiJson.getFloat(item, "barHeight", eeuiJson.getFloat(defaultStyles, "barHeight", 0f));
        if (titleBarHeight != 0f) {
            ViewGroup.LayoutParams lp;
            lp = titleBar.getLayoutParams();
            lp.height =  eeuiScreenUtils.weexPx2dp(mWXSDKInstance, titleBarHeight);
            titleBar.setLayoutParams(lp);
        }

        showNavigation();

        if (TextUtils.isEmpty(titleColor)) {
            titleColor = navigationBarBackgroundColor.contentEquals("#3EB4FF") ? "#ffffff" : "#232323";
        }
        if (TextUtils.isEmpty(subtitleColor)) {
            subtitleColor = navigationBarBackgroundColor.contentEquals("#3EB4FF") ? "#ffffff" : "#232323";
        }

        if ("".equals(title)) {
            titleBarTitle.setVisibility(View.GONE);
        }else{
            titleBarTitle.setVisibility(View.VISIBLE);
            titleBarTitle.setText(title);
            titleBarTitle.setTextSize(TypedValue.COMPLEX_UNIT_PX, eeuiScreenUtils.weexPx2dp(mWXSDKInstance, titleSize));
            titleBarTitle.getPaint().setFakeBoldText(titleBold);
            titleBarTitle.setTextColor(Color.parseColor(titleColor));
        }

        if ("".equals(subtitle)) {
            titleBarSubtitle.setVisibility(View.GONE);
        }else{
            titleBarSubtitle.setVisibility(View.VISIBLE);
            titleBarSubtitle.setText(subtitle);
            titleBarSubtitle.setTextSize(TypedValue.COMPLEX_UNIT_PX, eeuiScreenUtils.weexPx2dp(mWXSDKInstance, subtitleSize));
            titleBarSubtitle.setTextColor(Color.parseColor(subtitleColor));
        }

        JSONObject finalItem = item;
        titleBarMiddle.setOnClickListener(v -> {
            if (callback != null) {
                callback.onReceiveResult(finalItem);
            }
        });

        if (!mPageInfo.isFirstPage() && titleBarLeftNull) {
            JSONObject styles = eeuiJson.parseObject(defaultStyles.getJSONObject("left"));
            if (styles.get("icon") == null) {
                styles.put("icon","tb-back");
            }
            if (styles.get("iconSize") == null) {
                styles.put("iconSize", 36);
            }
            if (styles.get("width") == null) {
                styles.put("width", 98);
            }
            setNavigationItems(styles, "left", result -> eeuiPage.closeWin(mPageInfo.getPageName()));
        }
    }

    /**
     * 设置页面标题栏左右按钮
     * @param params
     * @param position
     * @param callback
     */
    public void setNavigationItems(Object params, String position, ResultCallback<JSONObject> callback) {
        navigationInit();
        JSONArray buttonArray = new JSONArray();
        if (params instanceof String) {
            JSONObject temp = new JSONObject();
            temp.put("title", params);
            buttonArray.add(temp);
        } else if (params instanceof JSONObject) {
            JSONObject temp = eeuiJson.parseObject(params);
            buttonArray.add(temp);
        } else {
            buttonArray = eeuiJson.parseArray(params);
        }
        if (position.equals("right")) {
            titleBarRight.removeAllViews();
        } else {
            titleBarLeft.removeAllViews();
        }
        JSONObject defaultStyles = eeuiJson.parseObject(eeuiBase.config.getObject("navigationBarStyle").getJSONObject(position));
        LinearLayout.LayoutParams layoutParams = new LinearLayout.LayoutParams(LinearLayout.LayoutParams.WRAP_CONTENT, LinearLayout.LayoutParams.MATCH_PARENT);
        for (int i = 0; i < buttonArray.size(); i++) {
            JSONObject item = eeuiJson.parseObject(buttonArray.get(i));
            String title = eeuiJson.getString(item, "title", eeuiJson.getString(defaultStyles, "title", ""));
            String titleColor = eeuiJson.getString(item, "titleColor", eeuiJson.getString(defaultStyles, "titleColor", ""));
            float titleSize = eeuiJson.getFloat(item, "titleSize", eeuiJson.getFloat(defaultStyles, "titleSize", 28f));
            boolean titleBold = eeuiJson.getBoolean(item, "titleBold", eeuiJson.getBoolean(defaultStyles, "titleBold", false));
            String icon = eeuiJson.getString(item, "icon", eeuiJson.getString(defaultStyles, "icon", ""));
            String iconColor = eeuiJson.getString(item, "iconColor", eeuiJson.getString(defaultStyles, "iconColor", ""));
            float iconSize = eeuiJson.getFloat(item, "iconSize", eeuiJson.getFloat(defaultStyles, "iconSize", 28f));
            int width = eeuiScreenUtils.weexPx2dp(mWXSDKInstance, item.get("width"), eeuiJson.getInt(defaultStyles, "width", 0));
            int spacing = eeuiScreenUtils.weexPx2dp(mWXSDKInstance, item.get("spacing"), eeuiJson.getInt(defaultStyles, "spacing", 10));

            if (TextUtils.isEmpty(titleColor)) {
                titleColor = navigationBarBackgroundColor.contentEquals("#3EB4FF") ? "#ffffff" : "#232323";
            }
            if (TextUtils.isEmpty(iconColor)) {
                iconColor = navigationBarBackgroundColor.contentEquals("#3EB4FF") ? "#ffffff" : "#232323";
            }

            LinearLayout.LayoutParams customParams = new LinearLayout.LayoutParams(width > 0 ? width : LinearLayout.LayoutParams.WRAP_CONTENT, LinearLayout.LayoutParams.MATCH_PARENT);
            LinearLayout customButton = new LinearLayout(this);
            customButton.setLayoutParams(customParams);
            customButton.setGravity(Gravity.CENTER);
            customButton.setOrientation(LinearLayout.HORIZONTAL);
            TextView titleView = new TextView(this);
            if (!"".equals(icon)) {
                if (isFontIcon(icon)) {
                    IconTextView iconView = new IconTextView(this);
                    iconView.setLayoutParams(layoutParams);
                    iconView.setGravity(Gravity.CENTER);
                    iconView.setText(String.format("{%s}", icon));
                    iconView.setTextSize(TypedValue.COMPLEX_UNIT_PX, eeuiScreenUtils.weexPx2dp(mWXSDKInstance, iconSize));
                    iconView.setTextColor(Color.parseColor(iconColor));
                    customButton.addView(iconView);
                }else{
                    icon = eeuiPage.rewriteUrl(this, icon);
                    ImageView imgView = new ImageView(this);
                    imgView.setLayoutParams(new LinearLayout.LayoutParams(eeuiScreenUtils.weexPx2dp(mWXSDKInstance, iconSize), LinearLayout.LayoutParams.MATCH_PARENT));
                    imgView.setScaleType(ImageView.ScaleType.FIT_CENTER);
                    if (icon.startsWith("file://assets/")) {
                        icon = icon.substring(14);
                        try {
                            InputStream is = getAssets().open(icon);
                            Bitmap bitmap= BitmapFactory.decodeStream(is);
                            imgView.setImageBitmap(bitmap);
                        } catch (IOException e) {
                            e.printStackTrace();
                        }
                    } else {
                        Glide.with(imgView.getContext()).load(icon).apply(new RequestOptions().diskCacheStrategy(DiskCacheStrategy.ALL)).listener(new RequestListener<Drawable>() {
                            @Override
                            public boolean onLoadFailed(@Nullable GlideException e, Object model, Target<Drawable> target, boolean isFirstResource) {
                                return false;
                            }
                            @Override
                            public boolean onResourceReady(Drawable resource, Object model, Target<Drawable> target, DataSource dataSource, boolean isFirstResource) {
                                return false;
                            }
                        }).into(imgView);
                    }
                    customButton.addView(imgView);
                }
            }
            if (!"".equals(title)) {
                if (!"".equals(icon)) {
                    titleView.setPadding(spacing, 0, 0, 0);
                }
                titleView.setLayoutParams(layoutParams);
                titleView.setGravity(Gravity.CENTER);
                titleView.setText(title);
                titleView.setTextSize(TypedValue.COMPLEX_UNIT_PX, eeuiScreenUtils.weexPx2dp(mWXSDKInstance, titleSize));
                titleView.getPaint().setFakeBoldText(titleBold);
                titleView.setTextColor(Color.parseColor(titleColor));
                customButton.addView(titleView);
            }
            customButton.setClickable(true);
            customButton.setFocusable(true);
            try {
                TypedValue typedValue = new TypedValue();
                customButton.getContext().getTheme().resolveAttribute(android.R.attr.selectableItemBackground, typedValue, true);
                int[] attribute = new int[]{android.R.attr.selectableItemBackground};
                TypedArray typedArray = customButton.getContext().getTheme().obtainStyledAttributes(typedValue.resourceId, attribute);
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                    customButton.setForeground(typedArray.getDrawable(0));
                }
                typedArray.recycle();
            } catch (Exception ignored) { }
            customButton.setOnClickListener(v -> {
                if (callback != null) {
                    callback.onReceiveResult(item);
                }
            });
            if (position.equals("right")) {
                titleBarRight.addView(customButton);
            } else {
                titleBarLeftNull = false;
                titleBarLeft.addView(customButton);
            }
        }
        titleBarLeft.setLayoutParams(layoutParams);
        titleBarLeft.post(() -> {
            int leftWidth = titleBarLeft.getWidth();
            titleBarRight.setLayoutParams(layoutParams);
            titleBarRight.post(() -> {
                int rightWidth = titleBarRight.getWidth();
                if (leftWidth > rightWidth) {
                    titleBarRight.setLayoutParams(new LinearLayout.LayoutParams(leftWidth, LinearLayout.LayoutParams.MATCH_PARENT));
                } else if (leftWidth < rightWidth) {
                    titleBarLeft.setLayoutParams(new LinearLayout.LayoutParams(rightWidth, LinearLayout.LayoutParams.MATCH_PARENT));
                }
            });
        });

        if (navigationBarBackgroundColor == null) {
            setNavigationTitle(" ", null);
        }else{
            showNavigation();
        }
    }

    /**
     * 显示标题栏
     */
    public void showNavigation() {
        if ("fullscreen".equals(mPageInfo.getStatusBarType()) || "immersion".equals(mPageInfo.getStatusBarType())) {
            return;
        }
        navigationInit();
        titleBar.setVisibility(View.VISIBLE);
    }

    /**
     * 隐藏标题栏
     */
    public void hideNavigation() {
        navigationInit();
        titleBar.setVisibility(View.GONE);
    }

    /****************************************************************************************************/
    /****************************************************************************************************/
    /****************************************************************************************************/

    private TextView deBugButton;
    private WsManager deBugSocketWsManager;
    private int deBugButtonSize = SizeUtils.dp2px(48);
    private String deBugWsOpenUrl = "";
    private String deBugKeepScreen = "";
    private Timer deBugSocketTimer;

    public boolean isDeBugPage() {
        return deBugButton != null;
    }

    /**
     * 创建debug按钮
     */
    @SuppressLint("SetTextI18n")
    private void deBugButtonCreate() {
        if (!BuildConfig.DEBUG) {
            return;
        }
        if (deBugButton != null) {
            return;
        }
        if (mPageInfo == null) {
            return;
        }
        if (!("app".equals(mPageInfo.getPageType()) || "web".equals(mPageInfo.getPageType()) || "auto".equals(mPageInfo.getPageType()))) {
            return;
        }
        deBugButton = new TextView(this);
        deBugButton.setText("DEV");
        deBugButton.setTextColor(Color.WHITE);
        deBugButton.setTextSize(14);
        deBugButton.setGravity(Gravity.CENTER);
        deBugButton.setBackgroundResource(eeuiDebug.getDebugButton(eeuiCommon.getVariateInt("__system:deBugSocket:Status")));
        if (PageActivity.hideDev) {
            deBugButton.setVisibility(View.GONE);
        }
        deBugButton.setOnClickListener(deBugClickListener);
        FloatDragView.Builder mFloatDragView = new FloatDragView.Builder();
        mFloatDragView.setActivity(this)
                .setDefaultLeft(eeuiParse.parseInt(eeuiCommon.getVariate("__system:pageActivity:FloatDrag:Left"), ScreenUtils.getScreenWidth() - deBugButtonSize))
                .setDefaultTop(eeuiParse.parseInt(eeuiCommon.getVariate("__system:pageActivity:FloatDrag:Top"), (ScreenUtils.getScreenHeight() - deBugButtonSize) / 2))
                .setNeedNearEdge(true)
                .setSize(deBugButtonSize)
                .setView(deBugButton)
                .setUpdateListener((left, top) -> {
                    eeuiCommon.setVariate("__system:pageActivity:FloatDrag:Left", left);
                    eeuiCommon.setVariate("__system:pageActivity:FloatDrag:Top", top);
                })
                .build();
    }

    /**
     * 刷新debug按钮
     * @param status
     */
    public void deBugButtonRefresh(int status) {
        if (deBugButton == null) {
            return;
        }
        if (status == 1) {
            deBugButton.setBackgroundResource(eeuiDebug.getDebugButton(1));
            eeuiCommon.setVariate("__system:deBugSocket:Status", 1);
        } else if (status == 2) {
            deBugButton.setBackgroundResource(eeuiDebug.getDebugButton(2));
            eeuiCommon.setVariate("__system:deBugSocket:Status", 2);
        } else if (status == 3) {
            deBugButton.setVisibility(View.GONE);
            return;
        } else {
            deBugButton.setBackgroundResource(eeuiDebug.getDebugButton(eeuiCommon.getVariateInt("__system:deBugSocket:Status")));
        }
        FrameLayout.LayoutParams layoutParams = new FrameLayout.LayoutParams(deBugButtonSize, deBugButtonSize);
        int left = eeuiParse.parseInt(eeuiCommon.getVariate("__system:pageActivity:FloatDrag:Left"), ScreenUtils.getScreenWidth() - deBugButtonSize);
        int top = eeuiParse.parseInt(eeuiCommon.getVariate("__system:pageActivity:FloatDrag:Top"), (ScreenUtils.getScreenHeight() - deBugButtonSize) / 2);
        layoutParams.setMargins(left, top, 0, 0);
        deBugButton.setLayoutParams(layoutParams);
    }

    /**
     * 初始化deBugSocket
     */
    private void deBugSocketInit() {
        if (deBugButton == null) {
            return;
        }
        if (eeuiCommon.getVariateInt("__system:deBugSocket:Init") == 0) {
            eeuiCommon.setVariate("__system:deBugSocket:Init", 1);
            //
            JSONObject jsonData = eeuiJson.parseObject(eeuiCommon.getAssetsFile(this, "file://assets/eeui/config.json"));
            eeuiCommon.setVariate("__system:deBugSocket:Host", eeuiJson.getString(jsonData, "socketHost"));
            eeuiCommon.setVariate("__system:deBugSocket:Port", eeuiJson.getString(jsonData, "socketPort"));
            if (PermissionUtils.isShowApply || PermissionUtils.isShowRationale || PermissionUtils.isShowOpenAppSetting) {
                if (deBugSocketTimer != null) {
                    deBugSocketTimer.cancel();
                    deBugSocketTimer = null;
                }
                deBugSocketTimer = new Timer();
                deBugSocketTimer.schedule(new TimerTask() {
                    @Override
                    public void run() {
                        if (!PermissionUtils.isShowApply && !PermissionUtils.isShowRationale && !PermissionUtils.isShowOpenAppSetting) {
                            deBugSocketTimer.cancel();
                            deBugSocketTimer = null;
                            PageActivity.this.runOnUiThread(() -> {
                                try {
                                    deBugSocketConnect("initialize");
                                } catch (Exception e) {
                                    Log.d(TAG, "run: deBugSocketConnect error:" + e.getMessage());
                                }
                            });
                        }
                    }
                }, 3000, 2000);
            }else{
                deBugSocketConnect("initialize");
            }
        }
    }

    /**
     * 连接deBugSocket
     */
    private void deBugSocketConnect(String mode) {
        if (deBugButton == null) {
            return;
        }
        if ("initialize".contentEquals(mode)) {
            deBugWsOpenUrl = "";
        }
        if (deBugSocketWsManager != null) {
            deBugSocketWsManager.stopConnect();
            deBugSocketWsManager = null;
        }
        String host = eeuiCommon.getVariateStr("__system:deBugSocket:Host");
        String port = eeuiCommon.getVariateStr("__system:deBugSocket:Port");
        if (host.length() == 0 || port.length() == 0) {
            return;
        }
        deBugSocketWsManager = new WsManager.Builder(this)
                .client(new OkHttpClient().newBuilder().pingInterval(15, TimeUnit.SECONDS).retryOnConnectionFailure(true).build())
                .wsUrl("ws://" + host + ":" + port + "?mode=" + mode + "&version=2")
                .needReconnect(false)
                .build();
        deBugSocketWsManager.setWsStatusListener(deBugWsStatusListener);
        try {
            deBugSocketWsManager.startConnect();
        } catch (IllegalArgumentException ignored) { }
    }

    /**
     * debug按钮点击事件
     */
    private View.OnClickListener deBugClickListener = v -> {
        eeuiCommon.setVariate("__system:deBugSocket:Click", 1);
        List<ActionItem> mActionItem = new ArrayList<>();
        mActionItem.add(new ActionItem(1, eeuiCommon.getVariateInt("__system:deBugSocket:Status") == 1 ? "WiFi真机同步 [已连接]" : "WiFi真机同步"));
        mActionItem.add(new ActionItem(2, deBugKeepScreen.contentEquals("ON") ? "屏幕常亮 [已开启]" : "屏幕常亮"));
        mActionItem.add(new ActionItem(3, "页面信息"));
        mActionItem.add(new ActionItem(4, "扫一扫"));
        mActionItem.add(new ActionItem(5, "刷新"));
        mActionItem.add(new ActionItem(6, eeuiDebug.isNewDebug() ? "Console [新]" : "Console"));
        mActionItem.add(new ActionItem(7, "隐藏DEV"));
        mActionItem.add(new ActionItem(8, "重启APP"));
        mActionItem.add(new ActionItem(9, "清除缓存"));
        if (eeuiBase.config.verifyIsUpdate()) {
            mActionItem.add(new ActionItem(10, "清除热更新数据"));
        }
        ActionSheet.createBuilder(this, getSupportFragmentManager())
                .setSubTitle("开发工具菜单")
                .setCancelActionTitle("取消")
                .setActionItems(mActionItem)
                .setCancelableOnTouchOutside(true)
                .setListener(new ActionSheet.ActionSheetListener() {
                    @Override
                    public void onDismiss(ActionSheet actionSheet, boolean isCancel) {

                    }

                    @Override
                    public void onActionButtonClick(ActionSheet actionSheet, int index) {
                        switch (index) {
                            case 0: {
                                String host = eeuiCommon.getVariateStr("__system:deBugSocket:Host");
                                String port = eeuiCommon.getVariateStr("__system:deBugSocket:Port");
                                String inputObject = "{title:\"WiFi真机同步配置\",message:\"配置成功后，可实现真机同步实时预览\",buttons:[\"取消\",\"连接\"],inputs:[{type:'text',placeholder:'请输入IP地址',value:'" + host + "',autoFocus:true},{type:'number',placeholder:'请输入端口号',value:'" + port + "'}]}";
                                eeuiAlertDialog.input(PageActivity.this, eeuiJson.parseObject(inputObject), new JSCallback() {
                                    @Override
                                    public void invoke(Object data) {
                                        Map<String, Object> retData = eeuiMap.objectToMap(data);
                                        if (eeuiParse.parseStr(retData.get("status")).equals("click") && eeuiParse.parseStr(retData.get("title")).equals("连接")) {
                                            JSONArray dData = eeuiJson.parseArray(retData.get("data"));
                                            eeuiCommon.setVariate("__system:deBugSocket:Host", dData.getString(0));
                                            eeuiCommon.setVariate("__system:deBugSocket:Port", dData.getString(1));
                                            List<Activity> activityList = eeui.getActivityList();
                                            Activity activity = activityList.get(0);
                                            if (activity instanceof PageActivity) {
                                                ((PageActivity) activity).deBugSocketConnect("initialize");
                                            }
                                        }
                                    }

                                    @Override
                                    public void invokeAndKeepAlive(Object data) {
                                        //
                                    }
                                });
                                break;
                            }
                            case 1: {
                                if (deBugKeepScreen.contentEquals("ON")) {
                                    deBugKeepScreen = "OFF";
                                    getWindow().clearFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
                                } else {
                                    deBugKeepScreen = "ON";
                                    getWindow().addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
                                }
                                break;
                            }
                            case 2: {
                                Map<String, Object> info = getPageInfo().toMap();
                                info.put("loadTime", eeuiCommon.formatDate(eeuiParse.parseStr(info.get("loadTime")), null));
                                showPageInfo(JSON.toJSONString(info, true));
                                break;
                            }
                            case 3: {
                                if (eeuiObj == null) {
                                    eeuiObj = new eeui();
                                }
                                eeuiObj.openScaner(PageActivity.this, "{title:'二维码/条码'}", new JSCallback() {
                                    @Override
                                    public void invoke(Object data) {
                                        //
                                    }

                                    @Override
                                    public void invokeAndKeepAlive(Object data) {
                                        Map<String, Object> retData = eeuiMap.objectToMap(data);
                                        if (eeuiParse.parseStr(retData.get("status")).equals("success")) {
                                            String text = eeuiParse.parseStr(retData.get("text"));
                                            if (text.startsWith("http")) {
                                                new Handler().postDelayed(() -> {
                                                    String url = text, host = "", port = "";
                                                    if (text.contains("?socket=")) {
                                                        url = eeuiCommon.getMiddle(text, null, "?socket=");
                                                        host = eeuiCommon.getMiddle(text, "?socket=", ":");
                                                        port = eeuiCommon.getMiddle(text, "?socket=" + host + ":", "&");
                                                    }
                                                    //
                                                    PageBean mPageBean = new PageBean();
                                                    mPageBean.setUrl(url);
                                                    mPageBean.setPageType("auto");
                                                    eeuiPage.openWin(PageActivity.this, mPageBean);
                                                    //
                                                    if (host.length() > 0 && port.length() > 0) {
                                                        eeuiCommon.setVariate("__system:deBugSocket:Host", host);
                                                        eeuiCommon.setVariate("__system:deBugSocket:Port", port);
                                                        List<Activity> activityList = eeui.getActivityList();
                                                        for (int i = activityList.size() - 1; i >= 0; --i) {
                                                            Activity activity = activityList.get(i);
                                                            if (activity instanceof PageActivity && ((PageActivity) activity).isDeBugPage()) {
                                                                ((PageActivity) activity).deBugSocketConnect("back");
                                                                break;
                                                            }
                                                        }
                                                    }
                                                }, 300);
                                            } else {
                                                Toast.makeText(PageActivity.this, "识别内容：" + text, LENGTH_SHORT).show();
                                            }
                                        }
                                    }
                                });
                                break;
                            }
                            case 4: {
                                eeuiPage.mAppboardContent = new HashMap<>();
                                reload();
                                break;
                            }
                            case 5: {
                                eeuiDebug.setNewDebug(false);
                                showConsole();
                                break;
                            }
                            case 6: {
                                JSONObject newJson = new JSONObject();
                                newJson.put("title", "隐藏DEV");
                                newJson.put("message", "确定要隐藏DEV漂浮按钮吗？\n隐藏按钮将在下次启动APP时显示。");
                                eeuiAlertDialog.confirm(eeui.getActivityList().getLast(), newJson, new JSCallback() {
                                    @Override
                                    public void invoke(Object data) {
                                        Map<String, Object> retData = eeuiMap.objectToMap(data);
                                        if (eeuiParse.parseStr(retData.get("status")).equals("click") && eeuiParse.parseStr(retData.get("title")).equals("确定")) {
                                            PageActivity.hideDev = true;
                                            List<Activity> activityList = eeui.getActivityList();
                                            for (int i = activityList.size() - 1; i >= 0; --i) {
                                                Activity activity = activityList.get(i);
                                                if (activity instanceof PageActivity) {
                                                    ((PageActivity) activity).deBugButtonRefresh(3);
                                                }
                                            }
                                        }
                                    }

                                    @Override
                                    public void invokeAndKeepAlive(Object data) {

                                    }
                                });
                                break;
                            }
                            case 7: {
                                JSONObject newJson = new JSONObject();
                                newJson.put("title", "热重启APP");
                                newJson.put("message", "确认要关闭所有页面热重启APP吗？");
                                eeuiAlertDialog.confirm(eeui.getActivityList().getLast(), newJson, new JSCallback() {
                                    @Override
                                    public void invoke(Object data) {
                                        Map<String, Object> retData = eeuiMap.objectToMap(data);
                                        if (eeuiParse.parseStr(retData.get("status")).equals("click") && eeuiParse.parseStr(retData.get("title")).equals("确定")) {
                                            eeuiCommon.setVariate("__system:deBugSocket:Init", 0);
                                            eeuiCommon.setVariate("__system:deBugSocket:Status", 0);
                                            eeuiBase.cloud.appData(false);
                                            eeuiBase.cloud.reboot();
                                        }
                                    }

                                    @Override
                                    public void invokeAndKeepAlive(Object data) {

                                    }
                                });
                                break;
                            }
                            case 8: {
                                JSONObject newJson = new JSONObject();
                                newJson.put("title", "清除缓存");
                                newJson.put("message", "确认清除缓存吗？\n（清除包括：clearCustomConfig、clearCacheDir、clearCachePage、clearCacheAjax）");
                                eeuiAlertDialog.confirm(eeui.getActivityList().getLast(), newJson, new JSCallback() {
                                    @Override
                                    public void invoke(Object data) {
                                        Map<String, Object> retData = eeuiMap.objectToMap(data);
                                        if (eeuiParse.parseStr(retData.get("status")).equals("click") && eeuiParse.parseStr(retData.get("title")).equals("确定")) {
                                            eeuiBase.config.clearCache();
                                        }
                                    }

                                    @Override
                                    public void invokeAndKeepAlive(Object data) {

                                    }
                                });
                                break;
                            }
                            case 9: {
                                eeuiCommon.setVariate("__system:deBugSocket:Init", 0);
                                eeuiBase.cloud.clearUpdate();
                                break;
                            }
                        }
                    }
                }).show();
    };

    /**
     * 添加tabbar监听
     * @param callback
     */
    public static void setTabViewDebug(ResultCallback<String> callback) {
        tabViewDebug.add(callback);
    }

    /**
     * 移除tabbar监听
     * @param callback
     */
    public static void removeTabViewDebug(ResultCallback<String> callback) {
        tabViewDebug.remove(callback);
    }

    /**
     * deBugSocket事件
     */
    private WsStatusListener deBugWsStatusListener = new WsStatusListener() {

        @Override
        public void onOpen(Response response) {
            super.onOpen(response);
            Log.d("[socket]", "onOpen");
            deBugWsOpenUrl = response.request().url().host() + ":" + response.request().url().port();
            //
            if (deBugKeepScreen.contentEquals("")) {
                deBugKeepScreen = "ON";
                getWindow().addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
            }
            List<Activity> activityList = eeui.getActivityList();
            for (int i = activityList.size() - 1; i >= 0; --i) {
                Activity activity = activityList.get(i);
                if (activity instanceof PageActivity) {
                    ((PageActivity) activity).deBugButtonRefresh(1);
                }
            }
        }

        @Override
        public void onMessage(String text) {
            super.onMessage(text);
            handleMessage(text);
        }

        @Override
        public void onClosed(int code, String reason) {
            super.onClosed(code, reason);
            Log.d("[socket]", "onClosed");
            //
            List<Activity> activityList = eeui.getActivityList();
            for (int i = activityList.size() - 1; i >= 0; --i) {
                Activity activity = activityList.get(i);
                if (activity instanceof PageActivity) {
                    ((PageActivity) activity).deBugButtonRefresh(2);
                }
            }
        }

        @Override
        public void onFailure(Throwable t, Response response) {
            super.onFailure(t, response);
            //
            String host = eeuiCommon.getVariateStr("__system:deBugSocket:Host");
            String port = eeuiCommon.getVariateStr("__system:deBugSocket:Port");
            if (deBugWsOpenUrl.contentEquals(host + ":" + port)) {
                mHandler.postDelayed(()-> {
                    Log.d("[socket]", "reconnect");
                    deBugSocketConnect("reconnect");
                }, 3000);
            } else {
                String statusRand = eeuiCommon.randomString(6);
                eeuiCommon.setVariate("__system:deBugSocket:statusRand", statusRand);
                mHandler.postDelayed(()-> {
                    if (eeuiCommon.getVariateInt("__system:deBugSocket:Status") != 1 && statusRand.contentEquals(eeuiCommon.getVariateStr("__system:deBugSocket:statusRand"))) {
                        Log.d("[socket]", "onFailure");
                        Toast.makeText(PageActivity.this, "WiFi同步连接失败：" + t.getMessage(), LENGTH_SHORT).show();
                    }
                }, 1000);
            }
            //
            List<Activity> activityList = eeui.getActivityList();
            for (int i = activityList.size() - 1; i >= 0; --i) {
                Activity activity = activityList.get(i);
                if (activity instanceof PageActivity) {
                    ((PageActivity) activity).deBugButtonRefresh(2);
                }
            }
        }

        private void handleMessage(String text) {
            //
            JSONObject data = eeuiJson.parseObject(text);
            String type = eeuiJson.getString(data, "type");
            String value = eeuiJson.getString(data, "value");
            int version = eeuiJson.getInt(data, "version");
            if (version < 2) {
                Toast.makeText(PageActivity.this, "eeui-cli版本太低，请先升级eeui-cli版本，详情：https://www.npmjs.com/package/eeui-cli", Toast.LENGTH_LONG).show();
                Log.d(TAG, "eeui-cli版本太低，请先升级eeui-cli版本，详情：https://www.npmjs.com/package/eeui-cli");
                return;
            }
            Log.d("[socket]", "onMessage: " + type + ":" + value);
            if (type.equals("HOMEPAGE")) {
                eeuiPage.mAppboardWifi = new HashMap<>();
            }
            JSONArray appboards = eeuiJson.parseArray(data.getJSONArray("appboards"));
            if (appboards.size() > 0) {
                for (int i = 0; i < appboards.size(); i++) {
                    JSONObject appboardItem = eeuiJson.parseObject(appboards.get(i));
                    eeuiPage.mAppboardWifi.put(eeuiJson.getString(appboardItem, "path"), eeuiJson.getString(appboardItem, "content"));
                }
            }
            //
            switch (type) {
                case "HOMEPAGE": {
                    List<Activity> activityList = eeui.getActivityList();
                    if (activityList.size() >= 2 && activityList.get(0).getClass().getName().endsWith(".WelcomeActivity")) {
                        activityList.remove(0);
                    }
                    if (eeuiCommon.getVariateInt("__system:deBugSocket:Click") != 1) {
                        boolean meetSkip = true;
                        String valueHP = getHostPort(value);
                        for (int i = activityList.size() - 1; i >= 0; --i) {
                            Activity activity = activityList.get(i);
                            if (activity instanceof PageActivity) {
                                PageBean mPageBean = ((PageActivity) activity).getPageInfo();
                                String hostPort = getHostPort(mPageBean.getUrl());
                                if (!hostPort.equals(valueHP)) {
                                    meetSkip = false;
                                }
                            } else {
                                meetSkip = false;
                            }
                        }
                        if (meetSkip) {
                            return;
                        }
                    }
                    for (int i = activityList.size() - 1; i >= 0; --i) {
                        Activity activity = activityList.get(i);
                        if (i == 0) {
                            if (activity instanceof PageActivity) {
                                PageActivity mActivity = ((PageActivity) activity);
                                String homePage = eeuiCommon.getCachesString(PageActivity.this, "__system:homePage", "");
                                if (!homePage.equals(value)) {
                                    eeuiCommon.setCachesString(PageActivity.this, "__system:homePage", value, 2);
                                    mHandler.postDelayed(() -> {
                                        String curUrl = mActivity.mPageInfo.getUrl();
                                        mActivity.mPageInfo.setUrl(value);
                                        if (!value.contentEquals(curUrl) || eeuiCommon.getVariateInt("__system:deBugSocket:Click") == 1) {
                                            mActivity.reload();
                                        }
                                        BGAKeyboardUtil.closeKeyboard(PageActivity.this);
                                    }, 300);
                                }
                            }
                        } else {
                            activity.finish();
                        }
                    }
                    break;
                }
                case "HOMEPAGEBACK": {
                    List<Activity> activityList = eeui.getActivityList();
                    Activity activity = activityList.get(0);
                    if (activity instanceof PageActivity) {
                        PageActivity mActivity = ((PageActivity) activity);
                        eeuiCommon.setCachesString(PageActivity.this, "__system:homePage", value, 2);
                        mActivity.mPageInfo.setUrl(value);
                        mActivity.reload();
                        BGAKeyboardUtil.closeKeyboard(PageActivity.this);
                    }
                    break;
                }
                case "RECONNECT": {
                    String urlHost = getHostPort(value);
                    String nowHost = "";
                    Activity activity = eeui.getActivityList().getLast();
                    if (activity instanceof PageActivity) {
                        PageActivity mActivity = ((PageActivity) activity);
                        nowHost = getHostPort(mActivity.getPageInfo().getUrl());
                    }
                    if (!urlHost.equals(nowHost)) {
                        data.put("type", "HOMEPAGE");
                        handleMessage(data.toJSONString());
                    }
                    break;
                }
                case "RELOADPAGE": {
                    List<Activity> activityList = eeui.getActivityList();
                    boolean already = false;
                    int size = activityList.size() - 1;
                    for (int i = size; i >= 0; --i) {
                        Activity activity = activityList.get(i);
                        if (activity instanceof PageActivity) {
                            PageActivity mActivity = ((PageActivity) activity);
                            String urlStr = eeuiParse.parseStr(eeuiPage.realUrl(mActivity.mPageInfo.getUrl()));
                            if (urlStr.startsWith(value)) {
                                if (i == size) {
                                    mActivity.reload();
                                    BGAKeyboardUtil.closeKeyboard(PageActivity.this);
                                } else {
                                    mActivity.getPageInfo().setResumeUrl(value);
                                }
                                already = true;
                            }
                        }
                    }
                    if (!already) {
                        for (int i = 0; i < tabViewDebug.size(); i++) {
                            ResultCallback<String> call = tabViewDebug.get(i);
                            if (call != null) {
                                call.onReceiveResult(value);
                            }
                        }
                    }
                    break;
                }
                case "REFRESH": {
                    Activity activity = eeui.getActivityList().getLast();
                    if (activity instanceof PageActivity) {
                        PageActivity mActivity = ((PageActivity) activity);
                        mActivity.reload();
                    }
                    break;
                }
            }
        }

        private String getHostPort(String url) {
            try {
                URL tmp = new URL(url);
                String host = tmp.getHost();
                host+= (tmp.getPort() > -1 && tmp.getPort() != 80) ? (":" + tmp.getPort()) : "";
                return host;
            } catch (MalformedURLException e) {
                e.printStackTrace();
            }
            return "";
        }
    };

    /**
     * 显示页面详情
     */
    public void showPageInfo(String context) {
        if (mPageInfoView != null) {
            ((TextView) mPageInfoView.findViewById(R.id.v_info)).setText(context);
            return;
        }
        mPageInfoView = PageActivity.this.getLayoutInflater().inflate(R.layout.activity_page_info, null);
        ((TextView) mPageInfoView.findViewById(R.id.v_info)).setText(context);
        if ("immersion".equals(mPageInfo.getStatusBarType())) {
            mPageInfoView.setPadding(0, eeuiCommon.getStatusBarHeight(PageActivity.this), 0, 0);
        } else {
            mPageInfoView.setPadding(0, 0, 0, 0);
        }
        mPageInfoView.findViewById(R.id.v_close).setOnClickListener(v -> {
            mBody.removeView(mPageInfoView);
            mPageInfoView = null;
        });
        mBody.addView(mPageInfoView);
    }

    /**
     * 显示日志查看
     */
    public void showConsole() {
        if (mPageLogView != null) {
            return;
        }
        mPageLogView = PageActivity.this.getLayoutInflater().inflate(R.layout.activity_page_console, null);
        if ("immersion".equals(mPageInfo.getStatusBarType())) {
            mPageLogView.setPadding(0, eeuiCommon.getStatusBarHeight(PageActivity.this), 0, 0);
        } else {
            mPageLogView.setPadding(0, 0, 0, 0);
        }
        mPageLogView.findViewById(R.id.v_space).setOnClickListener(v -> {
            eeuiDebug.setNewDebug(false);
            closeConsole();
        });
        FrameLayout mLayout = mPageLogView.findViewById(R.id.v_view);
        WXSDKInstance mInstance = new WXSDKInstance(this);
        mInstance.registerRenderListener(new IWXRenderListener() {
            @Override
            public void onViewCreated(WXSDKInstance instance, View view) {
                mLayout.removeAllViews();
                mLayout.addView(view);
            }
            @Override
            public void onRenderSuccess(WXSDKInstance instance, int width, int height) {

            }
            @Override
            public void onRefreshSuccess(WXSDKInstance instance, int width, int height) {

            }
            @Override
            public void onException(WXSDKInstance instance, String errCode, String msg) {

            }
        });
        eeuiPage.cachePage(this, "file://assets/main-console.js", 0, null, new eeuiPage.OnCachePageCallback() {
            @Override
            public void success(Map<String, Object> resParams, String newUrl) {
                mInstance.renderByUrl("Console::" + mPageInfo.getPageName(), newUrl, resParams, null, WXRenderStrategy.APPEND_ASYNC);
            }

            @Override
            public void error(Map<String, Object> resParams, String newUrl) {
                Toast.makeText(PageActivity.this, "日志文件不存在！", Toast.LENGTH_SHORT).show();
            }
        });
        mBody.addView(mPageLogView);
    }

    /**
     * 关闭日志查看
     */
    public void closeConsole() {
        if (mPageLogView == null) {
            return;
        }
        mBody.removeView(mPageLogView);
        mPageLogView = null;
    }

    /**
     * 显示升级提示
     */
    public void showVersionUpdate(String templateId) {
        if (mPageVersionUpdateView != null) {
            return;
        }
        mPageVersionUpdateView = PageActivity.this.getLayoutInflater().inflate(R.layout.activity_page_version_update, null);
        if ("immersion".equals(mPageInfo.getStatusBarType())) {
            mPageVersionUpdateView.setPadding(0, eeuiCommon.getStatusBarHeight(PageActivity.this), 0, 0);
        } else {
            mPageVersionUpdateView.setPadding(0, 0, 0, 0);
        }
        FrameLayout mLayout = mPageVersionUpdateView.findViewById(R.id.v_view);
        WXSDKInstance mInstance = new WXSDKInstance(this);
        mInstance.registerRenderListener(new IWXRenderListener() {
            @Override
            public void onViewCreated(WXSDKInstance instance, View view) {
                mLayout.removeAllViews();
                mLayout.addView(view);
            }
            @Override
            public void onRenderSuccess(WXSDKInstance instance, int width, int height) {

            }
            @Override
            public void onRefreshSuccess(WXSDKInstance instance, int width, int height) {

            }
            @Override
            public void onException(WXSDKInstance instance, String errCode, String msg) {

            }
        });
        eeuiPage.cachePage(this, "file://assets/version_update/" + templateId + ".js", 0, null, new eeuiPage.OnCachePageCallback() {
            @Override
            public void success(Map<String, Object> resParams, String newUrl) {
                mInstance.renderByUrl("VersionUpdate::" + mPageInfo.getPageName(), newUrl, resParams, null, WXRenderStrategy.APPEND_ASYNC);
            }

            @Override
            public void error(Map<String, Object> resParams, String newUrl) {
                //
            }
        });
        mBody.addView(mPageVersionUpdateView);
    }

    /**
     * 关闭升级提示
     */
    public void closeVersionUpdate() {
        if (mPageVersionUpdateView == null) {
            return;
        }
        mBody.removeView(mPageVersionUpdateView);
        mPageVersionUpdateView = null;
    }
}
