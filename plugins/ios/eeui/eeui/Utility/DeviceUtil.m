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
    return url;
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

//重写url
+ (NSString*)rewriteUrl:(NSString*)url
{
    //和安卓同步，处理本地图片file重复问题
    if ([url hasPrefix:@"file://file://"]) {
        return [url stringByReplacingOccurrencesOfString:@"file://file://" withString:@"file://"];
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
        if ([url containsString:@"/./"]) {
            url = [url stringByReplacingOccurrencesOfString:@"/./" withString:@"/"];
        }
        return url;
    }

    NSString *topUrl = [[WeexSDKManager sharedIntstance] weexUrl];
    eeuiViewController *top = (eeuiViewController *)[self getTopviewControler];
    if (top && top.url) {
        topUrl = top.url;
    }

    NSURL *URL = [NSURL URLWithString:topUrl];
    NSString *scheme = [URL scheme];
    NSString *host = [URL host];
    NSInteger port = [[URL port] integerValue];
    NSString *path = [URL path];

    if (scheme == nil) scheme = @"";
    if (host == nil) host = @"";

    NSString *newUrl = [NSString stringWithFormat:@"%@://%@%@", scheme, host, port > 0 && port != 80 ? [NSString stringWithFormat:@":%ld", (long)port] : @""];
    if ([url isAbsolutePath]) {
        newUrl = [newUrl stringByAppendingString:url];
    } else {
        if ([path isEqualToString:@"/"]) {
            path = @"";
        } else {
            path = [path stringByDeletingLastPathComponent];
        }
        newUrl = [NSString stringWithFormat:@"%@%@/%@", newUrl, path, url];
    }

    if ([newUrl containsString:@"/./"]) {
        newUrl = [newUrl stringByReplacingOccurrencesOfString:@"/./" withString:@"/"];
    }
    return newUrl;
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

@end
