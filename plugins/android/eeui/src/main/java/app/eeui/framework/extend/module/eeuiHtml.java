package app.eeui.framework.extend.module;

import android.net.Uri;
import android.text.TextUtils;
import android.view.View;
import android.view.ViewGroup;

import com.alibaba.fastjson.JSONObject;
import com.taobao.weex.WXSDKInstance;

import java.io.File;
import java.net.MalformedURLException;
import java.net.URL;

import app.eeui.framework.activity.PageActivity;
import app.eeui.framework.extend.bean.PageBean;
import app.eeui.framework.ui.component.tabbar.view.TabbarFrameLayoutView;

public class eeuiHtml {

    /**
     * （无用、保留只是为了示例）将js中的src进行二次包装
     * @param context       上下文
     * @param content       内容
     * @return
     */
    /*@Deprecated
    public static String repairJsImage(Context context, String content) {
        String regexBody = "_c\\('image',\\s*\\{([^\\)]*)\\}";
        Pattern patternBody = Pattern.compile(regexBody, Pattern.CASE_INSENSITIVE);
        Matcher matcherBody = patternBody.matcher(content);
        //
        String result = content;
        while (matcherBody.find()) {
            String regexSrc = "(\"src\":\\s*\\\"([^\\)]*)\\\")";
            Pattern patternSrc = Pattern.compile(regexSrc, Pattern.CASE_INSENSITIVE);
            Matcher matcherSrc = patternSrc.matcher(matcherBody.group(1));
            //
            while (matcherSrc.find()) {
                String src = eeuiHtml.repairUrl(context, matcherSrc.group(2));
                result = result.replaceAll(matcherSrc.group(1), "\"src\": \"" + src + "\"");
            }
        }
        return result;
    }*/

    /**
     * （无用、保留只是为了示例）将image标签中的src进行二次包装
     * @param context       上下文
     * @param content       内容
     * @return
     */
    /*@Deprecated
    public static String repairImage(Context context, String content) {
        String patternStr = "<image\\s*([^>]*)\\s*src=((\\\"|\\')(.*?)(\\\"|\\'))\\s*([^>]*)>";
        Pattern pattern = Pattern.compile(patternStr, Pattern.CASE_INSENSITIVE);
        Matcher matcher = pattern.matcher(content);
        String result = content;
        while (matcher.find()) {
            try {
                String src = matcher.group(3) + eeuiHtml.repairUrl(context, matcher.group(4)) + matcher.group(5);
                result = result.replaceAll(matcher.group(2), src);
            }catch (Exception ignored) { }
        }
        return result;
    }*/

    /**
     * 规范化url
     * @param url
     * @return
     */
    public static String realUrl(String url) {
        try {
            URL uri = new URL(url);
            url = uri.toString();
        } catch (MalformedURLException e) {
            e.printStackTrace();
        }
        return url;
    }

    /**
     * 补全地址
     * @param pageUrl      context（PageActivity）、String（父页地址）、view、WXSDKInstance
     * @param url           图片地址
     * @return
     */
    public static String repairUrl(Object pageUrl, String url) {
        if (url == null) {
            return "";
        }
        if (url.startsWith("file://file://")) {
            url = url.substring(7);
        }
        if (url.startsWith("data:image/")) {
            return url;
        }

        if (url.startsWith("http://") || url.startsWith("https://") || url.startsWith("ftp://")) {
            Uri mUri = Uri.parse(url);
            if (TextUtils.equals("http", mUri.getScheme()) || TextUtils.equals("https", mUri.getScheme())) {
                String weexTpl = mUri.getQueryParameter("_wx_tpl");
                url = TextUtils.isEmpty(weexTpl) ? mUri.toString() : weexTpl;
            }
        }
        if (url.startsWith("http://") || url.startsWith("https://") || url.startsWith("ftp://")) {
            return realUrl(url);
        }

        String websiteUrl = getWebsiteUrl(pageUrl);
        if (websiteUrl == null) {
            return realUrl(url);
        }

        if (url.startsWith("/")) {
            if (websiteUrl.startsWith("file://assets")) {
                url = "root:/" + url;
            }
        }

        if (url.startsWith("root:")) {
            int fromIndex = url.startsWith("root://") ? 7 : 5;
            if (websiteUrl.startsWith("file://assets")) {
                return realUrl("file://assets/eeui/" + url.substring(fromIndex));
            } else {
                url = "/" + url.substring(fromIndex);
            }
        }

        if (url.contains("page_cache")) {
            File cachePath = eeui.getApplication().getExternalFilesDir("page_cache");
            if (cachePath != null) {
                String cacheUrl = "file://" + cachePath.getPath();
                if (url.startsWith(cacheUrl)) {
                    url = url.substring(cacheUrl.length());
                }
            }
        }

        if (url.startsWith("file://")) {
            return realUrl(url);
        }

        String newUrl = url;
        try {
            URL tmp = new URL(websiteUrl);
            if (url.startsWith("//")) {
                return realUrl(tmp.getProtocol() + ":" + url);
            }
            newUrl = tmp.getProtocol() + "://" + tmp.getHost();
            newUrl+= (tmp.getPort() > -1 && tmp.getPort() != 80) ? (":" + tmp.getPort()) : "";
            if (url.startsWith("/")) {
                if (websiteUrl.startsWith("file://assets/")) {
                    newUrl = "file://assets" + url;
                }else{
                    newUrl+= url;
                }
            }else{
                String path = "/";
                int lastIndex = tmp.getPath().lastIndexOf("/");
                if (lastIndex > -1){
                    path = tmp.getPath().substring(0, lastIndex + 1);
                }
                newUrl+= path + url;
            }
        } catch (MalformedURLException e) {
            e.printStackTrace();
        }
        return realUrl(newUrl);
    }

    /**
     * 获取父级地址
     * @param pageUrl
     * @return
     */
    public static String getWebsiteUrl(Object pageUrl) {
        String websiteUrl = null;
        if (pageUrl instanceof String) {
            websiteUrl = (String) pageUrl;
        }
        if (websiteUrl == null && pageUrl instanceof WXSDKInstance) {
            String tabbarUrl = ((WXSDKInstance) pageUrl).getContainerInfo().get("eeuiTabbarUrl");
            if (!TextUtils.isEmpty(tabbarUrl)) {
                websiteUrl = tabbarUrl;
            }
            pageUrl = ((WXSDKInstance) pageUrl).getContext();
        }
        if (websiteUrl == null && pageUrl instanceof View) {
            ViewGroup parentViewGroup = (ViewGroup) ((View) pageUrl).getParent();
            while (parentViewGroup != null) {
                if (parentViewGroup instanceof TabbarFrameLayoutView) {
                    websiteUrl = ((TabbarFrameLayoutView) parentViewGroup).getUrl();
                    break;
                }
                try {
                    parentViewGroup = (ViewGroup) parentViewGroup.getParent();
                } catch (ClassCastException e) {
                    parentViewGroup = null;
                }
            }
            pageUrl = ((View) pageUrl).getContext();
        }
        if (websiteUrl == null && pageUrl instanceof PageActivity) {
            PageBean mPageBean = ((PageActivity) pageUrl).getPageInfo();
            if (mPageBean != null) {
                websiteUrl = mPageBean.getUrl();
            }
        }
        return websiteUrl;
    }

    /**
     * 获取地址中的参数返回 JSONObject
     * @param url
     * @return
     */
    public static JSONObject getUrlQuery(String url) {
        JSONObject queryJson = new JSONObject();
        if (url == null) {
            return queryJson;
        }
        url = url.trim();
        if (url.equals("")) {
            return queryJson;
        }
        String[] urlParts = url.split("\\?");
        //没有参数
        if (urlParts.length == 1) {
            return queryJson;
        }
        //有参数
        String[] params = urlParts[1].split("&");
        for (String param : params) {
            String[] keyValue = param.split("=");
            queryJson.put(keyValue[0], keyValue[1]);
        }
        return queryJson;
    }
}
