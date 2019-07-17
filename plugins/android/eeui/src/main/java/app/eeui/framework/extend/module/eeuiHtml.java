package app.eeui.framework.extend.module;

import android.content.Context;
import android.net.Uri;
import android.text.TextUtils;

import java.io.File;
import java.net.MalformedURLException;
import java.net.URL;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import app.eeui.framework.activity.PageActivity;
import app.eeui.framework.extend.bean.PageBean;

public class eeuiHtml {

    /**
     * （无用、保留只是为了示例）将js中的src进行二次包装
     * @param context       上下文
     * @param content       内容
     * @return
     */
    @Deprecated
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
    }

    /**
     * （无用、保留只是为了示例）将image标签中的src进行二次包装
     * @param context       上下文
     * @param content       内容
     * @return
     */
    @Deprecated
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
    }

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
     * @param context       上下文
     * @param url           图片地址
     * @return
     */
    public static String repairUrl(Context context, String url) {
        if (url == null) {
            return "";
        }
        if (url.startsWith("file://file://")) {
            url = url.substring(7);
        }

        if (url.startsWith("http://") || url.startsWith("https://") || url.startsWith("ftp://") || url.startsWith("data:image/")) {
            Uri mUri = Uri.parse(url);
            if (TextUtils.equals("http", mUri.getScheme()) || TextUtils.equals("https", mUri.getScheme())) {
                String weexTpl = mUri.getQueryParameter("_wx_tpl");
                url = TextUtils.isEmpty(weexTpl) ? mUri.toString() : weexTpl;
            }
        }
        if (url == null || url.startsWith("http://") || url.startsWith("https://") || url.startsWith("ftp://") || url.startsWith("data:image/")) {
            return realUrl(url);
        }

        String websiteUrl = null;
        if (context instanceof PageActivity) {
            PageBean mPageBean = ((PageActivity) context).getPageInfo();
            if (mPageBean != null) {
                websiteUrl = mPageBean.getUrl();
            }
        }
        if (websiteUrl == null) {
            return realUrl(url);
        }

        if (url.startsWith("root://")) {
            if (websiteUrl.startsWith("file://assets")) {
                return realUrl("file://assets/eeui/" + url.substring(7));
            } else {
                url = "/" + url.substring(7);
            }
        }else if (url.startsWith("root:")) {
            if (websiteUrl.startsWith("file://assets")) {
                return realUrl("file://assets/eeui/" + url.substring(5));
            } else {
                url = "/" + url.substring(5);
            }
        }

        if (url.contains("page_cache")) {
            File cachePath = context.getExternalFilesDir("page_cache");
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
}
