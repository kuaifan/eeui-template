//
//  Config.m
//  eeuiProject
//
//  Created by 高一 on 2018/9/27.
//

#import "Config.h"
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
    NSString *str = [NSString stringWithFormat:@"%@", json[key]];
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
    NSMutableDictionary *json = [self get];
    if (json == nil) {
        return nil;
    }
    return [json objectForKey:key];
}

//获取主页地址
+ (NSString *) getHome
{
    NSString *homePage = [self getString:@"homePage" defaultVal:@""];
    if (homePage.length == 0) {
        homePage = [NSString stringWithFormat:@"file://%@", [self getResourcePath:@"bundlejs/eeui/pages/index.js"]];
    }
    return homePage;
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
    long localVersion = (long)[Config getLocalVersion];

    if (verifyDir == nil) {
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

    NSString *newUrl = @"";
    for (NSString * dirName in verifyDir) {
        NSString *tempPath = [NSString stringWithFormat:@"%@/%@/%@", path, dirName, originalPath];
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
