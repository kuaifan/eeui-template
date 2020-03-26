package app.eeui.framework.extend.view.webviewBridge;

import android.webkit.JsPromptResult;
import android.webkit.ValueCallback;
import android.webkit.WebChromeClient;
import android.webkit.WebView;

import java.util.HashMap;
import java.util.Map;

import app.eeui.framework.extend.module.eeuiJson;
import app.eeui.framework.extend.view.ExtendWebView;


public class InjectedChromeClient extends WebChromeClient {
    private Map<String, JsCallJava> mJsCallJava = new HashMap<>();
    private boolean mIsInjectedJS;
    private boolean mAgainInjectedJS;
    private boolean enableApi = true;
    private ValueCallback<Integer> mHeightChanged;

    public InjectedChromeClient(Map<String, Class> data) {
        if (data != null) {
            for (String injectedName : data.keySet()) {
                String callName = "__eeui_js_" + injectedName;
                Class injectedCls = data.get(injectedName);
                if (injectedCls != null) {
                    mJsCallJava.put(callName, new JsCallJava(callName, injectedCls));
                }
            }
        }
    }

    public void setEnableApi(boolean enableApi) {
        this.enableApi = enableApi;
    }

    public void setHeightChanged(ValueCallback<Integer> mHeightChanged) {
        this.mHeightChanged = mHeightChanged;
    }

    @Override
    public void onProgressChanged(WebView view, int newProgress) {
        //为什么要在这里注入JS
        //1、OnPageStarted中注入有可能全局注入不成功，导致页面脚本上所有接口任何时候都不可用
        //2、OnPageFinished中注入，虽然最后都会全局注入成功，但是完成时间有可能太晚，当页面在初始化调用接口函数时会等待时间过长
        //3、在进度变化时注入，刚好可以在上面两个问题中得到一个折中处理
        //4、进度大于15时进行注入
        if (newProgress <= 15) {
            mIsInjectedJS = false;
        } else if (!mIsInjectedJS) {
            for (String key : mJsCallJava.keySet()) {
                JsCallJava value = mJsCallJava.get(key);
                if (value != null) {
                    view.loadUrl(value.getPreloadInterfaceJS());
                }
            }
            mIsInjectedJS = true;
        }
        //5、进度大于25%时再次进行注入，因为从测试看来只有进度大于这个数字页面才真正得到框架刷新加载，保证100%注入成功
        if (newProgress <= 25) {
            mAgainInjectedJS = false;
        } else if (!mAgainInjectedJS) {
            for (String key : mJsCallJava.keySet()) {
                JsCallJava value = mJsCallJava.get(key);
                if (value != null) {
                    view.loadUrl(value.getPreloadInterfaceJS());
                }
            }
            view.loadUrl("javascript:(function(b){console.log('requireModuleJs initialization begin');if(b.__requireModuleJs===true){return}b.__requireModuleJs=true;var a=function(name){if(['websocket','screenshots','citypicker','picture','rongim','umeng','pay','audio','deviceInfo','communication','geolocation','recorder','accelerometer','compass','amap','seekbar','network',].indexOf(name)!==-1){name='eeui/'+name}if(name==='networkTransfer'){name='eeui/network'}if(name==='videoView'){name='eeui/video'}name=name.replace(/\\/+(\\w)/g,function($1){return $1.toLocaleUpperCase()}).replace(/\\//g,'');var moduleName='__eeui_js_'+name;if(typeof b[moduleName]==='object'&&b[moduleName]!==null){return b[moduleName]}};b.requireModuleJs=a;var apiNum=0;var apiInter=setInterval(function(){if(typeof b.$ready==='function'){b.$ready();apiNum=300}else if(typeof $ready==='function'){$ready();apiNum=300}if(apiNum>=300){clearInterval(apiInter)}apiNum++},100);console.log('requireModuleJs initialization end')})(window);");
            if (mHeightChanged != null) {
                view.loadUrl("javascript:(function(b){console.log('eeuiHeightGetterJs initialization begin');if(b.__eeuiHeightGetterJs===true){return}b.__eeuiHeightGetterJs=true;var scrollHeight=0;var refreshHeight=function(){var tempHeight=document.body.scrollHeight||document.documentElement.scrollHeight;if(tempHeight!==scrollHeight){scrollHeight=tempHeight;console.log('eeuiHeightGetterJs height === '+scrollHeight);prompt(JSON.stringify({__identify:\"__eeui_heightGetterJs\",scrollHeight:scrollHeight}))}};refreshHeight();setInterval(refreshHeight,500);console.log('eeuiHeightGetterJs initialization end')})(window);");
            }
            mAgainInjectedJS = true;
        }
        //JS注入结束
        super.onProgressChanged(view, newProgress);
    }

    @Override
    public boolean onJsPrompt(WebView view, String url, String message, String defaultValue, JsPromptResult result) {
        String identify = eeuiJson.getString(message, "__identify");
        if ("__eeui_heightGetterJs".equals(identify)) {
            if (mHeightChanged != null) {
                mHeightChanged.onReceiveValue(eeuiJson.getInt(message, "scrollHeight"));
            }
            result.confirm(null);
            return true;
        }
        if (enableApi && !"".equals(identify) && view instanceof ExtendWebView) {
            JsCallJava JSCJ = mJsCallJava.get(identify);
            if (JSCJ != null) {
                result.confirm(JSCJ.call((ExtendWebView) view, message));
                return true;
            }
        }
        return super.onJsPrompt(view, url, message, defaultValue, result);
    }
}
