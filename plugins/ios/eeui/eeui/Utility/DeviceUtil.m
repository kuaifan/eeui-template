//
//  DeviceUtil.m
//  WeexTestDemo
//
//  Created by apple on 2018/6/5.
//  Copyright © 2018年 TomQin. All rights reserved.
//

#import "DeviceUtil.h"
#import "WeexSDKManager.h"
#import "WeexSDK.h"
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

//重写url
+ (NSString*)rewriteUrl:(NSString*)url
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

    NSString *topUrl = [[WeexSDKManager sharedIntstance] weexUrl];
    eeuiViewController *top = (eeuiViewController *)[self getTopviewControler];
    if (top && top.url) {
        topUrl = top.url;
    }
    if (topUrl.length <= 0) {
        return [self realUrl:url];
    }
    
    if ([url hasPrefix:@"root://"]) {
        NSString *tempUrl = [NSString stringWithFormat:@"file://%@", [Config getResourcePath:@"bundlejs"]];
        if ([topUrl hasPrefix:tempUrl]) {
            return [self realUrl:[NSString stringWithFormat:@"%@/eeui/%@", tempUrl, [url substringFromIndex:7]]];
        }else{
            url = [NSString stringWithFormat:@"/%@", [url substringFromIndex:7]];
        }
    }else if ([url hasPrefix:@"root:"]) {
        NSString *tempUrl = [NSString stringWithFormat:@"file://%@", [Config getResourcePath:@"bundlejs"]];
        if ([topUrl hasPrefix:tempUrl]) {
            return [self realUrl:[NSString stringWithFormat:@"%@/eeui/%@", tempUrl, [url substringFromIndex:5]]];
        }else{
            url = [NSString stringWithFormat:@"/%@", [url substringFromIndex:5]];
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

    NSURL *URL = [NSURL URLWithString:topUrl];
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
        if ([topUrl hasPrefix:rootPath]) {
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
    NSString *appboard = @"";
    for (NSString *key in mAppboardContent) {
        NSString *value = mAppboardContent[key];
        if (value.length > 0) {
            appboard = [NSString stringWithFormat:@"%@%@;", appboard, value];
        }
    }
    if (appboard.length > 0) {
        if (![appboard hasPrefix:@"// { \"framework\": \"Vue\"}"]) {
            appboard = [NSString stringWithFormat:@"%@%@", @"// { \"framework\": \"Vue\"}\nif(typeof app==\"undefined\"){app=weex}\n", appboard];
        }
    }
    return appboard;
}

//设置Appboard内容
+ (void)setAppboardContent:(NSString *)key content:(NSString *)content
{
    if (mAppboardContent == nil) {
        mAppboardContent = [NSMutableDictionary dictionary];
    }
    [mAppboardContent setValue:content forKey:key];
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

@end
