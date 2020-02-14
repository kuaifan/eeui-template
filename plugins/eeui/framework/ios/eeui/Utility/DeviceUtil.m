//
//  DeviceUtil.m
//  WeexTestDemo
//
//  Created by apple on 2018/6/5.
//  Copyright © 2018年 TomQin. All rights reserved.
//

#import "DeviceUtil.h"
#import "WeexSDKManager.h"
#import "TBCityIconInfo.h"
#import "TBCityIconFont.h"
#import "eeuiViewController.h"
#import "Config.h"

@implementation DeviceUtil


//设计尺寸转开发尺寸 px -> pt
+ (CGFloat)scale:(NSInteger)value
{
    //weex以750宽为设计尺寸
    return [UIScreen mainScreen].bounds.size.width * 1.0f/750 * value;
}

+ (CGFloat)scaleFloat:(float)value
{
    //weex以750宽为设计尺寸
    return [UIScreen mainScreen].bounds.size.width * 1.0f/750 * value;
}

//字体尺寸转换
+ (NSInteger)font:(NSInteger)font
{
    return [UIScreen mainScreen].bounds.size.width * 1.0f/750 * font;
}

//获取当前控制器
+ (UIViewController *)getTopviewControler {
    UIViewController *rootVC = [[UIApplication sharedApplication].delegate window].rootViewController;

    UIViewController *parent = rootVC;

    while ((parent = rootVC.presentedViewController) != nil && [(parent = rootVC.presentedViewController) isKindOfClass:[eeuiViewController class]]) {
        rootVC = parent;
    }

    while ([rootVC isKindOfClass:[UINavigationController class]]) {
        rootVC = [(UINavigationController *)rootVC topViewController];
    }

    return rootVC;
}

//url转换
+ (NSString*)urlEncoder:(NSString*)url
{
    url = [url stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    url = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
    return url;
}

//规范化url，删除所有符号连接（比如'/./', '/../' 以及多余的'/'）
+ (NSString*)realUrl:(NSString*)url
{
    if ([url containsString:@"/./"] || [url containsString:@"/../"]) {
        url = [url stringByReplacingOccurrencesOfString:@"\\" withString:@"/"];
        NSString *last = @"";
        while (![url isEqualToString:last]) {
            last = url;
            NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"/[^/]+/\\.\\./" options:NSRegularExpressionCaseInsensitive error:nil];
            url  = [regex stringByReplacingMatchesInString:url options:0 range:NSMakeRange(0, url.length) withTemplate:@"/"];
        }
        last = @"";
        while (![url isEqualToString:last]) {
            last = url;
            NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"/\\./+" options:NSRegularExpressionCaseInsensitive error:nil];
            url  = [regex stringByReplacingMatchesInString:url options:0 range:NSMakeRange(0, url.length) withTemplate:@"/"];
        }
    }
    return url;
}

//重写url（传入 WXSDKInstance）
+ (NSString*)rewriteUrl:(NSString*)url mInstance:(WXSDKInstance*)mInstance
{
    NSString* homePage = nil;
    if ([mInstance.viewController isKindOfClass:[eeuiViewController class]]) {
        eeuiViewController *top = (eeuiViewController *)mInstance.viewController;
        if (top && top.url) {
            homePage = top.url;
        }
    }
    return [self rewriteUrl:url homePage:homePage];
}

//重写url（传入homePage）
+ (NSString*)rewriteUrl:(NSString*)url homePage:(NSString*)homePage
{
    if (url.length == 0) {
        return @"";
    }
    if ([url hasPrefix:@"file://file://"]) {
        url = [url substringFromIndex:7];
    }

    if (url == nil || [url hasPrefix:@"http://"] || [url hasPrefix:@"https://"] || [url hasPrefix:@"ftp://"] || [url hasPrefix:@"file://"] || [url hasPrefix:@"data:image/"]) {
        NSArray* elts = [url componentsSeparatedByString:@"?"];
        if (elts.count >= 2) {
            NSArray *urls = [elts.lastObject componentsSeparatedByString:@"="];
            for (NSString *str in urls) {
                if ([str isEqualToString:@"_wx_tpl"]) {
                    url = [[urls lastObject]  stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                    break;
                }
            }
        }
    }
    if (url.length == 0 || [url hasPrefix:@"http://"] || [url hasPrefix:@"https://"] || [url hasPrefix:@"ftp://"] || [url hasPrefix:@"data:image/"]) {
        return [self realUrl:url];
    }

    if (homePage.length == 0) {
        homePage = [[WeexSDKManager sharedIntstance] weexUrl];
        if ([[[WXSDKManager bridgeMgr] topInstance].viewController isKindOfClass:[eeuiViewController class]]) {
            eeuiViewController *top = (eeuiViewController *)[[WXSDKManager bridgeMgr] topInstance].viewController;
            if (top && top.url) {
                homePage = top.url;
            }
        }
        if (homePage.length == 0) {
            eeuiViewController *top = (eeuiViewController *)[self getTopviewControler];
            if (top && top.url) {
                homePage = top.url;
            }
        }       
    }
    if (homePage.length == 0) {
        return [self realUrl:url];
    }
    
    if ([url hasPrefix:@"/"]) {
        NSString *tempUrl = [NSString stringWithFormat:@"file://%@", [Config getResourcePath:@"bundlejs"]];
        if ([homePage hasPrefix:tempUrl]) {
            url = [NSString stringWithFormat:@"root:/%@", url];
        }
    }
    
    if ([url hasPrefix:@"root:"]) {
        NSInteger fromIndex = [url hasPrefix:@"root://"] ? 7 : 5;
        NSString *tempUrl = [NSString stringWithFormat:@"file://%@", [Config getResourcePath:@"bundlejs"]];
        if ([homePage hasPrefix:tempUrl]) {
            return [self realUrl:[NSString stringWithFormat:@"%@/eeui/%@", tempUrl, [url substringFromIndex:fromIndex]]];
        }else{
            url = [NSString stringWithFormat:@"/%@", [url substringFromIndex:fromIndex]];
        }
    }
    
    if ([url containsString:@"page_cache"]) {
        NSString *filePath = [NSString stringWithFormat:@"file://%@",
                              [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"page_cache"]];
        if ([url hasPrefix:filePath]) {
            url = [url substringFromIndex:filePath.length];
        }
    }
    
    if ([url hasPrefix:@"file://"]) {
        return [self realUrl:url];
    }

    NSURL *URL = [NSURL URLWithString:homePage];
    NSString *scheme = [URL scheme];
    NSString *host = [URL host];
    NSInteger port = [[URL port] integerValue];
    NSString *path = [URL path];

    if (scheme == nil) scheme = @"";
    if (host == nil) host = @"";
    
    if ([url hasPrefix:@"//"]) {
        return [self realUrl:[NSString stringWithFormat:@"%@:%@", scheme, url]];
    }
    NSString *newUrl = [NSString stringWithFormat:@"%@://%@%@", scheme, host, port > 0 && port != 80 ? [NSString stringWithFormat:@":%ld", (long)port] : @""];
    if ([url isAbsolutePath]) {
        NSString *rootPath = [NSString stringWithFormat:@"file://%@", [Config getResourcePath:@"bundlejs"]];
        if ([homePage hasPrefix:rootPath]) {
            newUrl = [rootPath stringByAppendingString:url];
        }else{
            newUrl = [newUrl stringByAppendingString:url];
        }
    } else {
        if ([path isEqualToString:@"/"]) {
            path = @"";
        } else {
            path = [path stringByDeletingLastPathComponent];
        }
        newUrl = [NSString stringWithFormat:@"%@%@/%@", newUrl, path, url];
    }
    return [self realUrl:newUrl];
}

//url添加js后缀
+ (NSString*)suffixUrl:(NSString*)pageType url:(NSString*)url
{
    if ([pageType isEqualToString:@"app"] || [pageType isEqualToString:@"weex"]) {
        NSArray *array = [url componentsSeparatedByString:@"/"];
        NSString *lastUrl = [array lastObject];
        if (!([url hasPrefix:@"http://"] || [url hasPrefix:@"https://"] || [url hasPrefix:@"ftp://"] || [url hasPrefix:@"file://"])
            && ![lastUrl containsString:@"."]) {
            url = [NSString stringWithFormat:@"%@.js", url];
        }
    }
    return url;
}

//根据文本属性获取图片
+ (UIImage*)getIconText:(NSString*)text font:(NSInteger)font color:(NSString*)icolor
{
    NSString *key = @"";
    NSInteger fontSize = font > 0 ? font : 12;
    NSString *color = icolor.length > 0 ? icolor : @"#242424";
    NSArray *list = [text componentsSeparatedByString:@" "];
    if (list.count == 2) {
        key = [WXConvert NSString:list.firstObject];
        NSString *other = [WXConvert NSString:list.lastObject];
        if ([other hasSuffix:@"px"] || [other hasSuffix:@"dp"] || [other hasSuffix:@"sp"] || [other hasSuffix:@"%"]) {
            fontSize = FONT([other integerValue]);
        } else if ([other isEqualToString:@"#"]) {
            color = other;
        }
    } else {
        key = text;
    }
    [TBCityIconFont setFontName:@"eeuiicon"];
    NSString *imgName = [IconFontUtil iconFont:key];

    return [UIImage iconWithInfo:TBCityIconInfoMake(imgName, fontSize, [WXConvert UIColor:color])];
}

//字符串中划线转驼峰写法
+ (NSString *)convertToCamelCaseFromSnakeCase:(NSString *)key
{
    NSMutableString *str = [NSMutableString stringWithString:key];
    while ([str containsString:@"-"]) {
        NSRange range = [str rangeOfString:@"-"];
        if (range.location + 1 < [str length]) {
            char c = [str characterAtIndex:range.location+1];
            [str replaceCharactersInRange:NSMakeRange(range.location, range.length+1) withString:[[NSString stringWithFormat:@"%c",c] uppercaseString]];
        }
    }
    return str;
}

//重设图片大小
+ (UIImage *)imageResize:(UIImage*)img andResizeTo:(CGSize)newSize icon:(NSString *)icon
{
    CGFloat scale = [[UIScreen mainScreen]scale];
    UIGraphicsBeginImageContextWithOptions(newSize, NO, scale);
    CGFloat x = 0;
    if (![icon containsString:@"//"] && ![icon hasPrefix:@"data:"]) {
        x = - newSize.width / 12 + scale / 12;
    }
    [img drawInRect:CGRectMake(x, 0, newSize.width, newSize.height)];//有偏移，自己加了参数
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

//获取Appboard内容
+ (NSString *)getAppboardContent
{
    if (mAppboardContent == nil) {
        mAppboardContent = [NSMutableDictionary dictionary];
    }
    if (mAppboardWifi == nil) {
        mAppboardWifi = [NSMutableDictionary dictionary];
    }
    [self loadAppboardContent];
    [self loadAppboardUpdate];
    //
    NSString *appboard = @"";
    for (NSString *key in mAppboardWifi) {
        NSString *value = mAppboardWifi[key];
        if (value.length > 0) {
            appboard = [NSString stringWithFormat:@"%@%@;", appboard, value];
        }
    }
    for (NSString *key in mAppboardContent) {
        NSString *temp = mAppboardWifi[key];
        if (temp.length == 0) {
            NSString *value = mAppboardContent[key];
            if (value.length > 0) {
                appboard = [NSString stringWithFormat:@"%@%@;", appboard, value];
            }
        }
    }
    if (appboard.length > 0) {
        if (![appboard hasPrefix:@"// { \"framework\": \"Vue\"}"]) {
            appboard = [NSString stringWithFormat:@"%@%@", @"// { \"framework\": \"Vue\"}\nif(typeof app==\"undefined\"){app=weex}\n", appboard];
        }
    }
    return appboard;
}

//加载assets下的appboard
+ (void)loadAppboardContent
{
    NSString *path = [Config getResourcePath:@"bundlejs/eeui/appboard"];
    NSFileManager * fileManger = [NSFileManager defaultManager];
    BOOL isDir = NO;
    [fileManger fileExistsAtPath:path isDirectory:&isDir];
    if (isDir) {
        NSArray * dirArray = [fileManger contentsOfDirectoryAtPath:path error:nil];
        NSString * subPath = nil;
        for (NSString * str in dirArray) {
            if ([str hasSuffix:@".js"]) {
                NSString *key = [NSString stringWithFormat:@"appboard/%@", str];
                NSString *temp = [mAppboardContent objectForKey:key];
                if (temp.length == 0) {
                    subPath  = [Config verifyFile:[path stringByAppendingPathComponent:str]];
                    BOOL issubDir = NO;
                    [fileManger fileExistsAtPath:subPath isDirectory:&issubDir];
                    BOOL isExist = [fileManger fileExistsAtPath:subPath isDirectory:&isDir];
                    if (isExist) {
                        NSData *fileData = [[NSData alloc] initWithContentsOfFile:subPath];
                        temp = [[NSString alloc] initWithData:fileData encoding:NSUTF8StringEncoding];
                        [mAppboardContent setValue:temp forKey:key];
                    }
                }
            }
        }
    }
}

//加载热更新下的appboard
+ (void)loadAppboardUpdate
{
    NSString *path = [Config getSandPath:@"update"];
    NSFileManager *myFileManager = [NSFileManager defaultManager];
    BOOL isDir = NO;
    BOOL isExist = NO;

    NSMutableArray *tempArray = [Config verifyData];
    for (NSString * dirName in tempArray) {
        NSString *tempPath = [NSString stringWithFormat:@"%@/%@/appboard", path, dirName];
        isExist = [myFileManager fileExistsAtPath:tempPath isDirectory:&isDir];
        if (isExist && isDir) {
            NSArray *tmpArray = [myFileManager contentsOfDirectoryAtPath:tempPath error:nil];
            for (NSString * tmpName in tmpArray) {
                if ([tmpName hasSuffix:@".js"]) {
                    NSString *key = [NSString stringWithFormat:@"appboard/%@", tmpName];
                    NSString *temp = [mAppboardContent objectForKey:key];
                    if (temp.length == 0) {
                        NSString *filePath = [NSString stringWithFormat:@"%@/%@", tempPath, tmpName];
                        isExist = [myFileManager fileExistsAtPath:filePath isDirectory:&isDir];
                        if (isExist && !isDir) {
                            NSData *fileData = [[NSData alloc] initWithContentsOfFile:filePath];
                            temp = [[NSString alloc] initWithData:fileData encoding:NSUTF8StringEncoding];
                            [mAppboardContent setValue:temp forKey:key];
                        }
                    }
                }
            }
        }
    }
}

//设置Appboard内容
+ (void)setAppboardContent:(NSString *)key content:(NSString *)content
{
    if (mAppboardContent == nil) {
        mAppboardContent = [NSMutableDictionary dictionary];
    }
    [mAppboardContent setValue:content forKey:key];
}

//清空Appboard内容
+ (void)clearAppboardContent
{
    mAppboardContent = [NSMutableDictionary dictionary];
}

//设置Appboard内容 (WIFI同步)
+ (void)setAppboardWifi:(NSString *)key content:(NSString *)content
{
    if (mAppboardWifi == nil) {
        mAppboardWifi = [NSMutableDictionary dictionary];
    }
    [mAppboardWifi setValue:content forKey:key];
}

//清空Appboard内容 (WIFI同步)
+ (void)clearAppboardWifi
{
    mAppboardWifi = [NSMutableDictionary dictionary];
}

//下载文件
+ (void)downloadScript:(NSString *)url appboard:(NSString *)appboard cache:(NSInteger)cache callback:(void(^)(NSString* path))callback
{
    NSDictionary *data = [WeexSDKManager sharedIntstance].cacheData[url];
    if (data != nil) {
        NSDictionary *data = [WeexSDKManager sharedIntstance].cacheData[url];
        NSInteger time = [data[@"cache_time"] integerValue];
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:time];
        if ([date compare:[NSDate date]] == NSOrderedDescending) {
            callback([NSString stringWithFormat:@"file://%@", data[@"cache_url"]]);
            return;
        }
    }
    //
    NSString *filePath = [NSString stringWithFormat:@"file://%@/",
                          [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"page_cache"]];
    if ([url hasPrefix:filePath]) {
        callback(url);
        return;
    }
    //
    NSString *urlStr = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet characterSetWithCharactersInString:@"`#%^{}\"[]|\\<> "].invertedSet];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *downloadTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (!error) {
            NSString *path = @"/";
            NSString *rootPath = [NSString stringWithFormat:@"file://%@", [Config getResourcePath:@"bundlejs"]];
            if ([url hasPrefix:rootPath]) {
                path = [url substringFromIndex:rootPath.length];
            }else{
                path = [[NSURL URLWithString:url] path];
            }
            if (![path isEqualToString:@"/"]) {
                path = [path stringByDeletingLastPathComponent];
            }
            NSFileManager *fileManager = [NSFileManager defaultManager];
            NSString *filePath =  [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:[NSString stringWithFormat:@"page_cache%@", path]];
            if (![fileManager fileExistsAtPath:filePath]) {
                [fileManager createDirectoryAtPath:filePath withIntermediateDirectories:YES attributes:nil error:nil];
            }
            NSString *fullPath = [filePath stringByAppendingPathComponent:[Config MD5ForLower32Bate:url]];
            NSString *content = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            if (appboard.length > 0) {
                content = [NSString stringWithFormat:@"%@%@", appboard, content];
            }
            [content writeToFile:fullPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
            //
            if (cache > 1000) {
                NSInteger time = [[NSDate date] timeIntervalSince1970] + cache * 1.0f / 1000;
                NSDictionary *saveDic = @{@"cache_url":fullPath, @"cache_time":@(time)};
                [[WeexSDKManager sharedIntstance].cacheData setObject:saveDic forKey:url];
            }
            //
            callback([NSString stringWithFormat:@"file://%@", fullPath]);
        }else{
            callback(nil);
        }
    }];
    [downloadTask resume];
}


// 时间戳—>字符串时间
+ (NSString *)timesFromString:(NSString *)timestamp {
    //时间戳转时间的方法
    NSDate *timeData = [NSDate dateWithTimeIntervalSince1970:[timestamp intValue]];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *strTime = [dateFormatter stringFromDate:timeData];
    return strTime;
}

//NSDictionary转NSString
+ (NSString*) dictionaryToJson:(NSDictionary *)dic
{
    NSError *parseError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&parseError];
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

//NSString转NSDictionary
+ (NSDictionary*) dictionaryWithJsonString:(NSString *)jsonString
{
    if (jsonString == nil) {
        return nil;
    }
    if ([jsonString isKindOfClass:[NSDictionary class]]) {
        return (NSDictionary *) jsonString;
    }
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&err];
    if (err) {
        return nil;
    }
    return dic;
}

//数组转换成json串
+ (NSString *)arrayToJson:(NSArray *)array
{
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:array options:NSJSONWritingPrettyPrinted error:&error];
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];;
}

//判断颜色是不是亮色
+(BOOL) isLightColor:(UIColor*)clr {
    CGFloat components[3];
    [self getRGBComponents:components forColor:clr];
    EELog(@"%f %f %f", components[0], components[1], components[2]);
    CGFloat num = components[0] + components[1] + components[2];
    if(num < 382) {
        return NO;
    }else{
        return YES;
    }
}

//获取RGB值
+ (void)getRGBComponents:(CGFloat [3])components forColor:(UIColor *)color {
#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_6_1
    int bitmapInfo = kCGBitmapByteOrderDefault | kCGImageAlphaPremultipliedLast;
#else
    int bitmapInfo = kCGImageAlphaPremultipliedLast;
#endif
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    unsigned char resultingPixel[4];
    CGContextRef context = CGBitmapContextCreate(&resultingPixel, 1, 1, 8, 4, rgbColorSpace, bitmapInfo);
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, CGRectMake(0, 0, 1, 1));
    CGContextRelease(context);
    CGColorSpaceRelease(rgbColorSpace);
    for (int component = 0; component < 3; component++) {
        components[component] = resultingPixel[component];
    }
}

+ (NSString *) webCommonStyle
{
    return @"body{background-color:#FFF;color:#000;font-family:Verdana,Arial,Helvetica,sans-serif;font-size:14px;line-height:1.3;scrollbar-3dlight-color:#F0F0EE;scrollbar-arrow-color:#676662;scrollbar-base-color:#F0F0EE;scrollbar-darkshadow-color:#DDD;scrollbar-face-color:#E0E0DD;scrollbar-highlight-color:#F0F0EE;scrollbar-shadow-color:#F0F0EE;scrollbar-track-color:#F5F5F5}td,th{font-family:Verdana,Arial,Helvetica,sans-serif;font-size:14px}.word-wrap{word-wrap:break-word;-ms-word-break:break-all;word-break:break-all;word-break:break-word;-ms-hyphens:auto;-moz-hyphens:auto;-webkit-hyphens:auto;hyphens:auto}.mce-content-body .mce-reset{margin:0;padding:0;border:0;outline:0;vertical-align:top;background:0 0;text-decoration:none;color:#000;font-family:Arial;font-size:11px;text-shadow:none;float:none;position:static;width:auto;height:auto;white-space:nowrap;cursor:inherit;line-height:normal;font-weight:400;text-align:left;-webkit-tap-highlight-color:transparent;-moz-box-sizing:content-box;-webkit-box-sizing:content-box;box-sizing:content-box;direction:ltr;max-width:none}.mce-object{border:1px dotted #3A3A3A;background:#D5D5D5 url(data:image/gif;base64,R0lGODlhEQANALMPAOXl5T8/P29vb7S0tFdXV/39/djY2N3d3crKyu/v7/f39/Ly8p2dnf///zMzMwAAACH5BAEAAA8ALAAAAAARAA0AAARF0MlJq3uutay75lmGNU9pjiNFCsipqhgxmO9HSgFTgtt9O4EBABWa3AiGwvBlfAgWisPOyCslDDSbSHTa+SzgpmdMbkQAADs=) no-repeat center}.mce-preview-object{display:inline-block;position:relative;margin:0 2px 0 2px;line-height:0;border:1px solid gray}.mce-preview-object[data-mce-selected=2] .mce-shim{display:none}.mce-preview-object .mce-shim{position:absolute;top:0;left:0;width:100%;height:100%;background:url(data:image/gif;base64,R0lGODlhAQABAIAAAAAAAP///yH5BAEAAAAALAAAAAABAAEAAAIBRAA7)}figure.align-left{float:left}figure.align-right{float:right}figure.image.align-center{display:table;margin-left:auto;margin-right:auto}figure.image{display:inline-block;border:1px solid gray;margin:0 2px 0 1px;background:#f5f2f0}figure.image img{margin:8px 8px 0 8px}figure.image figcaption{margin:6px 8px 6px 8px;text-align:center}.mce-toc{border:1px solid gray}.mce-toc h2{margin:4px}.mce-toc li{list-style-type:none}.mce-pagebreak{cursor:default;display:block;border:0;width:100%;height:5px;border:1px dashed #666;margin-top:15px;page-break-before:always}@media print{.mce-pagebreak{border:0}}.mce-item-anchor{cursor:default;display:inline-block;-webkit-user-select:all;-webkit-user-modify:read-only;-moz-user-select:all;-moz-user-modify:read-only;user-select:all;user-modify:read-only;width:9px!important;height:9px!important;border:1px dotted #3A3A3A;background:#D5D5D5 url(data:image/gif;base64,R0lGODlhBwAHAIABAAAAAP///yH5BAEAAAEALAAAAAAHAAcAAAIMjGGJmMH9mHQ0AlYAADs=) no-repeat center}.mce-nbsp,.mce-shy{background:#AAA}.mce-shy::after{content:'-'}.mce-match-marker{background:#AAA;color:#fff}.mce-match-marker-selected{background:#39f;color:#fff}.mce-spellchecker-word{border-bottom:2px solid rgba(208,2,27,.5);cursor:default}.mce-spellchecker-grammar{border-bottom:2px solid green;cursor:default}.mce-item-table,.mce-item-table caption,.mce-item-table td,.mce-item-table th{border:1px dashed #BBB}td[data-mce-selected],th[data-mce-selected]{background-color:#2276d2!important}.mce-edit-focus{outline:1px dotted #333}.mce-content-body [contentEditable=false] [contentEditable=true]:focus{outline:2px solid #2276d2}.mce-content-body [contentEditable=false] [contentEditable=true]:hover{outline:2px solid #2276d2}.mce-content-body [contentEditable=false][data-mce-selected]{outline:2px solid #2276d2}.mce-content-body [data-mce-selected=inline-boundary]{background:#bfe6ff}.mce-content-body .mce-item-anchor[data-mce-selected]{background:#D5D5D5 url(data:image/gif;base64,R0lGODlhBwAHAIABAAAAAP///yH5BAEAAAEALAAAAAAHAAcAAAIMjGGJmMH9mHQ0AlYAADs=) no-repeat center}.mce-content-body hr{cursor:default}.mce-content-body table{-webkit-nbsp-mode:normal}.ephox-snooker-resizer-bar{background-color:#2276d2;opacity:0}.ephox-snooker-resizer-cols{cursor:col-resize}.ephox-snooker-resizer-rows{cursor:row-resize}.ephox-snooker-resizer-bar.ephox-snooker-resizer-bar-dragging{opacity:.2}";
}

@end
