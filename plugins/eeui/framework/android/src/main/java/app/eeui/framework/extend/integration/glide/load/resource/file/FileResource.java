package app.eeui.framework.extend.integration.glide.load.resource.file;

import app.eeui.framework.extend.integration.glide.load.resource.SimpleResource;
import java.io.File;

/**
 * A simple {@link app.eeui.framework.extend.integration.glide.load.engine.Resource} that wraps a {@link File}.
 */
// Public API.
@SuppressWarnings("WeakerAccess")
public class FileResource extends SimpleResource<File> {
  public FileResource(File file) {
    super(file);
  }
}
