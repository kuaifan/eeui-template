package app.eeui.playground;

import android.graphics.Color;
import android.os.Build;
import android.os.Bundle;
import android.os.Handler;
import android.view.View;
import android.view.WindowManager;

import androidx.appcompat.app.AppCompatActivity;

import com.alibaba.fastjson.JSONObject;
import com.taobao.weex.bridge.JSCallback;

import java.util.Map;

import app.eeui.framework.extend.bean.PageBean;
import app.eeui.framework.extend.module.eeuiBase;
import app.eeui.framework.extend.module.eeuiMap;
import app.eeui.framework.extend.module.eeuiPage;
import app.eeui.framework.extend.module.eeuiParse;
import app.eeui.framework.ui.eeui;

public class WelcomeActivity extends AppCompatActivity {

    private boolean isOpenNext = false;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        fullScreen();
        setContentView(R.layout.activity_splash);
        new Handler().postDelayed(() -> openNext(""), eeuiBase.cloud.welcome(this, new eeuiBase.OnWelcomeListener() {
            @Override
            public void skip() {
                openNext("");
            }

            @Override
            public void finish() {
                openNext("");
            }

            @Override
            public void click(String var) {
                openNext(var);
            }
        }));
    }

    @Override
    public void onBackPressed() {

    }

    private void fullScreen() {
        getWindow().getDecorView().setSystemUiVisibility(View.SYSTEM_UI_FLAG_FULLSCREEN | View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN | View.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION | View.SYSTEM_UI_FLAG_HIDE_NAVIGATION);
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
            WindowManager.LayoutParams lp = getWindow().getAttributes();
            lp.layoutInDisplayCutoutMode = WindowManager.LayoutParams.LAYOUT_IN_DISPLAY_CUTOUT_MODE_SHORT_EDGES;
            getWindow().setAttributes(lp);
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            getWindow().setStatusBarColor(Color.TRANSPARENT);
        }
    }

    private void openNext(String pageUrl) {
        if (isOpenNext) {
            return;
        }
        isOpenNext = true;
        //
        eeuiBase.config.getHomeUrl(homeUrl -> {
            PageBean mPageBean = new PageBean();
            mPageBean.setUrl(homeUrl);
            mPageBean.setPageName(eeuiBase.config.getHomeParams("pageName", "firstPage"));
            mPageBean.setPageTitle(eeuiBase.config.getHomeParams("pageTitle", ""));
            mPageBean.setPageType(eeuiBase.config.getHomeParams("pageType", "app"));
            mPageBean.setParams(eeuiBase.config.getHomeParams("params", "{}"));
            mPageBean.setCache(eeuiParse.parseLong(eeuiBase.config.getHomeParams("cache", "0")));
            mPageBean.setLoading(eeuiParse.parseBool(eeuiBase.config.getHomeParams("loading", "true")));
            mPageBean.setLoadingBackground(eeuiParse.parseBool(eeuiBase.config.getHomeParams("loadingBackground", "false")));
            mPageBean.setSwipeBack(eeuiParse.parseBool(eeuiBase.config.getHomeParams("swipeBack", "true")));
            mPageBean.setSwipeFullBack(eeuiParse.parseBool(eeuiBase.config.getHomeParams("swipeFullBack", "false")));
            mPageBean.setSwipeColorBack(eeuiParse.parseBool(eeuiBase.config.getHomeParams("swipeColorBack", "true")));
            mPageBean.setStatusBarType(eeuiBase.config.getHomeParams("statusBarType", "normal"));
            mPageBean.setStatusBarColor(eeuiBase.config.getHomeParams("statusBarColor", "#3EB4FF"));
            mPageBean.setStatusBarAlpha(eeuiParse.parseInt(eeuiBase.config.getHomeParams("statusBarAlpha", "0")));
            String statusBarStyle = eeuiBase.config.getHomeParams("statusBarStyle", null);
            if (statusBarStyle != null) {
                mPageBean.setStatusBarStyle(eeuiParse.parseBool(statusBarStyle));
            }
            mPageBean.setSoftInputMode(eeuiBase.config.getHomeParams("softInputMode", "auto"));
            mPageBean.setBackgroundColor(eeuiBase.config.getHomeParams("backgroundColor", "#ffffff"));
            mPageBean.setFirstPage(true);
            mPageBean.setCallback(new JSCallback() {
                @Override
                public void invoke(Object data) {

                }

                @Override
                public void invokeAndKeepAlive(Object data) {
                    Map<String, Object> retData = eeuiMap.objectToMap(data);
                    String status = eeuiParse.parseStr(retData.get("status"));
                    if (status.equals("create")) {
                        eeuiBase.cloud.appData(false);
                        //
                        if (!"".equals(pageUrl)) {
                            String pageName = eeuiParse.parseStr(retData.get("pageName"));
                            PageBean tmpBean = eeuiPage.getPageBean(pageName);
                            if (tmpBean != null) {
                                JSONObject json = new JSONObject();
                                json.put("url", pageUrl);
                                json.put("pageType", "app");
                                new eeui().openPage(tmpBean.getContext(), json.toJSONString(), null);
                            }
                        }
                    }
                }
            });
            eeuiPage.openWin(WelcomeActivity.this, mPageBean);
            finish();
        });
    }
}
