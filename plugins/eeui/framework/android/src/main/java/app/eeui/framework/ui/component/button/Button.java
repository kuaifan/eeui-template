package app.eeui.framework.ui.component.button;

import android.app.Activity;
import android.content.Context;
import androidx.annotation.NonNull;
import android.util.TypedValue;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import com.alibaba.fastjson.JSONObject;
import com.taobao.weex.WXSDKInstance;
import com.taobao.weex.annotation.JSMethod;
import com.taobao.weex.dom.WXAttr;
import com.taobao.weex.ui.action.BasicComponentData;
import com.taobao.weex.ui.component.WXVContainer;

import java.util.HashMap;
import java.util.Map;

import app.eeui.framework.R;
import app.eeui.framework.extend.integration.iconify.widget.IconTextView;
import app.eeui.framework.extend.module.eeuiCommon;
import app.eeui.framework.extend.module.eeuiConstants;
import app.eeui.framework.extend.module.eeuiJson;
import app.eeui.framework.extend.module.eeuiParse;
import app.eeui.framework.extend.module.eeuiScreenUtils;

/**
 * Created by WDM on 2018/3/13.
 */
public class Button extends WXVContainer<ViewGroup> implements View.OnClickListener {

    private static final String TAG = "Button";

    private View mView;

    private boolean isDisabled;
    private boolean isLoading;

    private IconTextView v_loading;
    private View v_unclick;
    private TextView v_text;

    private int text_color = 0xFFFFFFFF;

    public Button(WXSDKInstance instance, WXVContainer parent, BasicComponentData basicComponentData) {
        super(instance, parent, basicComponentData);
        //
        String modelVal = String.valueOf(getComponentValue("model"));
        Map<String, Object> addStyle = new HashMap<>();
        if (getComponentValue("borderRadius") == null) {
            addStyle.put("borderRadius", "8px");
        }
        if (getComponentValue("borderWidth") == null) {
            addStyle.put("borderWidth", "0px");
        }
        if (getComponentValue("backgroundColor") == null) {
            addStyle.put("backgroundColor", modelToColor(modelVal));
        }
        if (modelVal.toLowerCase().equals("white")) {
            text_color = 0xFF000000;
        }
        basicComponentData.addStyle(addStyle, true);
    }

    @Override
    protected ViewGroup initComponentHostView(@NonNull Context context) {
        mView = ((Activity) context).getLayoutInflater().inflate(R.layout.layout_eeui_button, null);
        initPagerView();
        //
        if (getEvents().contains(eeuiConstants.Event.READY)) {
            fireEvent(eeuiConstants.Event.READY, null);
        }
        //
        return (ViewGroup) mView;
    }

    private void initPagerView() {
        v_loading = mView.findViewById(R.id.v_loading);
        v_unclick = mView.findViewById(R.id.v_unclick);
        v_text = mView.findViewById(R.id.v_text);
        mView.findViewById(R.id.l_click).setOnClickListener(this);
        updateStyle();
    }

    @Override
    public void onClick(View v) {
        if (v.getId() == R.id.l_click) {
            if (!isDisabled && !isLoading && getEvents().contains(eeuiConstants.Event.CLICK)) {
                fireEvent(eeuiConstants.Event.CLICK, null);
            }
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

            case "text":
                setText(val);
                return true;

            case "color":
                setTextColor(val);
                return true;

            case "fontSize":
                setTextSize(val);
                return true;

            case "disabled":
                setDisabled(val);
                return true;

            case "loading":
                setLoading(val);
                return true;

            default:
                return false;
        }
    }

    private Object getComponentValue(String name) {
        Object val = getBasicComponentData().getStyles().get(name);
        if (val != null) {
            return val;
        }
        WXAttr mWXAttr = getBasicComponentData().getAttrs();
        val = mWXAttr.get(name);
        if (val != null) {
            return val;
        }
        JSONObject json = eeuiJson.parseObject(eeuiParse.parseStr(mWXAttr.get("eeui"), ""));
        return json.get(name);
    }

    private String modelToColor(String model) {
        String button_backgroundColor = "#3EB4FF";
        switch (model.toLowerCase()) {
            case "red":
                button_backgroundColor = "#f44336";
                break;

            case "green":
                button_backgroundColor = "#4caf50";
                break;

            case "blue":
                button_backgroundColor = "#2196f3";
                break;

            case "pink":
                button_backgroundColor = "#e91e63";
                break;

            case "yellow":
                button_backgroundColor = "#ffeb3b";
                break;

            case "orange":
                button_backgroundColor = "#ff9800";
                break;

            case "gray":
                button_backgroundColor = "#9e9e9e";
                break;

            case "black":
                button_backgroundColor = "#000000";
                break;

            case "white":
                button_backgroundColor = "#ffffff";
                break;
        }
        return button_backgroundColor;
    }

    private void updateStyle() {
        int textColor =  text_color;
        if (isDisabled) {
            textColor = eeuiParse.parseColor("#ffffff");
        }
        v_loading.setVisibility(isLoading ? View.VISIBLE : View.GONE);
        v_unclick.setVisibility(isLoading || isDisabled ? View.VISIBLE : View.GONE);
        //
        v_text.setTextColor(textColor);
    }

    /***************************************************************************************************/
    /***************************************************************************************************/
    /***************************************************************************************************/

    /**
     * 设置文字
     * @param var
     */
    @JSMethod
    public void setText(Object var) {
        v_text.setText(eeuiParse.parseStr(var));
    }

    /**
     * 设置文字颜色
     * @param var
     */
    @JSMethod
    public void setTextColor(Object var) {
        text_color = eeuiParse.parseColor(eeuiParse.parseStr(var));
        updateStyle();
    }

    /**
     * 设置文字大小
     * @param var
     */
    @JSMethod
    public void setTextSize(Object var) {
        v_text.setTextSize(TypedValue.COMPLEX_UNIT_PX, eeuiScreenUtils.weexPx2dp(getInstance(), var, 24));
    }

    /**
     * 设置是否禁用
     * @param var
     */
    @JSMethod
    public void setDisabled(Object var) {
        isDisabled = eeuiParse.parseBool(var, false);
        updateStyle();
    }

    /**
     * 设置加载中状态
     * @param var
     */
    @JSMethod
    public void setLoading(Object var) {
        isLoading = eeuiParse.parseBool(var, false);
        updateStyle();
    }
}
