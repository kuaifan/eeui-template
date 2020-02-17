package app.eeui.framework.extend.adapter;

import android.content.Context;
import android.content.res.AssetManager;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.drawable.Drawable;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import android.text.TextUtils;
import android.util.Log;

import com.taobao.weex.WXSDKManager;
import com.taobao.weex.adapter.DrawableStrategy;
import com.taobao.weex.adapter.IDrawableLoader;

import org.apache.commons.lang3.math.NumberUtils;

import java.io.File;
import java.io.IOException;
import java.io.InputStream;

import app.eeui.framework.extend.integration.glide.Glide;
import app.eeui.framework.extend.integration.glide.RequestBuilder;
import app.eeui.framework.extend.integration.glide.load.engine.DiskCacheStrategy;
import app.eeui.framework.extend.integration.glide.request.RequestOptions;
import app.eeui.framework.extend.integration.glide.request.target.SimpleTarget;
import app.eeui.framework.extend.integration.glide.request.transition.Transition;
import app.eeui.framework.extend.module.eeuiBase;
import app.eeui.framework.extend.module.eeuiPage;
import app.eeui.framework.ui.eeui;

public class DrawableLoader implements IDrawableLoader {

    private static final String TAG = "DrawableLoader";

    private Context mContext;

    public DrawableLoader(Context context) {
        mContext = context;
    }

    @Override
    public void setDrawable(String url, DrawableTarget drawableTarget, DrawableStrategy drawableStrategy) {
        WXSDKManager.getInstance().postOnUiThread(() -> {
            String tempUrl = eeuiBase.config.verifyFile(eeuiPage.rewriteUrl(eeui.getActivityList().getLast(), handCachePageUrl(eeui.getActivityList().getLast(), url)));
            Log.d(TAG, "setDrawable: " + tempUrl);
            try {
                RequestBuilder<Drawable> myLoad;
                if (tempUrl.startsWith("file://assets/")) {
                    Bitmap myBitmap = getImageFromAssetsFile(mContext, tempUrl.substring(14));
                    myLoad = Glide.with(mContext).load(myBitmap);
                } else {
                    myLoad = Glide.with(mContext).load(tempUrl);
                }
                //
                RequestOptions myOptions = new RequestOptions().diskCacheStrategy(DiskCacheStrategy.ALL);
                myLoad.apply(myOptions).into(new SimpleTarget<Drawable>() {
                    @Override
                    public void onResourceReady(@NonNull Drawable resource, @Nullable Transition<? super Drawable> transition) {
                        drawableTarget.setDrawable(resource, true);
                    }
                });
            } catch (IllegalArgumentException ignored) {

            } catch (Exception ignored) {

            }
        }, 0);
    }

    private Bitmap getImageFromAssetsFile(Context context, String fileName) {
        Bitmap image = null;
        AssetManager am = context.getResources().getAssets();
        try {
            InputStream is = am.open(fileName);
            image = BitmapFactory.decodeStream(is);
            is.close();
        } catch (IOException e) {
            e.printStackTrace();
        }
        return image;
    }

    private String handCachePageUrl(Context context, String url) {
        if (TextUtils.isEmpty(url)) {
            return url;
        }
        File pageCache = context.getExternalFilesDir("page_cache");
        if (pageCache == null) {
            return url;
        }
        File updateFile = context.getExternalFilesDir("update");
        if (updateFile == null) {
            return url;
        }
        String cacheUrl = "file://" + pageCache.getPath() + updateFile.getPath() + "/";
        if (url.startsWith(cacheUrl)) {
            String tmpUrl = url.substring(cacheUrl.length());
            if (tmpUrl.contains("/") && NumberUtils.isCreatable(tmpUrl.substring(0, tmpUrl.indexOf("/")))) {
                url = "root:/" + tmpUrl.substring(tmpUrl.indexOf("/"));
            }
        }
        return url;
    }
}
