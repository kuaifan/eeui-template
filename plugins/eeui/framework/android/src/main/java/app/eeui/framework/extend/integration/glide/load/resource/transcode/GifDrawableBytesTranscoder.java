package app.eeui.framework.extend.integration.glide.load.resource.transcode;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import app.eeui.framework.extend.integration.glide.load.Options;
import app.eeui.framework.extend.integration.glide.load.engine.Resource;
import app.eeui.framework.extend.integration.glide.load.resource.bytes.BytesResource;
import app.eeui.framework.extend.integration.glide.load.resource.gif.GifDrawable;
import app.eeui.framework.extend.integration.glide.util.ByteBufferUtil;
import java.nio.ByteBuffer;

/**
 * An {@link app.eeui.framework.extend.integration.glide.load.resource.transcode.ResourceTranscoder} that converts {@link
 * app.eeui.framework.extend.integration.glide.load.resource.gif.GifDrawable} into bytes by obtaining the original bytes of
 * the GIF from the {@link app.eeui.framework.extend.integration.glide.load.resource.gif.GifDrawable}.
 */
public class GifDrawableBytesTranscoder implements ResourceTranscoder<GifDrawable, byte[]> {
  @Nullable
  @Override
  public Resource<byte[]> transcode(@NonNull Resource<GifDrawable> toTranscode,
      @NonNull Options options) {
    GifDrawable gifData = toTranscode.get();
    ByteBuffer byteBuffer = gifData.getBuffer();
    return new BytesResource(ByteBufferUtil.toBytes(byteBuffer));
  }
}
