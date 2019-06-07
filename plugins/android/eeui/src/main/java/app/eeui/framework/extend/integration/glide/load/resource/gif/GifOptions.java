package app.eeui.framework.extend.integration.glide.load.resource.gif;

import app.eeui.framework.extend.integration.glide.load.DecodeFormat;
import app.eeui.framework.extend.integration.glide.load.Option;
import app.eeui.framework.extend.integration.glide.load.Options;
import app.eeui.framework.extend.integration.glide.load.ResourceDecoder;

/**
 * Options related to decoding GIFs.
 */
public final class GifOptions {

  /**
   * Indicates the {@link app.eeui.framework.extend.integration.glide.load.DecodeFormat} that will be used in conjunction
   * with the particular GIF to determine the {@link android.graphics.Bitmap.Config} to use when
   * decoding frames of GIFs.
   */
  public static final Option<DecodeFormat> DECODE_FORMAT = Option.memory(
      "app.eeui.framework.extend.integration.glide.load.resource.gif.GifOptions.DecodeFormat", DecodeFormat.DEFAULT);

  /**
   * If set to {@code true}, disables the GIF {@link app.eeui.framework.extend.integration.glide.load.ResourceDecoder}s
   * ({@link ResourceDecoder#handles(Object, Options)} will return {@code false}). Defaults to
   * {@code false}.
   */
  public static final Option<Boolean> DISABLE_ANIMATION = Option.memory(
      "app.eeui.framework.extend.integration.glide.load.resource.gif.GifOptions.DisableAnimation", false);

  private GifOptions() {
    // Utility class.
  }
}
