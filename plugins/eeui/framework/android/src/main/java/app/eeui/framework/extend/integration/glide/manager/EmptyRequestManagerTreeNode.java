package app.eeui.framework.extend.integration.glide.manager;

import androidx.annotation.NonNull;
import app.eeui.framework.extend.integration.glide.RequestManager;
import java.util.Collections;
import java.util.Set;

/**
 * A {@link RequestManagerTreeNode} that returns no relatives.
 */
final class EmptyRequestManagerTreeNode implements RequestManagerTreeNode {
    @NonNull
    @Override
    public Set<RequestManager> getDescendants() {
        return Collections.emptySet();
    }
}
