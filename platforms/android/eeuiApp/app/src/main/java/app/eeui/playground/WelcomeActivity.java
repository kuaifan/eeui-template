package app.eeui.playground;

import android.os.Bundle;
import android.os.Handler;
import android.support.v7.app.AppCompatActivity;

import com.alibaba.fastjson.JSONObject;
import com.taobao.weex.bridge.JSCallback;

import java.util.Map;

import app.eeui.framework.extend.bean.PageBean;
import app.eeui.framework.extend.module.eeuiBase;
import app.eeui.framework.extend.module.eeuiMap;
import app.eeui.framework.extend.module.eeuiPage;
import app.eeui.framework.extend.module.eeuiParse;
import app.eeui.framework.ui.eeui;
import app.eeui.playground.R;

public class WelcomeActivity extends AppCompatActivity {

    private boolean isOpenNext = false;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
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

    private void openNext(String pageUrl) {
        if (isOpenNext) {
            return;
        }
        isOpenNext = true;
        //
        PageBean mPageBean = new PageBean();
        mPageBean.setUrl(eeuiBase.config.getHome());
        mPageBean.setPageName(eeuiBase.config.getHomeParams("pageName", "firstPage"));
        mPageBean.setPageTitle(eeuiBase.config.getHomeParams("pageTitle", ""));
        mPageBean.setPageType(eeuiBase.config.getHomeParams("pageType", "app"));
        mPageBean.setParams(eeuiBase.config.getHomeParams("params", "{}"));
        mPageBean.setCache(eeuiParse.parseLong(eeuiBase.config.getHomeParams("cache", "0")));
        mPageBean.setLoading(eeuiParse.parseBool(eeuiBase.config.getHomeParams("loading", "true")));
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
                    eeuiBase.cloud.appData();
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
    }
}
