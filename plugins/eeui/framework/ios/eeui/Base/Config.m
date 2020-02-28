//
//  Config.m
//  eeuiProject
//
//  Created by 高一 on 2018/9/27.
//

#import "Config.h"
#import "IpUtil.h"
#import "DeviceUtil.h"
#import "eeuiStorageManager.h"
#import "eeuiNewPageManager.h"
#import "eeuiCachesManager.h"
#import "eeuiAjaxManager.h"
#import <CommonCrypto/CommonDigest.h>

@implementation Config

static NSMutableDictionary *configData;
static NSMutableArray *verifyDir;

//读取配置
+ (NSMutableDictionary *) get
{
    //读取json
    if (configData == nil) {
        NSString *jsonFile = [self verifyFile:[self getResourcePath:@"bundlejs/eeui/config.json"]];
        NSData *fileData = [[ NSData alloc ] initWithContentsOfFile :jsonFile];
        NSDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:fileData options:kNilOptions error:nil];
        configData = [NSMutableDictionary dictionaryWithDictionary:jsonObject];
    }
    //自定义配置
    [[self getCustomConfig] enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        [configData setValue:obj forKey:key];
    }];
    return configData;
}

//清除配置
+ (void) clear
{
    configData = nil;
    verifyDir = nil;
}

//获取配置值
+ (NSString *) getString:(NSString*)key defaultVal:(NSString *)defaultVal
{
    NSMutableDictionary *json = [self get];
    if (json == nil) {
        return defaultVal;
    }
    NSString *str = nil;
    id rawValue = [self getRawValue:key];
    if ([rawValue isKindOfClass:[NSDictionary class]]) {
       str = [DeviceUtil dictionaryToJson:(NSDictionary *)rawValue];
    }else{
       str = [NSString stringWithFormat:@"%@", rawValue];
    }
    if (str == nil) {
        return defaultVal;
    }
    if ([str isEqual:[NSNull null]] || [str isEqualToString:@"(null)"]) {
        return defaultVal;
    }
    if (!str.length) {
        return defaultVal;
    }
    return str;
}

//获取配置值
+ (NSMutableDictionary *) getObject:(NSString*)key
{
    return [self getRawValue:key];
}

//获取配置原始值
+ (id) getRawValue:(NSString*)key
{
    NSMutableDictionary *json = [self get];
    if (json == nil) {
        return nil;
    }
    return [json objectForKey:key];
}

//获取主页地址
+ (void) getHomeUrl:(void(^)(NSString* path))callback
{
    NSString *socketHome = [self getString:@"socketHome" defaultVal:@""];
    NSString *homePage = [self getString:@"homePage" defaultVal:@""];
    if (homePage.length == 0) {
        homePage = [NSString stringWithFormat:@"file://%@", [self getResourcePath:@"bundlejs/eeui/pages/index.js"]];
    }else{
        homePage = [DeviceUtil suffixUrl:@"app" url:homePage];
        homePage = [DeviceUtil rewriteUrl:homePage homePage:[NSString stringWithFormat:@"file://%@", [self getResourcePath:@"bundlejs/eeui/pages/index.js"]]];
    }
    #if DEBUG
    #else
        socketHome = @"";
    #endif
    if (socketHome.length == 0) {
        callback(homePage);
        return;
    }
    NSURL *socketURL = [NSURL URLWithString:socketHome];
    NSRange lastRange = [[socketURL host] rangeOfString:@"." options:NSBackwardsSearch];
    BOOL isLip = NO;
    if (lastRange.location != NSNotFound) {
        NSString *socketHostTo = [[socketURL host] substringToIndex:lastRange.location];
        NSArray *ipLists = [IpUtil getLocalIPAddressIPv4Lists];
        for (NSString *ipv in ipLists) {
            if ([ipv hasPrefix:socketHostTo]) {
                isLip = YES;
                break;
            }
        }
    }
    if (!isLip) {
        callback(homePage);
        return;
    }
    //
    NSString *newUrlHome = [[NSString alloc] initWithFormat:@"%@%@%@", socketHome, [socketHome rangeOfString:@"?"].length > 0 ? @"&" : @"?", @"preload=preload"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:newUrlHome]];
    [request setTimeoutInterval:2.0];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *downloadTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (!error) {
            NSString *content = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSDictionary *jsonData = [DeviceUtil dictionaryWithJsonString:content];
            if (jsonData != nil) {
                //
                if ([jsonData[@"appboards"] isKindOfClass:[NSArray class]]) {
                    NSArray *appboards = jsonData[@"appboards"];
                    if ([appboards count] > 0) {
                        for (NSDictionary *appboardItem in appboards) {
                            [DeviceUtil setAppboardWifi:appboardItem[@"path"] content:appboardItem[@"content"]];
                        }
                    }
                }
                //
                NSRange range = [jsonData[@"body"] rangeOfString:@"^//\\s*\\{\\s*\"framework\"\\s*:\\s*\"Vue\"\\s*\\}" options:NSRegularExpressionSearch];
                if (range.location != NSNotFound) {
                    callback(socketHome);
                    return;
                }
            }
        }
        callback(homePage);
    }];
    [downloadTask resume];
}

//获取主页配置值
+ (NSString *) getHomeParams:(NSString*)key defaultVal:(NSString *)defaultVal
{
    NSDictionary *params = [self getObject:@"homePageParams"];
    if (params == nil) {
        return defaultVal;
    }
    NSString *str = [NSString stringWithFormat:@"%@", params[key]];
    if (str == nil) {
        return defaultVal;
    }
    if ([str isEqual:[NSNull null]] || [str isEqualToString:@"(null)"]) {
        return defaultVal;
    }
    if (!str.length) {
        return defaultVal;
    }
    return str;
}

//转换修复文件路径
+ (NSString *) verifyFile:(NSString*)originalUrl
{
    if (originalUrl == nil ||
        [originalUrl hasPrefix:@"http://"] ||
        [originalUrl hasPrefix:@"https://"] ||
        [originalUrl hasPrefix:@"ftp://"] ||
        [originalUrl hasPrefix:@"data:image/"]) {
        return originalUrl;
    }

    BOOL isFilePre = NO;
    NSString *rootPath = [self getResourcePath:@"bundlejs/eeui"];
    if (![originalUrl hasPrefix:rootPath]) {
        isFilePre = YES;
        rootPath = [NSString stringWithFormat:@"file://%@", rootPath];
        if (![originalUrl hasPrefix:rootPath]) {
            return originalUrl;
        }
    }
    rootPath = [NSString stringWithFormat:@"%@/", rootPath];

    NSString *originalPath = [originalUrl stringByReplacingOccurrencesOfString:rootPath withString:@""];
    NSString *path = [Config getSandPath:@"update"];

    NSFileManager *myFileManager = [NSFileManager defaultManager];
    BOOL isDir = NO;
    BOOL isExist = NO;

    NSString *newUrl = @"";
    NSMutableArray *tempArray = [self verifyData];
    for (NSString * dirName in tempArray) {
        NSString *tempPath = [NSString stringWithFormat:@"%@/%@/%@", path, dirName, [self getPathname:originalPath]];
        isExist = [myFileManager fileExistsAtPath:tempPath isDirectory:&isDir];
        if (isExist && !isDir) {
            newUrl = [NSString stringWithFormat:@"%@%@", isFilePre ? @"file://" : @"", tempPath];;
            break;
        }
    }

    if (newUrl.length == 0) {
        return originalUrl;
    }
    return newUrl;
}

+ (NSString*) getPathname:(NSString*)url
{
    if (url.length > 0) {
        NSRange range;
        range = [url rangeOfString:@"?"];
        if (range.location != NSNotFound) {
            url = [url substringToIndex:range.location];
        }
    }
    return url;
}

+ (NSMutableArray*) verifyData
{
    if (verifyDir == nil) {
        NSString *path = [Config getSandPath:@"update"];
        NSFileManager *myFileManager = [NSFileManager defaultManager];
        BOOL isDir = NO;
        BOOL isExist = NO;
        long localVersion = (long)[Config getLocalVersion];
        //
        verifyDir = [NSMutableArray array];
        NSArray *tmpArray = [myFileManager contentsOfDirectoryAtPath:path error:nil];
        for (NSString * dirName in tmpArray) {
            isExist = [myFileManager fileExistsAtPath:[NSString stringWithFormat:@"%@/%@", path, dirName] isDirectory:&isDir];
            if (isDir) {
                isExist = [myFileManager fileExistsAtPath:[NSString stringWithFormat:@"%@/%@/%ld.release", path, dirName, localVersion] isDirectory:&isDir];
                if (isExist && !isDir) {
                    [verifyDir addObject:dirName];
                }
            }
        }
        [verifyDir sortUsingComparator:^NSComparisonResult(id _Nonnull obj1, id _Nonnull obj2) {
            if ([obj1 integerValue] < [obj2 integerValue]) {
                return NSOrderedDescending;
            } else {
                return NSOrderedAscending;
            }
        }];
    }
    return verifyDir;
}

//是否有升级文件
+ (BOOL) verifyIsUpdate
{
    BOOL isDir = NO;
    BOOL isExist = NO;
    BOOL isUpdate = NO;
    NSString *path = [Config getSandPath:@"update"];
    NSFileManager *myFileManager = [NSFileManager defaultManager];
    NSArray *tmpArray = [myFileManager contentsOfDirectoryAtPath:path error:nil];
    for (NSString * dirName in tmpArray) {
        isExist = [myFileManager fileExistsAtPath:[NSString stringWithFormat:@"%@/%@", path, dirName] isDirectory:&isDir];
        if (isDir) {
            isUpdate = YES;
            break;
        }
    }
    return isUpdate;
}

//设置自定义配置
+ (void) setCustomConfig:(NSString*)key value:(id)value
{
    NSMutableDictionary *json = [[self getCustomConfig] mutableCopy];
    if (json == nil) {
        return;
    }
    if ([value isKindOfClass:[NSString class]]) {
        [json setValue:[WXConvert NSString:value] forKey:key];
    } else if ([value isKindOfClass:[NSNumber class]]) {
        [json setValue:@([WXConvert NSInteger:value]) forKey:key];
    } else if ([value isKindOfClass:[NSDictionary class]]) {
        [json setValue:value forKey:key];
    } else {
        return;
    }
    [json setValue:@([[NSDate date] timeIntervalSince1970]) forKey:@"__system:eeui:customTime"];
    [[eeuiStorageManager sharedIntstance] setCachesString:@"__system:eeui:customConfig" value:[DeviceUtil dictionaryToJson:json] expired:0];
}

//获取自定义配置
+ (NSDictionary *) getCustomConfig
{
    NSDictionary *json = [DeviceUtil dictionaryWithJsonString:[[eeuiStorageManager sharedIntstance] getCachesString:@"__system:eeui:customConfig" defaultVal:@"{}"]];
    if (json == nil) {
        return [NSMutableDictionary dictionary];
    }else{
        return json;
    }
}

//清空自定义配置
+ (void) clearCustomConfig
{
    [[eeuiStorageManager sharedIntstance] setCachesString:@"__system:eeui:customConfig" value:[DeviceUtil dictionaryToJson:@{}] expired:0];
}

//清除缓存
+ (void) clearCache
{
    [Config clearCustomConfig];
    [[eeuiCachesManager sharedIntstance] clearCacheDir:nil];
    [[eeuiNewPageManager sharedIntstance] clearCachePage];
    [[eeuiAjaxManager sharedIntstance] clearCacheAjax];
}

//******************************************************************************************
//******************************************************************************************
//******************************************************************************************


//获取资源路径
+ (NSString *) getResourcePath:(NSString*)name
{
    return [[ NSBundle mainBundle ] pathForResource : name ofType : nil ];
}

//获取沙盘路径
+ (NSString *) getSandPath:(NSString*)name
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return [[NSString alloc] initWithFormat:@"%@/%@/%@", [paths objectAtIndex:0], [[NSBundle mainBundle]bundleIdentifier], name];
}

//获取版本号
+ (NSInteger) getLocalVersion
{
    NSString *version = [[[NSBundle mainBundle] infoDictionary]  objectForKey:@"CFBundleVersion"];
    NSArray *list = [version componentsSeparatedByString:@"."];
    if (list.count > 0) {
        return [list.lastObject integerValue];
    } else {
        return [version integerValue];
    }
}

//获取版本名称
+ (NSString*) getLocalVersionName
{
    return (NSString*)[[[NSBundle mainBundle] infoDictionary]  objectForKey:@"CFBundleShortVersionString"];
}

//文件是否存在
+ (BOOL) isFileExists:(NSString*)path
{
    if ([[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:nil]) {
        return YES;
    }
    return NO;
}

//判断是否文件（不存在返回NO）
+ (BOOL) isFile:(NSString*)path
{
    BOOL isDir;
    if (![[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir]) {
        return NO;
    }
    if (isDir) {
        return NO;
    }else{
        return YES;
    }
}

//判断是否文件夹（不存在返回NO）
+ (BOOL) isDir:(NSString*)path
{
    BOOL isDir;
    if (![[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir]) {
        return NO;
    }
    if (isDir) {
        return YES;
    }else{
        return NO;
    }
}

//获取系统当前时间
+ (NSString *) getyyyMMddHHmmss
{
    NSDate * date = [NSDate date];
    NSTimeInterval sec = [date timeIntervalSinceNow];
    NSDate * currentDate = [[NSDate alloc] initWithTimeIntervalSinceNow:sec];
    NSDateFormatter * df = [[NSDateFormatter alloc] init ];
    [df setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    return [df stringFromDate:currentDate];
}

//MD5加密32位大写
+ (NSString *) MD5ForLower32Bate:(NSString *)str
{
    const char* input = [str UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(input, (CC_LONG)strlen(input), result);
    NSMutableString *digest = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for (NSInteger i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [digest appendFormat:@"%02X", result[i]];
    }
    return digest;
}

//获取中间字符串
+ (NSString *) getMiddle:(NSString *)string start:(nullable NSString *)startString to:(nullable NSString *)endString {
    NSString *text = string;
    if (text.length) {
        if (startString != nil && startString.length && [text containsString:startString]) {
            NSRange startRange = [text rangeOfString:startString];
            NSRange range = NSMakeRange(startRange.location + startRange.length, text.length - startRange.location - startRange.length);
            text = [text substringWithRange:range];
        }
        if (endString != nil && endString.length && [text containsString:endString]) {
            NSRange endRange = [text rangeOfString:endString];
            NSRange range = NSMakeRange(0, endRange.location);
            text = [text substringWithRange:range];
        }
    }
    return text;
}

@end
