package app.eeui.framework.extend.view.webviewBridge;

import android.annotation.SuppressLint;
import android.util.Log;

import com.alibaba.fastjson.JSON;

import java.lang.ref.WeakReference;

import app.eeui.framework.extend.view.ExtendWebView;

public class JsCallback {
    private static final String CALLBACK_JS_FORMAT = "javascript:%s.callback(%d, %d %s);";
    private int mIndex;
    private boolean mCouldGoOn;
    private WeakReference<ExtendWebView> mWebViewRef;
    private int mIsPermanent;
    private String mInjectedName;

    public JsCallback(ExtendWebView view, String injectedName, int index) {
        mCouldGoOn = true;
        mWebViewRef = new WeakReference<>(view);
        mInjectedName = injectedName;
        mIndex = index;
    }

    @SuppressLint("DefaultLocale")
    public void apply(Object... args) throws JsCallbackException {
        if (mWebViewRef.get() == null) {
            throw new JsCallbackException("the WebView related to the JsCallback has been recycled");
        }
        if (!mCouldGoOn) {
            throw new JsCallbackException("the JsCallback isn't permanent,cannot be called more than once");
        }
        StringBuilder sb = new StringBuilder();
        for (Object arg : args) {
            sb.append(",");
            if (arg instanceof String) {
                sb.append("\"");
                sb.append(String.valueOf(arg));
                sb.append("\"");
            } else if (arg instanceof Integer
                    || arg instanceof Long
                    || arg instanceof Boolean
                    || arg instanceof Float
                    || arg instanceof Double) {
                sb.append(arg);
            } else {
                sb.append(JSON.toJSONString(arg));
            }
        }
        String execJs = String.format(CALLBACK_JS_FORMAT, mInjectedName, mIndex, mIsPermanent, sb.toString());
        Log.d("JsCallBack", execJs);
        mWebViewRef.get().loadUrl(execJs);
        mCouldGoOn = mIsPermanent > 0;
    }

    public void setPermanent(boolean value) {
        mIsPermanent = value ? 1 : 0;
    }

    public static class JsCallbackException extends Exception {
        public JsCallbackException(String msg) {
            super(msg);
        }
    }
}
