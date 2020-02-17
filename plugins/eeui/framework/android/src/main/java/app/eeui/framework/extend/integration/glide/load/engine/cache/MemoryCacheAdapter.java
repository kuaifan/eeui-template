package app.eeui.framework.extend.integration.glide.load.engine.cache;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import app.eeui.framework.extend.integration.glide.load.Key;
import app.eeui.framework.extend.integration.glide.load.engine.Resource;

/**
 * A simple class that ignores all puts and returns null for all gets.
 */
public class MemoryCacheAdapter implements MemoryCache {

  private ResourceRemovedListener listener;

  @Override
  public long getCurrentSize() {
    return 0;
  }

  @Override
  public long getMaxSize() {
    return 0;
  }

  @Override
  public void setSizeMultiplier(float multiplier) {
    // Do nothing.
  }

  @Nullable
  @Override
  public Resource<?> remove(@NonNull Key key) {
    return null;
  }

  @Nullable
  @Override
  public Resource<?> put(@NonNull Key key, @Nullable Resource<?> resource) {
    if (resource != null) {
      listener.onResourceRemoved(resource);
    }
    return null;
  }

  @Override
  public void setResourceRemovedListener(@NonNull ResourceRemovedListener listener) {
    this.listener = listener;
  }

  @Override
  public void clearMemory() {
    // Do nothing.
  }

  @Override
  public void trimMemory(int level) {
    // Do nothing.
  }
}
