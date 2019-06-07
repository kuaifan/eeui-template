package app.eeui.framework.extend.integration.glide.manager;

/**
 * A no-op {@link app.eeui.framework.extend.integration.glide.manager.ConnectivityMonitor}.
 */
class NullConnectivityMonitor implements ConnectivityMonitor {

  @Override
  public void onStart() {
    // Do nothing.
  }

  @Override
  public void onStop() {
    // Do nothing.
  }

  @Override
  public void onDestroy() {
    // Do nothing.
  }
}
