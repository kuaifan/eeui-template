package app.eeui.framework.extend.view.loading;

import android.app.Activity;
import android.content.Context;
import android.content.DialogInterface;
import android.graphics.Color;
import android.os.Handler;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.Window;
import android.widget.FrameLayout;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.alibaba.fastjson.JSONObject;
import com.taobao.weex.bridge.JSCallback;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Timer;
import java.util.TimerTask;

import app.eeui.framework.R;
import app.eeui.framework.activity.PageActivity;
import app.eeui.framework.extend.module.utilcode.util.SizeUtils;
import app.eeui.framework.extend.module.eeuiCommon;
import app.eeui.framework.extend.module.eeuiDialog;
import app.eeui.framework.extend.module.eeuiJson;
import app.eeui.framework.extend.view.loading.spinkit.SpinKitView;


/**
 * Created by Administrator on 2017/3/16.
 */

public class LoadingDialog extends eeuiDialog {

    private final static String TAG = "LoadingDialog";

    private View mView;
    private LinearLayout v_main;
    private FrameLayout v_body;
    private TextView v_title;
    private static Handler mHandler = new Handler();
    private static List<loadBean> mLoadBean = new ArrayList<>();
    private static Map<String, String> identifyLists = new HashMap<>();

    public static String init(Context context, String obj, JSCallback callback) {
        JSONObject json = eeuiJson.parseObject(obj);
        if (json.size() == 0 && obj != null && obj.equals("null")) {
            json.put("title", String.valueOf(obj));
        }
        String loadName = eeuiCommon.randomString(8);
        //
        LoadingDialog mLoadingCustom;
        mLoadingCustom = new LoadingDialog(context, eeuiJson.getBoolean(json, "cancelable", true), dialogInterface -> {
            if (callback != null) {
                callback.invoke(null);
            }
            close(loadName, true);
        });
        if (mLoadingCustom.show(json)) {
            loadBean temp = new loadBean();
            temp.setName(loadName);
            temp.setLoading(mLoadingCustom);
            mLoadBean.add(temp);
            //
            int duration = eeuiJson.getInt(json, "duration");
            if (duration > 0) {
                mHandler.postDelayed(()-> close(loadName), duration);
            }else if (context instanceof PageActivity) {
                Timer timer = new Timer();
                identifyLists.put(loadName, ((PageActivity) context).identify);
                timer.schedule(new closeTask((PageActivity) context, timer, loadName), 3000, 3000);
            }
            //
            return loadName;
        }else{
            return "";
        }
    }

    private static class closeTask extends TimerTask {

        PageActivity context;
        Timer timer;
        String loadName;

        closeTask(PageActivity var1, Timer var2, String var3) {
            context = var1;
            timer = var2;
            loadName = var3;
        }

        @Override
        public void run() {
            loadBean temp = null;
            for (int i = 0; i < mLoadBean.size(); i++) {
                temp = mLoadBean.get(i);
                if (loadName.equals(temp.getName())) {
                    break;
                }
            }
            if (temp == null) {
                timer.cancel();
                return;
            }
            if (!context.identify.equals(identifyLists.get(loadName))) {
                timer.cancel();
                temp.getLoading().cancel();
            }
        }
    }

    public static void close(String var) {
        close(var, false);
    }

    public static void close(String var, boolean onlyRemoveData) {
        if (mLoadBean.size() > 0) {
            for (int i = 0; i < mLoadBean.size(); i++) {
                loadBean temp = mLoadBean.get(i);
                if (temp != null) {
                    if (var == null) {
                        if (!onlyRemoveData) {
                            try { temp.getLoading().cancel(); } catch (IllegalArgumentException ignored) { }
                        }
                        mLoadBean.remove(i);
                        break;
                    }else{
                        if (temp.getName().equals(var)) {
                            if (!onlyRemoveData) {
                                try { temp.getLoading().cancel(); } catch (IllegalArgumentException ignored) { }
                            }
                            mLoadBean.remove(i);
                            break;
                        }
                    }
                }
            }
        }
    }

    public static void closeAll() {
        if (mLoadBean.size() > 0) {
            for (int i = 0; i < mLoadBean.size(); i++) {
                loadBean temp = mLoadBean.get(i);
                if (temp != null) {
                    try { temp.getLoading().cancel(); } catch (IllegalArgumentException ignored) { }
                }
            }
            mLoadBean = new ArrayList<>();
        }
    }

    static class loadBean {

        private String name;
        private LoadingDialog loading;

        public String getName() {
            return name;
        }

        public void setName(String name) {
            this.name = name;
        }

        public LoadingDialog getLoading() {
            return loading;
        }

        public void setLoading(LoadingDialog loading) {
            this.loading = loading;
        }
    }

    /***********************************************************************************************/
    /***********************************************************************************************/
    /***********************************************************************************************/

    public LoadingDialog(Context context, boolean cancelable, DialogInterface.OnCancelListener cancelListener) {
        super(context, cancelable, cancelListener);
        initView(context);
    }

    public LoadingDialog(Context context, int themeResId) {
        super(context, themeResId);
        initView(context);
    }

    public LoadingDialog(Context context) {
        super(context);
        initView(context);
    }

    public LoadingDialog(Activity context) {
        super(context);
        initView(context);
    }

    public LoadingDialog(Context context, float alpha, int gravity) {
        super(context, alpha, gravity);
        initView(context);
    }

    private void initView(Context context) {
        mView = LayoutInflater.from(context).inflate(R.layout.dialog_loading, null);
        setContentView(mView);
        //
        v_main = mView.findViewById(R.id.v_main);
        v_body = mView.findViewById(R.id.v_body);
        v_title = mView.findViewById(R.id.v_title);
    }

    public boolean show(JSONObject obj) {
        int style = R.style.SpinKitView_ThreeBounce;
        switch (eeuiJson.getString(obj, "style").toLowerCase()) {
            case "rotatingplane":
                style = R.style.SpinKitView_RotatingPlane;
                break;
            case "doublebounce":
                style = R.style.SpinKitView_DoubleBounce;
                break;
            case "wave":
                style = R.style.SpinKitView_Wave;
                break;
            case "wanderingcubes":
                style = R.style.SpinKitView_WanderingCubes;
                break;
            case "pulse":
                style = R.style.SpinKitView_Pulse;
                break;
            case "chasingdots":
                style = R.style.SpinKitView_ChasingDots;
                break;
            case "threebounce":
                style = R.style.SpinKitView_ThreeBounce;
                break;
            case "circle":
                style = R.style.SpinKitView_Circle;
                break;
            case "cubegrid":
                style = R.style.SpinKitView_CubeGrid;
                break;
            case "fadingcircle":
                style = R.style.SpinKitView_FadingCircle;
                break;
            case "foldingcube":
                style = R.style.SpinKitView_FoldingCube;
                break;
            case "rotatingcircle":
                style = R.style.SpinKitView_RotatingCircle;
                break;
        }
        SpinKitView view = new SpinKitView(getContext(), null, R.style.SpinKitView, style);
        view.setColor(Color.parseColor(eeuiJson.getString(obj, "styleColor", "#5F97F1")));
        v_body.addView(view);
        //
        float amount = eeuiJson.getFloat(obj, "amount", -1f);
        if (amount != -1f) {
            Window window = this.getWindow();
            if (window != null) {
                window.setDimAmount(amount);
            }
        }
        //
        String title = eeuiJson.getString(obj, "title");
        int titleSize = eeuiJson.getInt(obj, "titleSize", 16);
        String titleColor = eeuiJson.getString(obj, "titleColor", "#7a583e");
        if (!title.isEmpty()) {
            v_main.setPadding(SizeUtils.dp2px(36), SizeUtils.dp2px(18), SizeUtils.dp2px(36), SizeUtils.dp2px(18));
            v_title.setText(title);
            v_title.setTextSize(titleSize);
            v_title.setTextColor(Color.parseColor(titleColor));
            v_title.setVisibility(View.VISIBLE);
        }
        //
        try {
            super.show();
            return true;
        }catch (RuntimeException ignored) {
            return false;
        }catch (Exception ignored) {
            return false;
        }
    }
}
