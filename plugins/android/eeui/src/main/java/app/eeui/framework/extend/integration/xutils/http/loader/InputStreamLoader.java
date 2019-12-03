package app.eeui.framework.extend.integration.xutils.http.loader;

import app.eeui.framework.extend.integration.xutils.cache.DiskCacheEntity;
import app.eeui.framework.extend.integration.xutils.http.request.UriRequest;

import java.io.InputStream;

/**
 * 建议配合 {@link app.eeui.framework.extend.integration.xutils.common.Callback.PrepareCallback} 使用,
 * 将PrepareType设置为InputStream, 以便在PrepareCallback#prepare中做耗时的数据任务处理.
 * <p>
 * Author: wyouflf
 * Time: 2014/05/30
 */
/*package*/ class InputStreamLoader extends Loader<InputStream> {

    @Override
    public Loader<InputStream> newInstance() {
        return new InputStreamLoader();
    }

    @Override
    public InputStream load(final UriRequest request) throws Throwable {
        request.sendRequest();
        return request.getInputStream();
    }

    @Override
    public InputStream loadFromCache(final DiskCacheEntity cacheEntity) throws Throwable {
        return null;
    }

    @Override
    public void save2Cache(final UriRequest request) {
    }
}
