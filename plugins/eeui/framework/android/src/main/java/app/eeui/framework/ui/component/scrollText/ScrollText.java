package app.eeui.framework.ui.component.scrollText;

import android.app.Activity;
import android.content.Context;
import android.os.Handler;
import androidx.annotation.NonNull;
import android.util.TypedValue;
import android.view.View;
import android.view.ViewGroup;
import android.widget.LinearLayout;

import com.alibaba.fastjson.JSONObject;

import com.taobao.weex.WXSDKInstance;
import com.taobao.weex.annotation.JSMethod;
import com.taobao.weex.bridge.JSCallback;
import com.taobao.weex.ui.action.BasicComponentData;
import com.taobao.weex.ui.component.WXVContainer;

import java.util.HashMap;
import java.util.Map;

import app.eeui.framework.R;
import app.eeui.framework.activity.PageActivity;
import app.eeui.framework.extend.module.eeuiCommon;
import app.eeui.framework.extend.module.eeuiConstants;

import app.eeui.framework.extend.module.eeuiJson;
import app.eeui.framework.extend.module.eeuiMap;
import app.eeui.framework.extend.module.eeuiParse;
import app.eeui.framework.extend.module.eeuiScreenUtils;
import app.eeui.framework.extend.view.AutoScrollTextView;
import app.eeui.framework.ui.eeui;

/**
 * Created by WDM on 2018/3/5.
 */
public class ScrollText extends WXVContainer<ViewGroup> implements View.OnClickListener {

    private static final String TAG = "ScrollText";

    private View mView;

    private String mText = "";

    private LinearLayout v_body;

    private AutoScrollTextView v_autotext;

    private int isPause = 0;

    public ScrollText(WXSDKInstance instance, WXVContainer parent, BasicComponentData basicComponentData) {
        super(instance, parent, basicComponentData);
    }

    @Override
    protected ViewGroup initComponentHostView(@NonNull Context context) {
        mView = ((Activity) context).getLayoutInflater().inflate(R.layout.layout_eeui_scroll_text, null);
        initPagerView();
        appleStyleAfterCreated();
        //
        if (getEvents().contains(eeuiConstants.Event.READY)) {
            fireEvent(eeuiConstants.Event.READY, null);
        }
        //
        if (context instanceof PageActivity) {
            ((PageActivity) context).setPageStatusListener("__ScrollText::" + eeuiCommon.randomString(6), new JSCallback() {
                @Override
                public void invoke(Object data) {
                }

                @Override
                public void invokeAndKeepAlive(Object data) {
                    Map<String, Object> retData = eeuiMap.objectToMap(data);
                    if (retData == null) {
                        return;
                    }
                    String status = eeuiParse.parseStr(retData.get("status"));
                    switch (status) {
                        case "pause":
                            isPause++;
                            stopScroll();
                            break;

                        case "resume":
                            resumeScroll(0);
                            break;
                    }
                }
            });
        }
        //
        return (ViewGroup) mView;
    }

    /**
     * 恢复滚动
     * @param num
     */
    private void resumeScroll(int num) {
        new Handler().postDelayed(() -> {
            if (eeui.finishingNumber > 0 && num < 35) {
                resumeScroll(num + 1);
                return;
            }
            if (isPause == 0) {
                return;
            }
            isPause--;
            if (isPause == 0) {
                if (v_autotext == null) {
                    return;
                }
                v_autotext.startScroll();
            }
        }, 300);
    }

    @Override
    public void addSubView(View view, int index) {

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

            case "text":
            case "content":
                setText(eeuiParse.parseStr(val, ""));
                v_autotext.startScroll();
                return true;

            case "speed":
                setSpeed(eeuiParse.parseFloat(val, 2f));
                return true;

            case "fontSize":
                setTextSize(val);
                return true;

            case "color":
                setTextColor(eeuiParse.parseStr(val, "#000000"));
                return true;

            case "backgroundColor":
                setBackgroundColor(eeuiParse.parseStr(val, "#00ffffff"));
                return true;

            default:
                return false;
        }
    }

    @Override
    public void onClick(View view) {
        if (isStarting()) {
            stopScroll();
        } else {
            startScroll();
        }
        if (getEvents().contains(eeuiConstants.Event.ITEM_CLICK)) {
            Map<String, Object> data = new HashMap<>();
            data.put("isStarting", isStarting());
            fireEvent(eeuiConstants.Event.ITEM_CLICK, data);
        }
    }

    private void initPagerView() {
        v_body = mView.findViewById(R.id.v_body);
        v_autotext = mView.findViewById(R.id.v_autotext);
        v_autotext.setOnClickListener(this);
    }

    private void appleStyleAfterCreated() {
        setText(null);
        setTextSize(20);
    }

    /***************************************************************************************************/
    /***************************************************************************************************/
    /***************************************************************************************************/

    /**
     * 设置文本
     * @param var
     */
    @JSMethod
    public void setText(String var) {
        if (var != null) {
            mText = var;
        }
        if (v_autotext == null) {
            return;
        }
        v_autotext.setText(mText);
        v_autotext.init(getParent().getLayoutWidth());
    }

    /**
     * 添加文本
     * @param var
     */
    @JSMethod
    public void addText(String var) {
        if (var == null) {
            return;
        }
        if (v_autotext == null) {
            return;
        }
        setText(mText + var);
    }

    /**
     * 开始滚动文字
     */
    @JSMethod
    public void startScroll() {
        if (v_autotext == null) {
            return;
        }
        v_autotext.startScroll();
    }

    /**
     * 停止滚动文字
     */
    @JSMethod
    public void stopScroll() {
        if (v_autotext == null) {
            return;
        }
        v_autotext.stopScroll();
    }

    /**
     * 获取滚动状态
     */
    @JSMethod(uiThread = false)
    public boolean isStarting() {
        if (v_autotext == null) {
            return false;
        }
        return v_autotext.isStarting;
    }

    /**
     * 获取文本
     * @return
     */
    @JSMethod(uiThread = false)
    public String getText() {
        return mText;
    }

    /**
     * 设置文字滚动速度
     * @param var
     */
    @JSMethod
    public void setSpeed(float var) {
        if (v_autotext == null) {
            return;
        }
        v_autotext.setSpeed(var);
    }

    /**
     * 设置文字大小
     * @param var
     */
    @JSMethod
    public void setTextSize(Object var) {
        if (v_autotext == null) {
            return;
        }
        v_autotext.setTextSize(TypedValue.COMPLEX_UNIT_PX, eeuiScreenUtils.weexPx2dp(getInstance(), var, 24));
    }

    /**
     * 设置文字颜色
     * @param var
     */
    @JSMethod
    public void setTextColor(String var) {
        if (v_autotext == null) {
            return;
        }
        v_autotext.setTextColor(eeuiParse.parseColor(var));
    }

    /**
     * 设置文字背景颜色
     * @param var
     */
    @JSMethod
    public void setBackgroundColor(String var) {
        v_body.setBackgroundColor(eeuiParse.parseColor(var));
    }
}
