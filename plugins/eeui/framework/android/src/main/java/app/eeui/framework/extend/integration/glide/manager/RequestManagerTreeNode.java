package app.eeui.framework.extend.integration.glide.manager;

import androidx.annotation.NonNull;
import app.eeui.framework.extend.integration.glide.RequestManager;
import java.util.Set;

/**
 * Provides access to the relatives of a RequestManager based on the current context. The context
 * hierarchy is provided by nesting in Activity and Fragments; the application context does not
 * provide access to any other RequestManagers hierarchically.
 */
public interface RequestManagerTreeNode {
  /**
   * Returns all descendant {@link RequestManager}s relative to the context of the current
   * {@link RequestManager}.
   */
  @NonNull
  Set<RequestManager> getDescendants();
}
