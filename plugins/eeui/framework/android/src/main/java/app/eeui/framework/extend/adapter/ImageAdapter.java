package app.eeui.framework.extend.adapter;

import android.content.Context;
import android.content.res.AssetManager;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.drawable.Drawable;
import android.net.Uri;
import android.os.Handler;
import android.os.Looper;
import androidx.annotation.Nullable;
import android.text.TextUtils;
import android.util.Log;
import android.widget.ImageView;

import com.squareup.picasso.Callback;
import com.squareup.picasso.Picasso;
import com.taobao.weex.WXEnvironment;
import com.taobao.weex.WXSDKInstance;
import com.taobao.weex.WXSDKManager;
import com.taobao.weex.adapter.IWXImgLoaderAdapter;
import com.taobao.weex.common.WXImageStrategy;
import com.taobao.weex.dom.WXImageQuality;

import org.apache.commons.lang3.math.NumberUtils;

import java.io.File;
import java.io.IOException;
import java.io.InputStream;

import app.eeui.framework.extend.integration.glide.Glide;
import app.eeui.framework.extend.integration.glide.RequestBuilder;
import app.eeui.framework.extend.integration.glide.load.DataSource;
import app.eeui.framework.extend.integration.glide.load.engine.DiskCacheStrategy;
import app.eeui.framework.extend.integration.glide.load.engine.GlideException;
import app.eeui.framework.extend.integration.glide.request.RequestListener;
import app.eeui.framework.extend.integration.glide.request.RequestOptions;
import app.eeui.framework.extend.integration.glide.request.target.Target;
import app.eeui.framework.extend.module.eeuiBase;
import app.eeui.framework.extend.module.eeuiPage;

public class ImageAdapter implements IWXImgLoaderAdapter {

    public static String imageEngine = "";

    private static final String TAG = "ImageAdapter";

    private Handler mHandler = new Handler();

    public ImageAdapter() {
    }

    @Override
    public void setImage(String url, ImageView view, WXImageQuality quality, WXImageStrategy strategy) {
        Runnable runnable = () -> {
            if (view == null || view.getLayoutParams() == null) {
                return;
            }
            if (TextUtils.isEmpty(url)) {
                view.setImageBitmap(null);
                return;
            }
            loadImage(0, url, view, strategy);
        };
        if (Thread.currentThread() == Looper.getMainLooper().getThread()) {
            runnable.run();
        } else {
            WXSDKManager.getInstance().postOnUiThread(runnable, 0);
        }
    }

    /**
     * 加载图片程序
     *
     * @param loadNum
     * @param url
     * @param view
     * @param strategy
     */
    private void loadImage(int loadNum, String url, ImageView view, WXImageStrategy strategy) {
        if (view.getLayoutParams().width <= 0 || view.getLayoutParams().height <= 0) {
            if (loadNum < 5) {
                mHandler.postDelayed(() -> view.post(() -> loadImage(loadNum + 1, url, view, strategy)), 200);
            }
            return;
        }
        //
        if (view.getContext() == null) {
            return;
        }
        String tempUrl = eeuiBase.config.verifyFile(eeuiPage.rewriteUrl(view, handCachePageUrl(view.getContext(), url)));
        Log.d(TAG, "loadImage: " + tempUrl);
        //
        if (!TextUtils.isEmpty(strategy.placeHolder)) {
            String placeHolder = eeuiBase.config.verifyFile(eeuiPage.rewriteUrl(view, handCachePageUrl(view.getContext(), strategy.placeHolder)));
            Picasso.Builder builder = new Picasso.Builder(WXEnvironment.getApplication());
            Picasso picasso = builder.build();
            picasso.load(Uri.parse(placeHolder)).into(view);
            view.setTag(strategy.placeHolder.hashCode(), picasso);
        }
        //
        try {
            if (imageEngine.equals("picasso") && !tempUrl.startsWith("data:image/")) {
                if (tempUrl.startsWith("file://assets/")) {
                    tempUrl = "file:///android_asset/" + tempUrl.substring(14);
                }
                Picasso.with(view.getContext()).load(tempUrl).into(view, new Callback() {
                    @Override
                    public void onSuccess() {
                        if (strategy.getImageListener() != null) {
                            strategy.getImageListener().onImageFinish(url, view, true, null);
                        }
                        recordImgLoadResult(strategy.instanceId, true, null);

                        if (!TextUtils.isEmpty(strategy.placeHolder)) {
                            ((Picasso) view.getTag(strategy.placeHolder.hashCode())).cancelRequest(view);
                        }
                    }

                    @Override
                    public void onError() {
                        if (strategy.getImageListener() != null) {
                            strategy.getImageListener().onImageFinish(url, view, false, null);
                        }
                        recordImgLoadResult(strategy.instanceId, false, null);
                    }
                });
            } else {
                RequestBuilder<Drawable> myLoad;
                if (tempUrl.startsWith("file://assets/")) {
                    Bitmap myBitmap = getImageFromAssetsFile(view.getContext(), tempUrl.substring(14));
                    myLoad = Glide.with(view.getContext()).load(myBitmap);
                } else {
                    myLoad = Glide.with(view.getContext()).load(tempUrl);
                }
                //
                RequestOptions myOptions = new RequestOptions().diskCacheStrategy(DiskCacheStrategy.ALL);
                myLoad.apply(myOptions).listener(new RequestListener<Drawable>() {
                    @Override
                    public boolean onLoadFailed(@Nullable GlideException e, Object model, Target<Drawable> target, boolean isFirstResource) {
                        if (strategy.getImageListener() != null) {
                            strategy.getImageListener().onImageFinish(url, view, false, null);
                        }
                        recordImgLoadResult(strategy.instanceId, false, null);
                        return false;
                    }

                    @Override
                    public boolean onResourceReady(Drawable resource, Object model, Target<Drawable> target, DataSource dataSource, boolean isFirstResource) {
                        if (strategy.getImageListener() != null) {
                            strategy.getImageListener().onImageFinish(url, view, true, null);
                        }
                        recordImgLoadResult(strategy.instanceId, true, null);

                        if (!TextUtils.isEmpty(strategy.placeHolder)) {
                            ((Picasso) view.getTag(strategy.placeHolder.hashCode())).cancelRequest(view);
                        }
                        return false;
                    }
                }).into(view);
            }
        } catch (IllegalArgumentException ignored) {

        } catch (Exception ignored) {

        }
    }

    private void recordImgLoadResult(String instanceId, boolean succeed, String errorCode) {
        WXSDKInstance instance = WXSDKManager.getInstance().getAllInstanceMap().get(instanceId);
        if (null == instance || instance.isDestroy()) {
            return;
        }
        instance.getApmForInstance().actionLoadImgResult(succeed, errorCode);
    }

    private Bitmap getImageFromAssetsFile(Context context, String fileName)
    {
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
