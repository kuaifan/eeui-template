package app.eeui.framework.activity;

import android.Manifest;
import android.annotation.SuppressLint;
import android.content.Intent;
import android.os.Bundle;
import android.provider.MediaStore;
import android.text.TextUtils;
import android.view.MotionEvent;
import android.view.SurfaceView;
import android.view.View;
import android.widget.TextView;

import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;


import com.google.zxing.BarcodeFormat;
import com.google.zxing.DecodeHintType;
import com.google.zxing.Result;
import com.taobao.weex.bridge.JSCallback;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Vector;

import app.eeui.framework.extend.integration.iconify.widget.IconTextView;
import app.eeui.framework.extend.module.eeuiCommon;
import app.eeui.framework.extend.module.utilcode.util.PermissionUtils;
import app.eeui.framework.extend.utils.ScanUriUtils;
import app.eeui.zxing.CaptureHelper;
import app.eeui.zxing.DecodeFormatManager;
import app.eeui.zxing.OnCaptureCallback;
import app.eeui.zxing.ViewfinderView;

import app.eeui.framework.R;
import app.eeui.zxing.util.CodeUtils;

public class ScanActivity extends AppCompatActivity implements OnCaptureCallback {

    public static JSCallback mJSCallback;

    private CaptureHelper mCaptureHelper;

    private boolean continuous = false;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_scan);
        initUI();
        //
        if (mJSCallback != null) {
            Map<String, Object> retData = new HashMap<>();
            retData.put("pageName", "scanPage");
            retData.put("status", "create");
            mJSCallback.invokeAndKeepAlive(retData);
        }
    }

    /**
     * 初始化
     */
    @SuppressLint("SetTextI18n")
    public void initUI() {
        SurfaceView surfaceView = findViewById(R.id.surfaceView);
        ViewfinderView viewfinderView = findViewById(R.id.viewfinderView);
        TextView tvTitle = findViewById(R.id.tvTitle);
        //
        String title = getIntent().getStringExtra("title");
        String desc = getIntent().getStringExtra("desc");
        continuous = getIntent().getBooleanExtra("continuous", false);
        tvTitle.setText(TextUtils.isEmpty(title) ? "" : title);
        viewfinderView.setLabelText(TextUtils.isEmpty(desc) ? "" : desc);
        eeuiCommon.setMargins(findViewById(R.id.llTop), 0, eeuiCommon.getStatusBarHeight(this), 0, 0);
        findViewById(R.id.iconBack).setOnClickListener(v -> finish());
        //
        mCaptureHelper = new CaptureHelper(this, surfaceView, viewfinderView, null, true);
        mCaptureHelper.setOnCaptureCallback(this);
        mCaptureHelper.onCreate();
        mCaptureHelper.playBeep(true)
                .vibrate(true)
                .continuousScan(continuous)
                .fullScreenScan(true)
                .supportLuminanceInvert(true);
        //
        IconTextView iconFlash = findViewById(R.id.iconFlash);
        iconFlash.setOnClickListener(v -> {
            if (mCaptureHelper != null && mCaptureHelper.getCameraManager() != null) {
                mCaptureHelper.getCameraManager().setTorch(!iconFlash.isSelected());
            }
        });
        mCaptureHelper.getCameraManager().setOnSensorListener((torch, tooDark, ambientLightLux) -> {
            if (tooDark) {
                if (iconFlash.getVisibility() != View.VISIBLE) {
                    iconFlash.setVisibility(View.VISIBLE);
                }
            } else if (!torch) {
                if (iconFlash.getVisibility() == View.VISIBLE) {
                    iconFlash.setVisibility(View.INVISIBLE);
                }
            }
        });
        mCaptureHelper.getCameraManager().setOnTorchListener(torch -> {
            iconFlash.setSelected(torch);
            if (torch) {
                iconFlash.setText("{tb-flashlight-open}");
            } else {
                iconFlash.setText("{tb-flashlight-close}");
            }
            if (mJSCallback != null) {
                Map<String, Object> retData = new HashMap<>();
                retData.put("pageName", "scanPage");
                retData.put("status", torch ? "openLight" : "offLight");
                mJSCallback.invokeAndKeepAlive(retData);
            }
        });
        //
        findViewById(R.id.iconPic).setOnClickListener(v -> checkExternalStoragePermissions());
    }

    @Override
    public void onResume() {
        super.onResume();
        if (mCaptureHelper != null) {
            mCaptureHelper.onResume();
        }
    }

    @Override
    public void onPause() {
        super.onPause();
        if (mCaptureHelper != null) {
            mCaptureHelper.onPause();
        }
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        if (mCaptureHelper != null) {
            mCaptureHelper.onDestroy();
        }
        if (mJSCallback != null) {
            Map<String, Object> retData = new HashMap<>();
            retData.put("pageName", "scanPage");
            retData.put("status", "destroy");
            mJSCallback.invoke(retData);
            mJSCallback = null;
        }
    }

    @Override
    public boolean onTouchEvent(MotionEvent event) {
        mCaptureHelper.onTouchEvent(event);
        return super.onTouchEvent(event);
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        if (resultCode == RESULT_OK && data != null) {
            if (requestCode == 0X302) {
                parsePhoto(data);
            }
        }
    }

    /**
     * 接收扫码结果回调
     * @param format 类型
     * @param result 扫码结果
     * @return 返回true表示拦截，将不自动执行后续逻辑，为false表示不拦截，默认不拦截
     */
    @Override
    public boolean onResultCallback(BarcodeFormat format, String result) {
        if (mJSCallback != null) {
            Result newResult = new Result(result, null, null, format);
            Map<String, Object> retData = new HashMap<>();
            retData.put("status", "success");
            retData.put("source", "camera");
            retData.put("result", newResult);
            retData.put("format", format.name());
            retData.put("text", result);
            mJSCallback.invokeAndKeepAlive(retData);
        }
        return false;
    }

    /**
     * 选择相册结果
     * @param data
     */
    private void parsePhoto(Intent data){
        String path = ScanUriUtils.getImagePath(this, data);
        if (TextUtils.isEmpty(path)) {
            return;
        }
        //异步解析
        new Thread(() -> {
            Result result = parseCode(path);
            runOnUiThread(() -> {
                if (mJSCallback != null) {
                    Map<String, Object> retData = new HashMap<>();
                    retData.put("status", "success");
                    retData.put("source", "photo");
                    retData.put("result", result);
                    retData.put("format", result.getBarcodeFormat().name());
                    retData.put("text", result.getText());
                    mJSCallback.invokeAndKeepAlive(retData);
                }
                if (!continuous) {
                    finish();
                }
            });
        }).start();
    }

    /**
     * 解析一维码/二维码图片
     * @param bitmapPath
     * @return
     */
    public static Result parseCode(String bitmapPath){
        Map<DecodeHintType,Object> hints = new HashMap<>();
        //添加可以解析的编码类型
        Vector<BarcodeFormat> decodeFormats = new Vector<>();
        decodeFormats.addAll(DecodeFormatManager.ONE_D_FORMATS);
        decodeFormats.addAll(DecodeFormatManager.QR_CODE_FORMATS);
        decodeFormats.addAll(DecodeFormatManager.DATA_MATRIX_FORMATS);
        decodeFormats.addAll(DecodeFormatManager.AZTEC_FORMATS);
        decodeFormats.addAll(DecodeFormatManager.PDF417_FORMATS);

        hints.put(DecodeHintType.TRY_HARDER,Boolean.TRUE);
        hints.put(DecodeHintType.POSSIBLE_FORMATS, decodeFormats);
        return CodeUtils.parseCodeResult(bitmapPath,hints);
    }

    /**
     * 选择相册
     */
    @SuppressLint("WrongConstant")
    private void checkExternalStoragePermissions() {
        PermissionUtils.permission(Manifest.permission.READ_EXTERNAL_STORAGE, Manifest.permission.WRITE_EXTERNAL_STORAGE)
                .rationale(shouldRequest -> PermissionUtils.showRationaleDialog(ScanActivity.this, shouldRequest, "读写"))
                .callback(new PermissionUtils.FullCallback() {
                    @Override
                    public void onGranted(List<String> permissionsGranted) {
                        Intent pickIntent = new Intent(Intent.ACTION_PICK, MediaStore.Images.Media.EXTERNAL_CONTENT_URI);
                        pickIntent.setDataAndType(MediaStore.Images.Media.EXTERNAL_CONTENT_URI, "image/*");
                        startActivityForResult(pickIntent, 0X302);
                    }

                    @Override
                    public void onDenied(List<String> permissionsDeniedForever, List<String> permissionsDenied) {
                        if (!permissionsDeniedForever.isEmpty()) {
                            PermissionUtils.showOpenAppSettingDialog(ScanActivity.this, "读写");
                        }
                    }
                }).request();
    }
}
