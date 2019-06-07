package app.eeui.framework.extend.adapter;

import android.content.Context;
import android.content.res.AssetManager;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.drawable.Drawable;
import android.os.Handler;
import android.os.Looper;
import android.support.annotation.Nullable;
import android.text.TextUtils;
import android.widget.ImageView;

import app.eeui.framework.activity.PageActivity;
import app.eeui.framework.extend.bean.PageBean;
import app.eeui.framework.extend.integration.glide.Glide;
import app.eeui.framework.extend.integration.glide.RequestBuilder;
import app.eeui.framework.extend.integration.glide.load.DataSource;
import app.eeui.framework.extend.integration.glide.load.engine.DiskCacheStrategy;
import app.eeui.framework.extend.integration.glide.load.engine.GlideException;
import app.eeui.framework.extend.integration.glide.request.RequestListener;
import app.eeui.framework.extend.integration.glide.request.RequestOptions;
import app.eeui.framework.extend.integration.glide.request.target.Target;
import app.eeui.framework.extend.module.eeuiBase;
import app.eeui.framework.extend.module.eeuiHtml;

import com.taobao.weex.WXSDKManager;
import com.taobao.weex.adapter.IWXImgLoaderAdapter;
import com.taobao.weex.common.WXImageStrategy;
import com.taobao.weex.dom.WXImageQuality;

import java.io.IOException;
import java.io.InputStream;

public class ImageAdapter implements IWXImgLoaderAdapter {

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
        if (url.contains("/./")) {
            url = url.replaceAll("/\\./", "/");
        }
        String finalUrl = url;
        //
        if (view.getLayoutParams().width <= 0 || view.getLayoutParams().height <= 0) {
            if (loadNum < 5) {
                mHandler.postDelayed(() -> view.post(() -> loadImage(loadNum + 1, finalUrl, view, strategy)), 200);
            }
            return;
        }
        //
        String tempUrl = finalUrl;
        if (tempUrl.startsWith("//")) {
            tempUrl = "http:" + finalUrl;
        } else if (!tempUrl.startsWith("http") && !tempUrl.startsWith("ftp:") && !tempUrl.startsWith("file:") && !tempUrl.startsWith("data:image/")) {
            if (view.getContext() instanceof PageActivity) {
                PageBean mPageBean = ((PageActivity) view.getContext()).getPageInfo();
                if (mPageBean != null) {
                    tempUrl = eeuiHtml.repairUrl(tempUrl, mPageBean.getUrl());
                }
            }
        }
        //
        if (view.getContext() == null) {
            return;
        }
        //
        tempUrl = eeuiBase.config.verifyFile(tempUrl);
        try {
            RequestBuilder<Drawable> myLoad;
            if (tempUrl.startsWith("file://assets/")) {
                Bitmap myBitmap = getImageFromAssetsFile(view.getContext(), tempUrl.substring(14));
                myLoad = Glide.with(view.getContext()).load(myBitmap);
            }else if (tempUrl.startsWith("file:///assets/")) {
                Bitmap myBitmap = getImageFromAssetsFile(view.getContext(), tempUrl.substring(15));
                myLoad = Glide.with(view.getContext()).load(myBitmap);
            }else{
                myLoad = Glide.with(view.getContext()).load(tempUrl);
            }
            //
            RequestOptions myOptions = new RequestOptions().diskCacheStrategy(DiskCacheStrategy.ALL);
            myLoad.apply(myOptions).listener(new RequestListener<Drawable>() {
                @Override
                public boolean onLoadFailed(@Nullable GlideException e, Object model, Target<Drawable> target, boolean isFirstResource) {
                    if (strategy.getImageListener() != null) {
                        strategy.getImageListener().onImageFinish(finalUrl, view, false, null);
                    }
                    return false;
                }

                @Override
                public boolean onResourceReady(Drawable resource, Object model, Target<Drawable> target, DataSource dataSource, boolean isFirstResource) {
                    if (strategy.getImageListener() != null) {
                        strategy.getImageListener().onImageFinish(finalUrl, view, true, null);
                    }
                    return false;
                }
            }).into(view);
        } catch (IllegalArgumentException ignored) {

        } catch (Exception ignored) {

        }
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
}
