//
//  eeuiStorageManager.m
//  WeexTestDemo
//
//  Created by apple on 2018/6/7.
//  Copyright © 2018年 TomQin. All rights reserved.
//

#import "eeuiStorageManager.h"

#define kStorageExpired @"storage_expired"
#define kStorageCaches @"storage_caches"
#define kStorageVariate @"storage_variate"

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
    }

    return self;
}

- (void)setCachesString:(NSString*)key value:(id)value expired:(NSInteger)expired
{
    if (key && value) {
        NSInteger time = expired == 0 ? 0 : [[NSDate date] timeIntervalSince1970] + expired;
        NSDictionary *saveDic = @{kStorageExpired:@(time), key:value};
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

- (id)getCachesString:(NSString*)key defaultVal:(id)defaultVal
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
                if (value) {
                    return value;
                }
            }
        }
    }
    return defaultVal;
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


@end
