package app.eeui.framework.extend.integration.glide.load.engine.cache;

import app.eeui.framework.extend.integration.glide.load.Key;
import java.io.File;

/**
 * A simple class that returns null for all gets and ignores all writes.
 */
public class DiskCacheAdapter implements DiskCache {
  @Override
  public File get(Key key) {
    // no op, default for overriders
    return null;
  }

  @Override
  public void put(Key key, Writer writer) {
    // no op, default for overriders
  }

  @Override
  public void delete(Key key) {
    // no op, default for overriders
  }

  @Override
  public void clear() {
      // no op, default for overriders
  }
}
