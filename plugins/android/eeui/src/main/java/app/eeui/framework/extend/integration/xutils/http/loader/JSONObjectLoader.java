package app.eeui.framework.extend.integration.xutils.http.loader;

import android.text.TextUtils;

import org.json.JSONObject;
import app.eeui.framework.extend.integration.xutils.cache.DiskCacheEntity;
import app.eeui.framework.extend.integration.xutils.common.util.IOUtil;
import app.eeui.framework.extend.integration.xutils.http.RequestParams;
import app.eeui.framework.extend.integration.xutils.http.request.UriRequest;

/**
 * Author: wyouflf
 * Time: 2014/06/16
 */
/*package*/ class JSONObjectLoader extends Loader<JSONObject> {

    private String charset = "UTF-8";
    private String resultStr = null;

    @Override
    public Loader<JSONObject> newInstance() {
        return new JSONObjectLoader();
    }

    @Override
    public void setParams(final RequestParams params) {
        if (params != null) {
            String charset = params.getCharset();
            if (!TextUtils.isEmpty(charset)) {
                this.charset = charset;
            }
        }
    }

    @Override
    public JSONObject load(final UriRequest request) throws Throwable {
        request.sendRequest();
        resultStr = IOUtil.readStr(request.getInputStream(), charset);
        return new JSONObject(resultStr);
    }

    @Override
    public JSONObject loadFromCache(final DiskCacheEntity cacheEntity) throws Throwable {
        if (cacheEntity != null) {
            String text = cacheEntity.getTextContent();
            if (!TextUtils.isEmpty(text)) {
                return new JSONObject(text);
            }
        }

        return null;
    }

    @Override
    public void save2Cache(UriRequest request) {
        saveStringCache(request, resultStr);
    }
}
