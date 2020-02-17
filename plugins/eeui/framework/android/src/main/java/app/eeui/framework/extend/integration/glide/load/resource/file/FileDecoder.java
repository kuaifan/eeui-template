package app.eeui.framework.extend.integration.glide.load.resource.file;

import androidx.annotation.NonNull;
import app.eeui.framework.extend.integration.glide.load.Options;
import app.eeui.framework.extend.integration.glide.load.ResourceDecoder;
import app.eeui.framework.extend.integration.glide.load.engine.Resource;
import java.io.File;

/**
 * A simple {@link app.eeui.framework.extend.integration.glide.load.ResourceDecoder} that creates resource for a given {@link
 * java.io.File}.
 */
public class FileDecoder implements ResourceDecoder<File, File> {

  @Override
  public boolean handles(@NonNull File source, @NonNull Options options) {
    return true;
  }

  @Override
  public Resource<File> decode(@NonNull File source, int width, int height,
      @NonNull Options options) {
    return new FileResource(source);
  }
}
