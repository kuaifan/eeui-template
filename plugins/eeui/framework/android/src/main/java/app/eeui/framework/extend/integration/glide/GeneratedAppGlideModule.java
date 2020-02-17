package app.eeui.framework.extend.integration.glide;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import app.eeui.framework.extend.integration.glide.manager.RequestManagerRetriever;
import app.eeui.framework.extend.integration.glide.module.AppGlideModule;
import java.util.Set;

/**
 * Allows {@link AppGlideModule}s to exclude {@link app.eeui.framework.extend.integration.glide.annotation.GlideModule}s to
 * ease the migration from {@link app.eeui.framework.extend.integration.glide.annotation.GlideModule}s to Glide's annotation
 * processing system and optionally provides a
 * {@link app.eeui.framework.extend.integration.glide.manager.RequestManagerRetriever.RequestManagerFactory} impl.
 */
abstract class GeneratedAppGlideModule extends AppGlideModule {
  /**
   * This method can be removed when manifest parsing is no longer supported.
   */
  @NonNull
  abstract Set<Class<?>> getExcludedModuleClasses();

  @Nullable
  RequestManagerRetriever.RequestManagerFactory getRequestManagerFactory() {
    return null;
  }
}
