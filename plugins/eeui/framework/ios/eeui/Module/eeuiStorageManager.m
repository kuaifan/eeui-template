//
//  eeuiStorageManager.m
//  WeexTestDemo
//
//  Created by apple on 2018/6/7.
//  Copyright © 2018年 TomQin. All rights reserved.
//

#import "eeuiStorageManager.h"
#import "DeviceUtil.h"

#define kStorageExpired @"storage_expired"
#define kStorageCaches @"storage_caches"
#define kStorageVariate @"storage_variate"
#define kStorageScriptUrl @"storage_script_url"

@implementation eeuiStorageManager

+ (eeuiStorageManager *)sharedIntstance {
    static dispatch_once_t once;
    static id instance;
    dispatch_once(&once, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init
{
    if (self = [super init]) {
        self.variateDic = [NSMutableDictionary dictionaryWithCapacity:5];
        self.pageScriptUrlDic = [NSMutableDictionary dictionaryWithCapacity:5];
    }

    return self;
}

- (void)setCaches:(NSString*)key value:(id)value expired:(NSInteger)expired
{
    if (key && value) {
        NSInteger time = expired == 0 ? 0 : [[NSDate date] timeIntervalSince1970] + expired;
        NSDictionary *saveDic = @{kStorageExpired:@(time), key:[DeviceUtil dictionaryToJson:@{@"value":value}], @"version":@(2)};
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        id data = [userDefaults objectForKey:kStorageCaches];
        NSMutableDictionary *mDic;
        if (!data) {
            mDic = [NSMutableDictionary dictionaryWithCapacity:5];
        } else {
            mDic = [NSMutableDictionary dictionaryWithDictionary:data];
        }
        [mDic setObject:saveDic forKey:key];
        [userDefaults setObject:mDic forKey:kStorageCaches];
        [userDefaults synchronize];
    }
}

- (id)getCaches:(NSString*)key defaultVal:(id)defaultVal
{
    id data = [[NSUserDefaults standardUserDefaults] objectForKey:kStorageCaches];
    if (data && [data isKindOfClass:[NSDictionary class]]) {
        id dic = [data objectForKey:key];
        if (dic && [dic isKindOfClass:[NSDictionary class]]) {
            NSInteger time = [WXConvert NSInteger:dic[kStorageExpired]];
            NSDate *date = [NSDate dateWithTimeIntervalSince1970:time];
            if ([date compare:[NSDate date]] == NSOrderedDescending || time == 0) {
                //有效时间内或没有限时
                id value = [dic objectForKey:key];
                if ([WXConvert NSInteger:dic[@"version"]] == 2) {
                    NSDictionary* obj = [DeviceUtil dictionaryWithJsonString:value];
                    value = obj[@"value"];
                }
                if (value) {
                    return value;
                }
            }
        }
    }
    return defaultVal;
}

- (void)setCachesString:(NSString*)key value:(NSString*)value expired:(NSInteger)expired
{
    [self setCaches:key value:value expired:expired];
}

- (NSString*)getCachesString:(NSString*)key defaultVal:(NSString*)defaultVal
{
    return [WXConvert NSString:[self getCaches:key defaultVal:defaultVal]];
}

- (id)getAllCaches
{
    id data = [[NSUserDefaults standardUserDefaults] objectForKey:kStorageCaches];
    if (data && [data isKindOfClass:[NSDictionary class]]) {
        NSMutableDictionary *json = [[NSMutableDictionary alloc] init];
        [data enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            NSString *name = [WXConvert NSString:key];
            if (obj && [obj isKindOfClass:[NSDictionary class]] && name && ![name hasPrefix:@"__system:"]) {    //获取缓存过滤系统缓存
                NSInteger time = [WXConvert NSInteger:obj[kStorageExpired]];
                NSDate *temp = [NSDate dateWithTimeIntervalSince1970:time];
                if ([temp compare:[NSDate date]] == NSOrderedDescending || time == 0) {
                    [json setValue:obj[name] forKey:name];
                }
            }
        }];
        return json;
    }
    return @{};
}

- (void)clearAllCaches
{
    id data = [[NSUserDefaults standardUserDefaults] objectForKey:kStorageCaches];
    if (data && [data isKindOfClass:[NSDictionary class]]) {
        NSMutableDictionary *json = [[NSMutableDictionary alloc] init];
        [data enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            NSString *name = [WXConvert NSString:key];
            if (obj && [obj isKindOfClass:[NSDictionary class]] && name && [name hasPrefix:@"__system:"]) {     //清空缓存保留系统缓存
                NSInteger time = [WXConvert NSInteger:obj[kStorageExpired]];
                NSDate *temp = [NSDate dateWithTimeIntervalSince1970:time];
                if ([temp compare:[NSDate date]] == NSOrderedDescending || time == 0) {
                    [json setValue:obj[name] forKey:name];
                }
            }
        }];
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:json forKey:kStorageCaches];
        [userDefaults synchronize];
    }
}

- (void)setVariate:(NSString*)key value:(id)value
{
    if (key && value) {
        id data = [[eeuiStorageManager sharedIntstance].variateDic objectForKey:kStorageVariate];
        NSMutableDictionary *mDic;
        if (!data) {
            mDic = [NSMutableDictionary dictionaryWithCapacity:5];
        } else {
            mDic = [NSMutableDictionary dictionaryWithDictionary:data];
        }
        [mDic setObject:value forKey:key];
        [[eeuiStorageManager sharedIntstance].variateDic setObject:mDic forKey:kStorageVariate];
    }
}

- (id)getVariate:(NSString*)key defaultVal:(id)defaultVal
{
    id data = [[eeuiStorageManager sharedIntstance].variateDic objectForKey:kStorageVariate];
    if (data && [data isKindOfClass:[NSDictionary class]]) {
        id value = [data objectForKey:key];
        if (value) {
            return value;
        }
    }
    return defaultVal;
}

- (id)getAllVariate
{
    id data = [[eeuiStorageManager sharedIntstance].variateDic objectForKey:kStorageVariate];
    if (data && [data isKindOfClass:[NSDictionary class]]) {
        return data;
    }
    return @{};
}

- (void)clearAllVariate
{
    [[eeuiStorageManager sharedIntstance].variateDic setObject:@{} forKey:kStorageVariate];
}

- (void)setPageScriptUrl:(NSString*)scriptURL url:(NSString*)url
{
    if (scriptURL && url) {
        id data = [[eeuiStorageManager sharedIntstance].pageScriptUrlDic objectForKey:kStorageScriptUrl];
        NSMutableDictionary *mDic;
        if (!data) {
            mDic = [NSMutableDictionary dictionaryWithCapacity:5];
        } else {
            mDic = [NSMutableDictionary dictionaryWithDictionary:data];
        }
        [mDic setObject:url forKey:scriptURL];
        [[eeuiStorageManager sharedIntstance].pageScriptUrlDic setObject:mDic forKey:kStorageScriptUrl];
    }
}

- (NSString *)getPageScriptUrl:(NSString*)scriptURL defaultVal:(NSString*)defaultVal
{
    id data = [[eeuiStorageManager sharedIntstance].pageScriptUrlDic objectForKey:kStorageScriptUrl];
    if (data && [data isKindOfClass:[NSDictionary class]]) {
        id value = [data objectForKey:scriptURL];
        if (value) {
            return value;
        }
    }
    return defaultVal;
}

@end
