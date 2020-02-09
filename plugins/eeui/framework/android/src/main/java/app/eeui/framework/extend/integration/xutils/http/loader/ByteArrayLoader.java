package app.eeui.framework.extend.integration.xutils.http.loader;

import app.eeui.framework.extend.integration.xutils.cache.DiskCacheEntity;
import app.eeui.framework.extend.integration.xutils.common.util.IOUtil;
import app.eeui.framework.extend.integration.xutils.http.request.UriRequest;

/**
 * Author: wyouflf
 * Time: 2014/05/30
 */
/*package*/ class ByteArrayLoader extends Loader<byte[]> {

    private byte[] resultData;

    @Override
    public Loader<byte[]> newInstance() {
        return new ByteArrayLoader();
    }

    @Override
    public byte[] load(final UriRequest request) throws Throwable {
        request.sendRequest();
        resultData = IOUtil.readBytes(request.getInputStream());
        return resultData;
    }

    @Override
    public byte[] loadFromCache(final DiskCacheEntity cacheEntity) throws Throwable {
        if (cacheEntity != null) {
            byte[] data = cacheEntity.getBytesContent();
            if (data != null && data.length > 0) {
                return data;
            }
        }
        return null;
    }

    @Override
    public void save2Cache(final UriRequest request) {
        saveByteArrayCache(request, resultData);
    }
}
