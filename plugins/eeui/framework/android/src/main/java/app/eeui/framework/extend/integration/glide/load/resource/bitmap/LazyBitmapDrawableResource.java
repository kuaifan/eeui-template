package app.eeui.framework.extend.integration.glide.load.resource.bitmap;

import android.content.Context;
import android.content.res.Resources;
import android.graphics.Bitmap;
import android.graphics.drawable.BitmapDrawable;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import app.eeui.framework.extend.integration.glide.Glide;
import app.eeui.framework.extend.integration.glide.load.engine.Initializable;
import app.eeui.framework.extend.integration.glide.load.engine.Resource;
import app.eeui.framework.extend.integration.glide.load.engine.bitmap_recycle.BitmapPool;
import app.eeui.framework.extend.integration.glide.util.Preconditions;

/**
 * Lazily allocates a {@link android.graphics.drawable.BitmapDrawable} from a given
 * {@link android.graphics.Bitmap} on the first call to {@link #get()}.
 */
public final class LazyBitmapDrawableResource implements Resource<BitmapDrawable>,
    Initializable {

  private final Resources resources;
  private final Resource<Bitmap> bitmapResource;

  /**
   * @deprecated Use {@link #obtain(Resources, Resource)} instead, it can be unsafe to extract
   * {@link Bitmap}s from their wrapped {@link Resource}.
   */
  @Deprecated
  public static LazyBitmapDrawableResource obtain(Context context, Bitmap bitmap) {
    return
        (LazyBitmapDrawableResource)
            obtain(
                context.getResources(),
                BitmapResource.obtain(bitmap, Glide.get(context).getBitmapPool()));
  }

  /**
   * @deprecated Use {@link #obtain(Resources, Resource)} instead, it can be unsafe to extract
   * {@link Bitmap}s from their wrapped {@link Resource}.
   */
  @Deprecated
  public static LazyBitmapDrawableResource obtain(Resources resources, BitmapPool bitmapPool,
      Bitmap bitmap) {
    return
        (LazyBitmapDrawableResource) obtain(resources, BitmapResource.obtain(bitmap, bitmapPool));
  }

  @Nullable
  public static Resource<BitmapDrawable> obtain(
      @NonNull Resources resources, @Nullable Resource<Bitmap> bitmapResource) {
    if (bitmapResource == null) {
      return null;
    }
    return new LazyBitmapDrawableResource(resources, bitmapResource);

  }

  private LazyBitmapDrawableResource(@NonNull Resources resources,
      @NonNull Resource<Bitmap> bitmapResource) {
    this.resources = Preconditions.checkNotNull(resources);
    this.bitmapResource = Preconditions.checkNotNull(bitmapResource);
  }

  @NonNull
  @Override
  public Class<BitmapDrawable> getResourceClass() {
    return BitmapDrawable.class;
  }

  @NonNull
  @Override
  public BitmapDrawable get() {
    return new BitmapDrawable(resources, bitmapResource.get());
  }

  @Override
  public int getSize() {
    return bitmapResource.getSize();
  }

  @Override
  public void recycle() {
    bitmapResource.recycle();
  }

  @Override
  public void initialize() {
    if (bitmapResource instanceof Initializable) {
      ((Initializable) bitmapResource).initialize();
    }
  }
}
