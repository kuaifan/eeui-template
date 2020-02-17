package app.eeui.framework.extend.integration.glide.manager;

import android.content.Context;
import androidx.annotation.NonNull;

/**
 * A factory class that produces a functional
 * {@link app.eeui.framework.extend.integration.glide.manager.ConnectivityMonitor}.
 */
public interface ConnectivityMonitorFactory {

  @NonNull
  ConnectivityMonitor build(
      @NonNull Context context,
      @NonNull ConnectivityMonitor.ConnectivityListener listener);
}
