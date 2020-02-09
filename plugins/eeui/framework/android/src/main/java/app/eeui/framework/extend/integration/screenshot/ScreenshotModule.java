package app.eeui.framework.extend.integration.screenshot;

import android.graphics.Bitmap;
import android.view.View;

import com.taobao.weex.bridge.JSCallback;

import java.io.File;
import java.util.HashMap;
import java.util.Map;

import app.eeui.framework.extend.integration.screenshot.util.ScreenshotPicture;
import app.eeui.framework.extend.integration.screenshot.util.ScreenshotSDCard;
import app.eeui.framework.ui.eeui;

public class ScreenshotModule {

    public static void shots(View view, JSCallback callback) {
        Map<String, Object> data = new HashMap<>();
        if (view == null) {
            data.put("status", "error");
            data.put("msg", "截图失败");
            data.put("path", "");
            callback.invoke(data);
            return;
        }
        Bitmap bitmap = viewConversionBitmap(view);
        if (bitmap == null) {
            data.put("status", "error");
            data.put("msg", "截图失败");
            data.put("path", "");
            callback.invoke(data);
            return;
        }
        String dir = ScreenshotSDCard.getBasePath(eeui.getApplication()) + "/shots/";
        File f = new File(dir);
        if (f.exists()) {
            f.delete();
        }
        f.mkdirs();
        ScreenshotPicture.saveImageToSDCard(dir + "shots.png", bitmap);
        data.put("status", "success");
        data.put("msg", "");
        data.put("path", dir + "shots.png");
        callback.invoke(data);
    }

    private static Bitmap viewConversionBitmap(View view) {
        if (view == null) {
            return null;
        }
        final boolean drawingCacheEnabled = true;
        view.setDrawingCacheEnabled(drawingCacheEnabled);
        view.buildDrawingCache(drawingCacheEnabled);
        final Bitmap drawingCache = view.getDrawingCache();
        Bitmap bitmap;
        if (drawingCache != null) {
            bitmap = Bitmap.createBitmap(drawingCache);
            view.setDrawingCacheEnabled(false);
        } else {
            bitmap = null;
        }
        return bitmap;
    }
}
