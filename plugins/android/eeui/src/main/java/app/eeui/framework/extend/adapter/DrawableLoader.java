package app.eeui.framework.extend.adapter;

import android.content.Context;
import android.content.res.AssetManager;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.drawable.Drawable;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;
import android.util.Log;

import com.taobao.weex.WXSDKManager;
import com.taobao.weex.adapter.DrawableStrategy;
import com.taobao.weex.adapter.IDrawableLoader;

import java.io.IOException;
import java.io.InputStream;

import app.eeui.framework.extend.integration.glide.Glide;
import app.eeui.framework.extend.integration.glide.RequestBuilder;
import app.eeui.framework.extend.integration.glide.load.engine.DiskCacheStrategy;
import app.eeui.framework.extend.integration.glide.request.RequestOptions;
import app.eeui.framework.extend.integration.glide.request.target.SimpleTarget;
import app.eeui.framework.extend.integration.glide.request.transition.Transition;
import app.eeui.framework.extend.module.eeuiBase;
import app.eeui.framework.extend.module.eeuiHtml;
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
            String tempUrl = eeuiBase.config.verifyFile(eeuiHtml.repairUrl(eeui.getActivityList().getLast(), url));
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
}
