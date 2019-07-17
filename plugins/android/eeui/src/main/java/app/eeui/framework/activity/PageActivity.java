package app.eeui.framework.activity;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.content.ContentResolver;
import android.content.Context;
import android.content.Intent;
import android.content.res.TypedArray;
import android.graphics.Bitmap;
import android.graphics.Color;
import android.graphics.Point;
import android.graphics.drawable.Drawable;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.os.Handler;
import android.provider.MediaStore;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;
import android.support.v4.widget.SwipeRefreshLayout;
import android.support.v7.app.AppCompatActivity;
import android.util.AndroidRuntimeException;
import android.util.Log;
import android.util.TypedValue;
import android.view.Gravity;
import android.view.SurfaceHolder;
import android.view.SurfaceView;
import android.view.View;
import android.view.ViewGroup;
import android.view.Window;
import android.view.WindowManager;
import android.webkit.WebView;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.SeekBar;
import android.widget.TextView;
import android.widget.Toast;

import com.alibaba.fastjson.JSON;
import com.alibaba.fastjson.JSONArray;
import com.alibaba.fastjson.JSONObject;
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
import java.util.concurrent.atomic.AtomicInteger;

import app.eeui.framework.BuildConfig;
import app.eeui.framework.R;
import app.eeui.framework.extend.bean.PageBean;
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
import app.eeui.framework.extend.integration.zxing.Result;
import app.eeui.framework.extend.module.eeuiAlertDialog;
import app.eeui.framework.extend.module.eeuiBase;
import app.eeui.framework.extend.module.eeuiCommon;
import app.eeui.framework.extend.module.eeuiConstants;
import app.eeui.framework.extend.module.eeuiIhttp;
import app.eeui.framework.extend.module.eeuiJson;
import app.eeui.framework.extend.module.eeuiMap;
import app.eeui.framework.extend.module.eeuiPage;
import app.eeui.framework.extend.module.eeuiParse;
import app.eeui.framework.extend.module.eeuiScreenUtils;
import app.eeui.framework.extend.module.rxtools.module.scaner.CameraManager;
import app.eeui.framework.extend.module.rxtools.module.scaner.CaptureActivityHandler;
import app.eeui.framework.extend.module.rxtools.module.scaner.decoding.InactivityTimer;
import app.eeui.framework.extend.module.rxtools.tool.RxAnimationTool;
import app.eeui.framework.extend.module.rxtools.tool.RxBeepTool;
import app.eeui.framework.extend.module.rxtools.tool.RxPhotoTool;
import app.eeui.framework.extend.module.rxtools.tool.RxQrBarTool;
import app.eeui.framework.extend.module.utilcode.constant.PermissionConstants;
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

    private Handler mHandler = new Handler();

    public String identify;
    private PageBean mPageInfo;
    private String lifecycleLastStatus;

    private Map<String, OnBackPressed> mOnBackPresseds = new HashMap<>();
    public interface OnBackPressed { boolean onBackPressed(); }

    private OnRefreshListener mOnRefreshListener;
    public interface OnRefreshListener { void refresh(String pageName); }

    private Map<String, JSCallback> mOnPageStatusListeners = new HashMap<>();
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

    //申请权限部分
    private PermissionUtils mPermissionInstance;

    //滑动验证码部分
    private SwipeCaptchaView v_swipeCaptchaView;
    private SeekBar v_swipeDragBar;
    private int v_swipeNum;

    //二维码与条形码部分
    private RelativeLayout scan_containter, scan_main;
    private InactivityTimer scan_inactivityTimer;
    private CaptureActivityHandler scan_handler;
    private boolean scan_hasSurface;
    private int scan_cropWidth = 0;
    private int scan_cropHeight = 0;
    private boolean scan_flashing = true;
    private boolean scan_vibrate = true;

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
     * 扫描二维码与条形码专用
     * @param context
     * @param obj
     * @param callback
     */
    public static void startScanerCode(Context context, String obj, JSCallback callback) {
        JSONObject json = eeuiJson.parseObject(obj);
        if (json.size() == 0 && obj != null && obj.equals("null")) {
            json.put("desc", String.valueOf(obj));
        }
        json.put("successClose", eeuiJson.getBoolean(json, "successClose", true));
        //
        PermissionUtils.permission(PermissionConstants.CAMERA)
                .rationale(shouldRequest -> PermissionUtils.showRationaleDialog(context, shouldRequest, "相机"))
                .callback(new PermissionUtils.FullCallback() {
                    @Override
                    public void onGranted(List<String> permissionsGranted) {
                        PageBean mBean = new PageBean();
                        mBean.setUrl(eeuiJson.getString(json, "desc", "将二维码图片对准扫描框即可自动扫描"));
                        mBean.setPageType("scanerCode");
                        mBean.setTranslucent(true);
                        mBean.setCallback(callback);
                        mBean.setOtherObject(json);
                        eeuiPage.openWin(context, mBean);
                    }

                    @Override
                    public void onDenied(List<String> permissionsDeniedForever, List<String> permissionsDenied) {
                        if (!permissionsDeniedForever.isEmpty()) {
                            PermissionUtils.showOpenAppSettingDialog(context, "相机");
                        }
                    }
                }).request();
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
                break;

            case "scanerCode":
                initSwipeBackFinish();
                break;

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
                setImmersionStatusBar();
                break;

            case "swipeCaptcha":
                setContentView(R.layout.activity_page_swipe_captcha);
                initSwipeCaptchaPageView();
                break;

            case "scanerCode":
                setContentView(R.layout.activity_page_scaner_code);
                setImmersionStatusBar();
                initScanerCodePageView();
                break;

            case "transparentPage":
                setContentView(R.layout.activity_page_transparent);
                setImmersionStatusBar();
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
        if (mPageInfo.getPageTitle() != null && !mPageInfo.getPageTitle().isEmpty()) {
            setNavigationTitle(mPageInfo.getPageTitle(), null);
        }
        invokeAndKeepAlive("create", null);
    }

    @Override
    public void finish(){
        super.finish();
        if (!mPageInfo.isAnimatedClose()) {
            this.overridePendingTransition(0, 0);
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
        if (scan_containter != null) {
            SurfaceView surfaceView = findViewById(R.id.scan_preview);
            SurfaceHolder surfaceHolder = surfaceView.getHolder();
            if (scan_hasSurface) {
                //Camera初始化
                initScanerCodeCamera(surfaceHolder);
            } else {
                surfaceHolder.addCallback(new SurfaceHolder.Callback() {
                    @Override
                    public void surfaceChanged(SurfaceHolder holder, int format, int width, int height) {

                    }

                    @Override
                    public void surfaceCreated(SurfaceHolder holder) {
                        if (!scan_hasSurface) {
                            scan_hasSurface = true;
                            initScanerCodeCamera(holder);
                        }
                    }

                    @Override
                    public void surfaceDestroyed(SurfaceHolder holder) {
                        scan_hasSurface = false;
                    }
                });
                surfaceHolder.setType(SurfaceHolder.SURFACE_TYPE_PUSH_BUFFERS);
            }
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
        if (scan_containter != null) {
            if (scan_handler != null) {
                scan_handler.quitSynchronously();
                scan_handler = null;
            }
            CameraManager.get().closeDriver();
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
        if (scan_containter != null && resultCode == Activity.RESULT_OK) {
            ContentResolver resolver = getContentResolver();
            Uri originalUri = data.getData();
            try {
                Bitmap photo = MediaStore.Images.Media.getBitmap(resolver, originalUri);
                Result result = RxQrBarTool.decodeFromPhoto(photo);
                if (result != null) {
                    RxBeepTool.playBeep(this, scan_vibrate);
                    Map<String, Object> retData = new HashMap<>();
                    retData.put("source", "photo");
                    retData.put("result", result);
                    retData.put("format", result.getBarcodeFormat());
                    retData.put("text", result.getText());
                    invokeAndKeepAlive("success", retData);
                } else {
                    Map<String, Object> retData = new HashMap<>();
                    retData.put("source", "photo");
                    invokeAndKeepAlive("error", retData);
                }
            } catch (IOException e) {
                e.printStackTrace();
            }
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
        if (scan_containter != null) {
            scan_inactivityTimer.shutdown();
        }
        if (mWXSDKInstance != null) {
            mWXSDKInstance.onActivityDestroy();
        }
        if (mWebView != null) {
            mWebView.onDestroy();
        }
        if (mPageInfo != null) {
            eeuiIhttp.cancel(mPageInfo.getPageName());
            eeuiPage.removePageBean(mPageInfo.getPageName());
            if (mPageInfo.isSwipeBack()) {
                KeyboardUtils.unregisterSoftInputChangedListener(this);
            }
        }
        if (BuildConfig.DEBUG) {
            if (eeui.getActivityList().size() == 1) {
                eeuiCommon.setVariate("__deBugSocket:Init", 0);
                if (PageActivity.hideDev) {
                    PageActivity.hideDev = false;
                }
            }
            closeConsole();
        }
        identify = "";
        invoke("destroy", null);
        super.onDestroy();
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
     * 初始化二维码与条形码视图
     */
    private void initScanerCodePageView() {
        scan_containter = findViewById(R.id.scan_containter);
        scan_main = findViewById(R.id.scan_main);
        //
        ImageView mQrLineView = findViewById(R.id.capture_scan_line);
        RxAnimationTool.ScaleUpDowm(mQrLineView);
        //
        CameraManager.init(this);
        scan_hasSurface = false;
        scan_inactivityTimer = new InactivityTimer(this);
        //
        if (mPageInfo.getUrl() != null) {
            ((TextView) findViewById(R.id.scan_desc)).setText(getPageInfo().getUrl());
        }
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
        switch (mPageInfo.getStatusBarType()) {
            case "fullscreen":
                //全屏
                getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN, WindowManager.LayoutParams.FLAG_FULLSCREEN);
                if (mPageInfo.getSoftInputMode().equals("auto")) {
                    mPageInfo.setSoftInputMode("pan");
                }
                break;
            case "immersion":
                //沉浸式
                setImmersionStatusBar();
                if (mPageInfo.getSoftInputMode().equals("auto")) {
                    mPageInfo.setSoftInputMode("pan");
                }
                break;
            default:
                //默认
                if (mPageInfo.isSwipeBack() && Build.VERSION.SDK_INT > Build.VERSION_CODES.KITKAT) {
                    StatusBarUtil.setColorForSwipeBack(this, Color.parseColor(mPageInfo.getStatusBarColor()), mPageInfo.getStatusBarAlpha());
                    KeyboardUtils.registerSoftInputChangedListener(this, (int height) -> {
                        if (KeyboardUtils.isSoftInputVisible(this)) {
                            KeyboardUtils.unregisterSoftInputChangedListener(this);
                            StatusBarUtil.cancelColorForSwipeBack(this);
                            StatusBarUtil.setColor(this, Color.parseColor(mPageInfo.getStatusBarColor()), mPageInfo.getStatusBarAlpha());
                        }
                    });
                }else{
                    StatusBarUtil.setColor(this, Color.parseColor(mPageInfo.getStatusBarColor()), mPageInfo.getStatusBarAlpha());
                }
                break;
        }
        //
        if (mPageInfo.getStatusBarStyle() != null) {
            setStatusBarStyle(mPageInfo.getStatusBarStyle());
        }
        //
        setSoftInputMode(mPageInfo.getSoftInputMode());
        initDefaultPageView();
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
                    public void success(String resData, boolean isCache) {
                        String[] temp = resData.split("\n");
                        String html = "";
                        if (temp.length > 0) {
                            html = temp[0];
                            html = html.replaceAll(" ", "");
                        }
                        mPageInfo.setPageType(html.startsWith("//{\"framework\":\"Vue\"") ? "app" : "web");
                        initDefaultPageView();
                        mAuto.setVisibility(View.GONE);
                    }

                    @Override
                    public void error(String error) {
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
        mSwipeBackHelper.setIsOnlyTrackingLeftEdge(true);
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
     * Scaner
     * 初始化二维码与条形码相机
     */
    private void initScanerCodeCamera(SurfaceHolder surfaceHolder) {
        try {
            CameraManager.get().openDriver(surfaceHolder);
            Point point = CameraManager.get().getCameraResolution();
            AtomicInteger width = new AtomicInteger(point.y);
            AtomicInteger height = new AtomicInteger(point.x);
            int cropWidth = scan_main.getWidth() * width.get() / scan_containter.getWidth();
            int cropHeight = scan_main.getHeight() * height.get() / scan_containter.getHeight();
            setScanCropWidth(cropWidth);
            setScanCropHeight(cropHeight);

            SurfaceView surfaceView = findViewById(R.id.scan_preview);
            ViewGroup.LayoutParams params = surfaceView.getLayoutParams();
            float screenRatio = ((float) scan_containter.getWidth()) / scan_containter.getHeight();
            float cameraRatio = ((float) width.get()) / height.get();
            if (cameraRatio > screenRatio) {
                params.width = (int) (((float) scan_containter.getHeight()) / height.get() * width.get());
                params.height = scan_containter.getHeight();
            }else{
                params.width = scan_containter.getWidth();
                params.height = (int) (((float) scan_containter.getWidth()) / width.get() * height.get());
            }
            surfaceView.setLayoutParams(params);
        } catch (IOException | RuntimeException ioe) {
            return;
        }
        if (scan_handler == null) {
            scan_handler = new CaptureActivityHandler(PageActivity.this);
        }
    }

    /**
     * Scaner
     * @param view
     */
    public void scanClick(View view) {
        int viewId = view.getId();
        if (viewId == R.id.scan_light) {
            scanLight();
        } else if (viewId == R.id.scan_back) {
            finish();
        } else if (viewId == R.id.scan_picture) {
            RxPhotoTool.openLocalImage(this);
        } else if (viewId == R.id.scan_image_qr) {
            eeuiCommon.setViewWidthHeight(scan_main, SizeUtils.dp2px(240), SizeUtils.dp2px(240));
            invokeAndKeepAlive("changeQr", null);
        } else if (viewId == R.id.scan_image_bar) {
            eeuiCommon.setViewWidthHeight(scan_main, SizeUtils.dp2px(300), SizeUtils.dp2px(120));
            invokeAndKeepAlive("changeBar", null);
        }
    }

    /**
     * Scaner
     */
    private void scanLight() {
        if (scan_flashing) {    // 开闪光灯
            scan_flashing = false;
            CameraManager.get().openLight();
            invokeAndKeepAlive("openLight", null);
        } else {            // 关闪光灯
            scan_flashing = true;
            CameraManager.get().offLight();
            invokeAndKeepAlive("offLight", null);
        }
    }

    /**
     * Scaner
     * @return
     */
    public int getScanCropWidth() {
        return scan_cropWidth;
    }

    /**
     * Scaner
     * @param cropWidth
     */
    public void setScanCropWidth(int cropWidth) {
        scan_cropWidth = cropWidth;
        CameraManager.FRAME_WIDTH = scan_cropWidth;

    }

    /**
     * Scaner
     * @return
     */
    public int getScanCropHeight() {
        return scan_cropHeight;
    }

    /**
     * Scaner
     * @param cropHeight
     */
    public void setScanCropHeight(int cropHeight) {
        this.scan_cropHeight = cropHeight;
        CameraManager.FRAME_HEIGHT = scan_cropHeight;
    }

    /**
     * Scaner
     * @param result
     */
    public void handleScanDecode(Result result) {
        scan_inactivityTimer.onActivity();
        RxBeepTool.playBeep(this, scan_vibrate);
        //
        Map<String, Object> retData = new HashMap<>();
        retData.put("source", "camera");
        retData.put("result", result);
        retData.put("format", result.getBarcodeFormat());
        retData.put("text", result.getText());
        invokeAndKeepAlive("success", retData);
    }

    /**
     * Scaner
     * @return
     */
    public Handler getScanHandler() {
        return scan_handler;
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
                    if (!mPageInfo.isTranslucent()) {
                        mWeexProgressBg.setVisibility(View.VISIBLE);
                    }
                }
            }), 100);
        }
        //
        weexCreateInstance();
        mWXSDKInstance.onActivityCreate();
        eeuiPage.cachePage(this, eeuiBase.config.verifyFile(mPageInfo.getUrl()), mPageInfo.getCache(), mPageInfo.getParams(), (resParams, newUrl) -> mWXSDKInstance.renderByUrl(mPageInfo.getPageName(), newUrl, resParams, null, WXRenderStrategy.APPEND_ASYNC));
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
                retData.put("errUrl", instance.getBundleUrl());
                invokeAndKeepAlive("error", retData);
                //
                mError.setVisibility(View.VISIBLE);
                mErrorCode.setText(String.valueOf(errCode));
                mErrorMsg = errMsg;
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

    private void setImmersionStatusBar() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            getWindow().setStatusBarColor(Color.TRANSPARENT);
            getWindow().getDecorView().setSystemUiVisibility(View.SYSTEM_UI_FLAG_LAYOUT_STABLE | View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN);
        } else if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
            getWindow().setFlags(WindowManager.LayoutParams.FLAG_TRANSLUCENT_STATUS, WindowManager.LayoutParams.FLAG_TRANSLUCENT_STATUS);
        }
    }

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
                    break;

                case "resume":
                case "pause":
                    break;

                default:
                    return;
            }
            WXComponent mWXComponent = mWXSDKInstance.getRootComponent();
            if (mWXComponent != null) {
                WXEvent events = mWXComponent.getEvents();
                boolean hasEvent = events.contains(eeuiConstants.Event.LIFECYCLE);
                if (hasEvent) {
                    Map<String, Object> retData = new HashMap<>();
                    retData.put("status", status);
                    WXBridgeManager.getInstance().fireEventOnNode(mWXSDKInstance.getInstanceId(), mWXComponent.getRef(), eeuiConstants.Event.LIFECYCLE, retData, null);
                    if (status.equals("ready")) {
                        lifecycleListener("resume");
                    }
                }
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
        switch (mode) {
            case "resize":
                getWindow().setSoftInputMode(WindowManager.LayoutParams.SOFT_INPUT_ADJUST_RESIZE);
                break;
            case "pan":
                getWindow().setSoftInputMode(WindowManager.LayoutParams.SOFT_INPUT_ADJUST_PAN);
                break;
            case "auto":
                getWindow().setSoftInputMode(WindowManager.LayoutParams.SOFT_INPUT_ADJUST_UNSPECIFIED);
                break;
        }
        mPageInfo.setSoftInputMode(mode);
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
     * 修改状态栏样式
     * @param isLight
     */
    public void setStatusBarStyle(boolean isLight) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            View decorView = this.getWindow().getDecorView();
            if (isLight) {
                //白色样式
                decorView.setSystemUiVisibility(decorView.getSystemUiVisibility() & ~View.SYSTEM_UI_FLAG_LIGHT_STATUS_BAR);
            } else {
                //黑色样式
                decorView.setSystemUiVisibility(decorView.getSystemUiVisibility() | View.SYSTEM_UI_FLAG_LIGHT_STATUS_BAR);
            }
        } else {
            Toast.makeText(this, "当前设备不支持状态栏字体变色", Toast.LENGTH_SHORT).show();
        }
    }

    /**
     * 是否是字体
     * @param var
     * @return
     */
    private boolean isFontIcon(String var) {
        return var != null && !var.contains("//") && !var.startsWith("data:");
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

        String title = eeuiJson.getString(item, "title", "");
        String titleColor = eeuiJson.getString(item, "titleColor", "#232323");
        float titleSize = eeuiJson.getFloat(item, "titleSize", 32f);
        String subtitle = eeuiJson.getString(item, "subtitle", "");
        String subtitleColor = eeuiJson.getString(item, "subtitleColor", "#232323");
        float subtitleSize = eeuiJson.getFloat(item, "subtitleSize", 24f);
        navigationBarBackgroundColor = eeuiJson.getString(item, "backgroundColor", (!mPageInfo.getStatusBarColor().equals("") ? mPageInfo.getStatusBarColor() : "#3EB4FF"));

        titleBar.setBackgroundColor(Color.parseColor(navigationBarBackgroundColor));
        showNavigation();

        titleBarTitle.setText(title);
        titleBarTitle.setTextSize(TypedValue.COMPLEX_UNIT_PX, eeuiScreenUtils.weexPx2dp(mWXSDKInstance, titleSize));
        titleBarTitle.setTextColor(Color.parseColor(titleColor));

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
            setNavigationItems(eeuiJson.parseObject("{'icon':'tb-back', 'iconSize': 36}"), "left", result -> eeuiPage.closeWin(mPageInfo.getPageName()));
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
        LinearLayout.LayoutParams layoutParams = new LinearLayout.LayoutParams(LinearLayout.LayoutParams.WRAP_CONTENT, LinearLayout.LayoutParams.MATCH_PARENT);
        for (int i = 0; i < buttonArray.size(); i++) {
            JSONObject item = eeuiJson.parseObject(buttonArray.get(i));
            String title = eeuiJson.getString(item, "title", "");
            String titleColor = eeuiJson.getString(item, "titleColor", "#232323");
            float titleSize = eeuiJson.getFloat(item, "titleSize", 28f);
            String icon = eeuiJson.getString(item, "icon", "");
            String iconColor = eeuiJson.getString(item, "iconColor", "#232323");
            float iconSize = eeuiJson.getFloat(item, "iconSize", 28f);
            int width = eeuiScreenUtils.weexPx2dp(mWXSDKInstance, item.get("width"));
            int spacing = eeuiScreenUtils.weexPx2dp(mWXSDKInstance, item.get("spacing"), 10);

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
                    ImageView imgView = new ImageView(this);
                    imgView.setLayoutParams(new LinearLayout.LayoutParams(eeuiScreenUtils.weexPx2dp(mWXSDKInstance, iconSize), LinearLayout.LayoutParams.MATCH_PARENT));
                    imgView.setScaleType(ImageView.ScaleType.FIT_CENTER);
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
    private int deBugButtonSize = 128;
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
        deBugButton = new TextView(this);
        deBugButton.setText("DEV");
        deBugButton.setTextColor(Color.WHITE);
        deBugButton.setTextSize(14);
        deBugButton.setGravity(Gravity.CENTER);
        if (eeuiCommon.getVariateInt("__deBugSocket:Status") == 1) {
            deBugButton.setBackgroundResource(R.drawable.debug_button_success);
        }else{
            deBugButton.setBackgroundResource(R.drawable.debug_button_connect);
        }
        if (PageActivity.hideDev) {
            deBugButton.setVisibility(View.GONE);
        }
        deBugButton.setOnClickListener(deBugClickListener);
        FloatDragView.Builder mFloatDragView = new FloatDragView.Builder();
        mFloatDragView.setActivity(this)
                .setDefaultLeft(eeuiParse.parseInt(eeuiCommon.getVariate("__pageActivity::FloatDrag:Left"), ScreenUtils.getScreenWidth() - deBugButtonSize))
                .setDefaultTop(eeuiParse.parseInt(eeuiCommon.getVariate("__pageActivity::FloatDrag:Top"), (ScreenUtils.getScreenHeight() - deBugButtonSize) / 2))
                .setNeedNearEdge(true)
                .setSize(deBugButtonSize)
                .setView(deBugButton)
                .setUpdateListener((left, top) -> {
                    eeuiCommon.setVariate("__pageActivity::FloatDrag:Left", left);
                    eeuiCommon.setVariate("__pageActivity::FloatDrag:Top", top);
                })
                .build();
    }

    /**
     * 刷新debug按钮
     * @param status
     */
    private void deBugButtonRefresh(int status) {
        if (deBugButton == null) {
            return;
        }
        if (status == 1) {
            deBugButton.setBackgroundResource(R.drawable.debug_button_success);
            eeuiCommon.setVariate("__deBugSocket:Status", 1);
        }else if (status == 2) {
            deBugButton.setBackgroundResource(R.drawable.debug_button_connect);
            eeuiCommon.setVariate("__deBugSocket:Status", 2);
        }else if (status == 3) {
            deBugButton.setVisibility(View.GONE);
            return;
        }
        FrameLayout.LayoutParams layoutParams = new FrameLayout.LayoutParams(deBugButtonSize, deBugButtonSize);
        int left = eeuiParse.parseInt(eeuiCommon.getVariate("__pageActivity::FloatDrag:Left"), ScreenUtils.getScreenWidth() - deBugButtonSize);
        int top = eeuiParse.parseInt(eeuiCommon.getVariate("__pageActivity::FloatDrag:Top"), (ScreenUtils.getScreenHeight() - deBugButtonSize) / 2);
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
        if (eeuiCommon.getVariateInt("__deBugSocket:Init") == 0) {
            eeuiCommon.setVariate("__deBugSocket:Init", 1);
            //
            JSONObject jsonData = eeuiJson.parseObject(eeuiCommon.getAssetsFile(this, "file://assets/eeui/config.json"));
            eeuiCommon.setVariate("__deBugSocket:Host", eeuiJson.getString(jsonData, "socketHost"));
            eeuiCommon.setVariate("__deBugSocket:Port", eeuiJson.getString(jsonData, "socketPort"));
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
                            deBugSocketConnect("initialize");
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
        String host = eeuiCommon.getVariateStr("__deBugSocket:Host");
        String port = eeuiCommon.getVariateStr("__deBugSocket:Port");
        if (host.length() == 0 || port.length() == 0) {
            return;
        }
        deBugSocketWsManager = new WsManager.Builder(this)
                .client(new OkHttpClient().newBuilder().pingInterval(15, TimeUnit.SECONDS).retryOnConnectionFailure(true).build())
                .wsUrl("ws://" + host + ":" + port + "?mode=" + mode)
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
        List<ActionItem> mActionItem = new ArrayList<>();
        mActionItem.add(new ActionItem(1, eeuiCommon.getVariateInt("__deBugSocket:Status") == 1 ? "WiFi真机同步 [已连接]" : "WiFi真机同步"));
        mActionItem.add(new ActionItem(2, deBugKeepScreen.contentEquals("ON") ? "屏幕常亮 [已开启]" : "屏幕常亮"));
        mActionItem.add(new ActionItem(3, "页面信息"));
        mActionItem.add(new ActionItem(4, "扫一扫"));
        mActionItem.add(new ActionItem(5, "刷新"));
        mActionItem.add(new ActionItem(6, "Console"));
        mActionItem.add(new ActionItem(7, "隐藏DEV"));
        mActionItem.add(new ActionItem(8, "重启APP"));
        if (eeuiBase.config.verifyIsUpdate()) {
            mActionItem.add(new ActionItem(9, "清除热更新数据"));
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
                                String host = eeuiCommon.getVariateStr("__deBugSocket:Host");
                                String port = eeuiCommon.getVariateStr("__deBugSocket:Port");
                                String inputObject = "{title:\"WiFi真机同步配置\",message:\"配置成功后，可实现真机同步实时预览\",buttons:[\"取消\",\"连接\"],inputs:[{type:'text',placeholder:'请输入IP地址',value:'" + host + "',autoFocus:true},{type:'number',placeholder:'请输入端口号',value:'" + port + "'}]}";
                                eeuiAlertDialog.input(PageActivity.this, eeuiJson.parseObject(inputObject), new JSCallback() {
                                    @Override
                                    public void invoke(Object data) {
                                        Map<String, Object> retData = eeuiMap.objectToMap(data);
                                        if (eeuiParse.parseStr(retData.get("status")).equals("click") && eeuiParse.parseStr(retData.get("title")).equals("连接")) {
                                            JSONArray dData = eeuiJson.parseArray(retData.get("data"));
                                            eeuiCommon.setVariate("__deBugSocket:Host", dData.getString(0));
                                            eeuiCommon.setVariate("__deBugSocket:Port", dData.getString(1));
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
                                showPageInfo(JSON.toJSONString(getPageInfo().toMap(), true));
                                break;
                            }
                            case 3: {
                                PageActivity.startScanerCode(PageActivity.this, "{}", new JSCallback() {
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
                                                        eeuiCommon.setVariate("__deBugSocket:Host", host);
                                                        eeuiCommon.setVariate("__deBugSocket:Port", port);
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
                                reload();
                                break;
                            }
                            case 5: {
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
                                            eeuiCommon.setVariate("__deBugSocket:Init", 0);
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
                                eeuiCommon.setVariate("__deBugSocket:Init", 0);
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
            String host = eeuiCommon.getVariateStr("__deBugSocket:Host");
            String port = eeuiCommon.getVariateStr("__deBugSocket:Port");
            if (deBugWsOpenUrl.contentEquals(host + ":" + port)) {
                mHandler.postDelayed(()-> {
                    Log.d("[socket]", "reconnect");
                    deBugSocketConnect("reconnect");
                }, 3000);
            } else {
                Log.d("[socket]", "onFailure");
                Toast.makeText(PageActivity.this, "WiFi同步连接失败：" + t.getMessage(), LENGTH_SHORT).show();
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
            Log.d("[socket]", "onMessage: " + text);
            //
            if (text.startsWith("HOMEPAGE:")) {
                List<Activity> activityList = eeui.getActivityList();
                if (activityList.size() >= 2 && activityList.get(0).getClass().getName().endsWith(".WelcomeActivity")) {
                    activityList.remove(0);
                }
                for (int i = activityList.size() - 1; i >= 0; --i) {
                    Activity activity = activityList.get(i);
                    if (i == 0) {
                        if (activity instanceof PageActivity) {
                            PageActivity mActivity = ((PageActivity) activity);
                            String homePage = eeuiCommon.getCachesString(PageActivity.this, "__deBugSocket", "homePage");
                            String mHomePage = text.substring(9);
                            if (!homePage.equals(mHomePage))  {
                                eeuiCommon.setCachesString(PageActivity.this, "__deBugSocket", "homePage", mHomePage, 2);
                                mHandler.postDelayed(()-> {
                                    mActivity.mPageInfo.setUrl(mHomePage);
                                    mActivity.reload();
                                    BGAKeyboardUtil.closeKeyboard(PageActivity.this);
                                }, 300);
                            }
                        }
                    }else{
                        activity.finish();
                    }
                }
            }else if (text.startsWith("HOMEPAGEBACK:")) {
                List<Activity> activityList = eeui.getActivityList();
                Activity activity = activityList.get(0);
                if (activity instanceof PageActivity) {
                    PageActivity mActivity = ((PageActivity) activity);
                    String mHomePage = text.substring(13);
                    eeuiCommon.setCachesString(PageActivity.this, "__deBugSocket", "homePage", mHomePage, 2);
                    mActivity.mPageInfo.setUrl(mHomePage);
                    mActivity.reload();
                    BGAKeyboardUtil.closeKeyboard(PageActivity.this);
                }
            }else if (text.startsWith("RECONNECT:")) {
                String urlHost = getHostPort(text.substring(10));
                String nowHost = "";
                Activity activity = eeui.getActivityList().getLast();
                if (activity instanceof PageActivity) {
                    PageActivity mActivity = ((PageActivity) activity);
                    nowHost = getHostPort(mActivity.getPageInfo().getUrl());
                }
                if (!urlHost.equals(nowHost)) {
                    handleMessage("HOMEPAGE:" + text.substring(10));
                }
            }else if (text.startsWith("RELOADPAGE:")) {
                String url = text.substring(11);
                List<Activity> activityList = eeui.getActivityList();
                boolean already = false;
                int size = activityList.size() - 1;
                for (int i = size; i >= 0; --i) {
                    Activity activity = activityList.get(i);
                    if (activity instanceof PageActivity) {
                        PageActivity mActivity = ((PageActivity) activity);
                        if (eeuiPage.realUrl(mActivity.mPageInfo.getUrl()).startsWith(url)) {
                            if (i == size) {
                                mActivity.reload();
                                BGAKeyboardUtil.closeKeyboard(PageActivity.this);
                            }else{
                                mActivity.getPageInfo().setResumeUrl(url);
                            }
                            already = true;
                        }
                    }
                }
                if (!already) {
                    for (int i = 0; i < tabViewDebug.size(); i++) {
                        ResultCallback<String> call = tabViewDebug.get(i);
                        if (call != null) {
                            call.onReceiveResult(url);
                        }
                    }
                }
            }else if (text.startsWith("APPBOARDCONTENT:")) {
                String[] temp = text.substring(16).split("::");
                eeuiPage.mAppboardContent.put(temp[0], text.substring(16 + 2 + temp[0].length()));
                //
                Activity activity = eeui.getActivityList().getLast();
                if (activity instanceof PageActivity) {
                    PageActivity mActivity = ((PageActivity) activity);
                    mActivity.reload();
                }
            }else if (text.contentEquals("REFRESH")) {
                Activity activity = eeui.getActivityList().getLast();
                if (activity instanceof PageActivity) {
                    PageActivity mActivity = ((PageActivity) activity);
                    mActivity.reload();
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
        mPageLogView.findViewById(R.id.v_space).setOnClickListener(v -> closeConsole());
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
        eeuiPage.cachePage(this, "file://assets/main-console.js", 0, null, (resParams, newUrl) -> mInstance.renderByUrl("Console::" + mPageInfo.getPageName(), newUrl, resParams, null, WXRenderStrategy.APPEND_ASYNC));
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
}
