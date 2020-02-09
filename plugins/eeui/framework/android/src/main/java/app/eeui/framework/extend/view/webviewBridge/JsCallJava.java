package app.eeui.framework.extend.view.webviewBridge;

import android.annotation.SuppressLint;
import android.text.TextUtils;
import android.util.Log;

import com.alibaba.fastjson.JSONArray;
import com.alibaba.fastjson.JSONObject;
import com.google.gson.Gson;

import java.lang.reflect.Method;
import java.lang.reflect.Modifier;
import java.util.HashMap;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import app.eeui.framework.extend.module.eeuiJson;
import app.eeui.framework.extend.module.eeuiParse;
import app.eeui.framework.extend.view.ExtendWebView;

public class JsCallJava {
    private final static String TAG = "JsCallJava";
    private final static String RETURN_RESULT_FORMAT = "{\"code\": %d, \"result\": %s}";
    private HashMap<String, Method> mMethodsMap;
    private String mInjectedName;
    private String mPreloadInterfaceJS;
    private Gson mGson;

    public JsCallJava(String injectedName, Class injectedCls) {
        try {
            if (TextUtils.isEmpty(injectedName)) {
                throw new Exception("injected name can not be null");
            }
            mInjectedName = injectedName;
            mMethodsMap = new HashMap<>();
            //获取自身声明的所有方法（包括public private protected），getMethods会获得所有继承与非继承的方法
            Method[] methods = injectedCls.getDeclaredMethods();
            StringBuilder sb = new StringBuilder("javascript:(function(b){console.log(\"");
            sb.append(mInjectedName);
            sb.append(" initialization begin\");");
            sb.append("if(b.__").append(mInjectedName).append("===true){return}b.__").append(mInjectedName).append("=true;");
            sb.append("var a={queue:[],callback:function(){var d=Array.prototype.slice.call(arguments,0);var c=d.shift();var e=d.shift();this.queue[c].apply(this,d)/*;if(!e){delete this.queue[c]}*/}};");
            for (Method method : methods) {
                String sign;
                if (method.getModifiers() != (Modifier.PUBLIC | Modifier.STATIC) || (sign = genJavaMethodSign(method)) == null) {
                    continue;
                }
                mMethodsMap.put(sign, method);
                sb.append(String.format("a.%s=", method.getName()));
            }
            sb.append("function(){var f=Array.prototype.slice.call(arguments,0);if(f.length<1){throw\"");
            sb.append(mInjectedName);
            sb.append(" call error, message:miss method name\"}var e=[];for(var h=1;h<f.length;h++){var c=f[h];var j=typeof c;e[e.length]=j;if(j==\"function\"){var d=a.queue.length;a.queue[d]=c;f[h]=d}}var g=JSON.parse(prompt(JSON.stringify({__identify:\"").append(mInjectedName).append("\",method:f.shift(),types:e,args:f})));if(g.code!=200){throw\"");
            sb.append(mInjectedName);
            sb.append(" call error, code:\"+g.code+\", message:\"+g.result}return g.result};Object.getOwnPropertyNames(a).forEach(function(d){var c=a[d];if(typeof c===\"function\"&&d!==\"callback\"){a[d]=function(){return c.apply(a,[d].concat(Array.prototype.slice.call(arguments,0)))}}});b.");
            sb.append(mInjectedName);
            sb.append("=a;console.log(\"");
            sb.append(mInjectedName);
            sb.append(" initialization end\");");
            sb.append(" })(window);");
            mPreloadInterfaceJS = sb.toString();
        } catch (Exception e) {
            Log.e(TAG, "init js error:" + e.getMessage());
        }
    }

    private String genJavaMethodSign(Method method) {
        StringBuilder sign = new StringBuilder(method.getName());
        Class[] argsTypes = method.getParameterTypes();
        int len = argsTypes.length;
        if (len < 1 || argsTypes[0] != ExtendWebView.class) {
            Log.w(TAG, "method(" + sign + ") must use webview to be first parameter, will be pass");
            return null;
        }
        for (int k = 1; k < len; k++) {
            Class cls = argsTypes[k];
            if (cls == String.class) {
                sign.append("_S");
            } else if (cls == int.class ||
                    cls == long.class ||
                    cls == float.class ||
                    cls == double.class) {
                sign.append("_N");
            } else if (cls == boolean.class) {
                sign.append("_B");
            } else if (cls == JSONObject.class) {
                sign.append("_O");
            } else if (cls == JsCallback.class) {
                sign.append("_F");
            } else {
                sign.append("_P");
            }
        }
        return sign.toString();
    }

    public String getPreloadInterfaceJS() {
        return mPreloadInterfaceJS;
    }

    public String call(ExtendWebView webView, String jsonStr) {
        if (!TextUtils.isEmpty(jsonStr)) {
            try {
                JSONObject callJson = eeuiJson.parseObject(jsonStr);
                String methodName = callJson.getString("method");
                JSONArray argsVals = callJson.getJSONArray("args");
                int len = argsVals.size();

                Method currMethod = null;
                StringBuilder sign = null;
                Object[] values = new Object[0];

                for (String key : mMethodsMap.keySet()) {
                    if (key.startsWith(methodName + "_")) {

                        sign = new StringBuilder(key);
                        currMethod = mMethodsMap.get(sign.toString());
                        if (currMethod == null) {
                            continue;
                        }

                        Pattern p = Pattern.compile("_+[A-Z]");
                        Matcher m = p.matcher(key);

                        int count = 0;
                        while (m.find()) {
                            count++;
                        }

                        values = new Object[count + 1];
                        values[0] = webView;

                        int k = 0;
                        m.reset();
                        while (m.find()) {
                            Object temp = k < len ? argsVals.get(k) : null;
                            if (temp == null) {
                                values[k + 1] = null;
                                continue;
                            }
                            switch (m.group()) {
                                case "_S":
                                    values[k + 1] = eeuiParse.parseStr(temp);
                                    break;

                                case "_N":
                                    Class[] methodTypes = currMethod.getParameterTypes();
                                    Class ccls = methodTypes[k + 1];
                                    if (ccls == int.class) {
                                        values[k + 1] = eeuiParse.parseInt(temp);
                                    } else if (ccls == long.class) {
                                        values[k + 1] = eeuiParse.parseLong(temp);
                                    } else {
                                        values[k + 1] = eeuiParse.parseDouble(temp);
                                    }
                                    break;

                                case "_B":
                                    values[k + 1] = eeuiParse.parseBool(temp);
                                    break;

                                case "_O":
                                    values[k + 1] = eeuiJson.parseObject(temp);
                                    break;

                                case "_F":
                                    values[k + 1] = new JsCallback(webView, mInjectedName, eeuiParse.parseInt(temp));
                                    break;

                                case "_P":
                                    values[k + 1] = temp;
                                    break;
                            }
                            k++;
                        }
                        break;
                    }else if (key.contentEquals(methodName)) {
                        sign = new StringBuilder(key);
                        currMethod = mMethodsMap.get(sign.toString());
                        if (currMethod == null) {
                            continue;
                        }
                        values = new Object[1];
                        values[0] = webView;
                        break;
                    }
                }

                // 方法匹配失败
                if (currMethod == null) {
                    return getReturn(jsonStr, 500, "not found method(" + sign + ") with valid parameters");
                }

                return getReturn(jsonStr, 200, currMethod.invoke(null, values));
            } catch (Exception e) {
                //优先返回详细的错误信息
                if (e.getCause() != null) {
                    return getReturn(jsonStr, 500, "method execute error:" + e.getCause().getMessage());
                }
                return getReturn(jsonStr, 500, "method execute error:" + e.getMessage());
            }
        } else {
            return getReturn(jsonStr, 500, "call data empty");
        }
    }

    @SuppressLint("DefaultLocale")
    private String getReturn(String reqJson, int stateCode, Object result) {
        String insertResult;
        if (result == null) {
            insertResult = "null";
        } else if (result instanceof String) {
            result = ((String) result).replace("\"", "\\\"");
            insertResult = "\"" + result + "\"";
        } else if (!(result instanceof Integer)
                && !(result instanceof Long)
                && !(result instanceof Boolean)
                && !(result instanceof Float)
                && !(result instanceof Double)
                && !(result instanceof JSONObject)) {
            // 非数字或者非字符串的构造对象类型都要序列化后再拼接
            if (mGson == null) {
                mGson = new Gson();
            }
            insertResult = mGson.toJson(result);
        } else {
            //数字直接转化
            insertResult = String.valueOf(result);
        }
        String resString = String.format(RETURN_RESULT_FORMAT, stateCode, insertResult);
        Log.d(TAG, mInjectedName + " call json: " + reqJson + " result:" + resString);
        return resString;
    }
}
