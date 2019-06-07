//
//  eeuiAjaxManager.m
//  WeexTestDemo
//
//  Created by apple on 2018/6/5.
//  Copyright © 2018年 TomQin. All rights reserved.
//

#import "eeuiAjaxManager.h"
#import "AFNetworking.h"
#import "SDImageCache.h"

#define CachaName @"ajax_cache.txt"
#define CacheCancelDate @"cancel_date"
#define CacheData @"cache_data"

@implementation eeuiAjaxManager

+ (eeuiAjaxManager *)sharedIntstance {
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
        self.taskDic = [NSMutableDictionary dictionaryWithCapacity:5];
    }

    return self;
}

- (void)ajax:(NSDictionary*)params callback:(WXModuleKeepAliveCallback)callback
{
    NSString *url = params[@"url"] ? [WXConvert NSString:params[@"url"]] : @"";
    NSString *name = params[@"name"] ? [WXConvert NSString:params[@"name"]] : @"";
    NSString *method = params[@"method"] ? [WXConvert NSString:params[@"method"]] : @"get";
    NSString *dataType = params[@"dataType"] ? [WXConvert NSString:params[@"dataType"]] : @"json";
    NSInteger timeout = params[@"timeout"] ? [WXConvert NSInteger:params[@"timeout"]] : 15000;
    NSInteger cache = params[@"cache"] ? [WXConvert NSInteger:params[@"cache"]] : 0;
    NSDictionary *headers = params[@"headers"] ? params[@"headers"] : @{};
    NSMutableDictionary *data = [NSMutableDictionary dictionaryWithDictionary:params[@"data"] ? params[@"data"] : @{}];
    NSDictionary *files = params[@"files"] ? params[@"files"] : @{};

    NSDictionary *result = @{@"status":@"ready", @"name":name, @"url":url, @"cache":@(NO), @"result":@{}};
    callback(result, YES);

    //网络请求
    NSLog(@"ajax = %@", url);

    //判断缓存
    NSDictionary *cacheResult = [self readFile:url];
    if (cacheResult) {
        NSDictionary *res = @{@"status":@"success", @"name":name, @"url":url, @"cache":@(YES), @"result":cacheResult};
        callback(res, YES);
        return;
    }
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer.timeoutInterval = timeout / 1000;

    if ([dataType isEqualToString:@"json"]) {
        manager.responseSerializer = [AFJSONResponseSerializer serializer];
    } else if ([dataType isEqualToString:@"text"]) {
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html", @"text/plain", nil];
    }

    //设置请求头
    for (NSString *key  in headers.allKeys) {
        NSString *value = [NSString stringWithFormat:@"%@", headers[key]];
        [manager.requestSerializer setValue:value forHTTPHeaderField:key];
    }

    __weak typeof(self) ws = self;

#pragma mark GET
    if ([method compare:@"get"
                options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        NSURLSessionDataTask *dataTask = [manager GET:url parameters:data progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            //NSLog(@"%@\n%@", url, responseObject);
            if (responseObject && [responseObject isKindOfClass:[NSDictionary class]]) {
                if ([[responseObject objectForKey:@"ret"] integerValue] == 1) {
                    //加入缓存
                    if (cache > 0 && [responseObject isKindOfClass:[NSDictionary class]]) {
                        [ws saveFile:responseObject key:url cache:cache];
                    }
                }
            } else {
                responseObject = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
            }
            NSDictionary *res = @{@"status":@"success", @"name":name, @"url":url, @"cache":@(NO), @"result":responseObject};
            callback(res, YES);

            NSDictionary *result2 = @{@"status":@"complete", @"name":name, @"url":url, @"cache":@(NO), @"result":responseObject};
            callback(result2, NO);
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            //NSLog(@"%@", error);
            id result = [[error userInfo] objectForKey:NSLocalizedDescriptionKey];

            NSDictionary *res = @{@"status":@"error", @"name":name, @"url":url, @"cache":@(NO), @"result":result};
            callback(res, YES);

            NSDictionary *result2 = @{@"status":@"complete", @"name":name, @"url":url, @"cache":@(NO), @"result":result};
            callback(result2, NO);
        }];

        [self.taskDic setObject:dataTask forKey:name];

    }
#pragma mark POST
    else if ([method compare:@"post"
                     options:NSCaseInsensitiveSearch] == NSOrderedSame && files.count == 0) {
        NSURLSessionDataTask *dataTask = [manager POST:url parameters:data progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            //NSLog(@"%@\n%@", url, responseObject);
            if (responseObject && [responseObject isKindOfClass:[NSDictionary class]]) {
                if ([[responseObject objectForKey:@"ret"] integerValue] == 1) {
                    NSDictionary *data = responseObject[@"data"];

                    //加入缓存
                    if (cache > 0 && [data isKindOfClass:[NSDictionary class]]) {
                        [ws saveFile:data key:url cache:cache];
                    }
                }
            } else {
                responseObject = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
            }

            NSDictionary *res = @{@"status":@"success", @"name":name, @"url":url, @"cache":@(NO), @"result":responseObject};
            callback(res, YES);

            NSDictionary *result2 = @{@"status":@"complete", @"name":name, @"url":url, @"cache":@(NO), @"result":responseObject};
            callback(result2, NO);
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            //NSLog(@"%@", error);
            id result = [[error userInfo] objectForKey:NSLocalizedDescriptionKey];

            NSDictionary *res = @{@"status":@"error", @"name":name, @"url":url, @"cache":@(NO), @"result":result};
            callback(res, YES);

            NSDictionary *result2 = @{@"status":@"complete", @"name":name, @"url":url, @"cache":@(NO), @"result":result};
            callback(result2, NO);
        }];

        [self.taskDic setObject:dataTask forKey:name];
    }

#pragma mark Upload
    else if (files.count > 0) {
        NSURLSessionDataTask *dataTask = [manager POST:url parameters:data constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
            for (NSString *key in files.allKeys) {
                id obj = files[key];
                if ([obj isKindOfClass:[NSString class]]) {
                    NSString *fileName = files[key];
                    UIImage *image = [UIImage imageWithContentsOfFile:fileName];
                    if (!image) {
                        //缓存
                        NSString *newUrl = [key stringByReplacingOccurrencesOfString:@"file://" withString:@""];
                        image = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:newUrl];
                    }
                    NSData *data = UIImagePNGRepresentation(image);
                    [formData appendPartWithFileData:data
                                                name:key
                                            fileName:fileName
                                            mimeType:@"image/png"];
                } else if ([obj isKindOfClass:[NSArray class]]) {
                    for (NSInteger i = 0; i < [obj count]; i++) {
                        NSString *fileName = obj[i];
                        UIImage *image = [UIImage imageWithContentsOfFile:fileName];
                        if (!image) {
                            //缓存
                            NSString *newUrl = [fileName stringByReplacingOccurrencesOfString:@"file://" withString:@""];
                            image = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:newUrl];
                        }
                        NSString *name = [NSString stringWithFormat:@"%@[%ld]", key, i];
                        NSData *data = UIImagePNGRepresentation(image);
                        [formData appendPartWithFileData:data
                                                    name:name
                                                fileName:fileName
                                                mimeType:@"image/jpeg"];
                    }
                }
            }
        } progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            //NSLog(@"%@", responseObject);
            NSDictionary *res = @{@"status":@"success", @"name":name, @"url":url, @"cache":@(NO), @"result":responseObject};
            callback(res, YES);

            NSDictionary *result2 = @{@"status":@"complete", @"name":name, @"url":url, @"cache":@(NO), @"result":@{}};
            callback(result2, NO);
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            //NSLog(@"%@", error);
            id result = [[error userInfo] objectForKey:NSLocalizedDescriptionKey];

            NSDictionary *res = @{@"status":@"error", @"name":name, @"url":url, @"cache":@(NO), @"result":result};
            callback(res, YES);

            NSDictionary *result2 = @{@"status":@"complete", @"name":name, @"url":url, @"cache":@(NO), @"result":result};
            callback(result2, NO);
        }];

        [self.taskDic setObject:dataTask forKey:name];
    }
}


- (void)ajaxCancel:(NSString*)name
{
    id task = [self.taskDic objectForKey:name];
    if ([task isKindOfClass:[NSURLSessionTask class]]) {
        [(NSURLSessionTask*)task cancel];
    }
}

- (void)getCacheSizeAjax:(WXModuleKeepAliveCallback)callback
{
    NSString *paths = [NSString stringWithFormat:@"%@/%@", NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject, CachaName];

    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSInteger size = 0;
    if ([fileManager fileExistsAtPath:paths])
    {
        size = [[fileManager attributesOfItemAtPath:paths error:nil] fileSize];
    }

    callback(@{@"size":@(size)}, NO);
}

- (void)clearCacheAjax
{
    NSString *paths = [NSString stringWithFormat:@"%@/%@", NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject, CachaName];

    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:paths]) {
        [fileManager removeItemAtPath:paths error:nil];
    }
}

#pragma mark
- (void)saveFile:(NSDictionary*)dic key:(NSString*)key cache:(NSInteger)cache
{
    NSString *paths = [NSString stringWithFormat:@"%@/%@", NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject, CachaName];

    //    if (![[NSFileManager defaultManager] fileExistsAtPath:paths]) {
    //        [[NSFileManager defaultManager] createDirectoryAtPath:paths withIntermediateDirectories:YES attributes:nil error:nil];//创建文件夹
    //    }
    NSInteger time = [[NSDate date] timeIntervalSince1970] + cache * 1.0f / 1000;
    NSDictionary *saveDic = @{key:@{CacheCancelDate : @(time), CacheData: dic}};
    NSData *data = [NSJSONSerialization dataWithJSONObject:saveDic options:NSJSONWritingPrettyPrinted error:nil];

    [[NSFileManager defaultManager] createFileAtPath:paths contents:data attributes:nil];
}

- (NSDictionary*)readFile:(NSString*)name
{
    NSString *paths = [NSString stringWithFormat:@"%@/%@", NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject, CachaName];
    id data = [NSData dataWithContentsOfFile:paths options:0 error:NULL];
    if (data) {
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];

        if (dic && [dic isKindOfClass:[NSDictionary class]]) {
            id result = [dic objectForKey:name];
            if (result && [result isKindOfClass:[NSDictionary class]]) {
                //先判断是否过期
                NSInteger time = [[result objectForKey:CacheCancelDate] integerValue];
                NSDate *date = [NSDate dateWithTimeIntervalSince1970:time];

                if ([date compare:[NSDate date]] == NSOrderedDescending) {
                    return [result objectForKey:CacheData];
                }
            }
        }
    }

    return nil;
}


@end
