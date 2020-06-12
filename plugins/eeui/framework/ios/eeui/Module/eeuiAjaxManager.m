//
//  eeuiAjaxManager.m
//  WeexTestDemo
//
//  Created by apple on 2018/6/5.
//  Copyright © 2018年 TomQin. All rights reserved.
//

#import <CoreServices/CoreServices.h>
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
    BOOL beforeAfter = params[@"beforeAfter"] ? [WXConvert BOOL:params[@"beforeAfter"]] : NO;
    BOOL progressCall = params[@"progressCall"] ? [WXConvert BOOL:params[@"progressCall"]] : NO;
    NSDictionary *headers = params[@"headers"] ? params[@"headers"] : @{};
    NSMutableDictionary *data = [NSMutableDictionary dictionaryWithDictionary:params[@"data"] ? params[@"data"] : @{}];
    NSDictionary *files = params[@"files"] ? params[@"files"] : @{};

    if (name.length == 0) {
        name = [NSString stringWithFormat:@"ajax-%d", (arc4random() % 100) + 1000];
    }

    if (callback == nil) {
        callback = ^(id result, BOOL keepAlive) { };
    }
    
    if (beforeAfter) {
        NSDictionary *result = @{
            @"status":@"ready",
            @"name":name,
            @"url":url,
            @"cache":@(NO),
            @"code":@(0),
            @"headers":@{},
            @"result":@{}
        };
        callback(result, YES);
    }

    //网络请求
    EELog(@"ajax = %@", url);

    //判断缓存
    NSDictionary *cacheResult = [self readFile:url];
    if (cacheResult) {
        NSDictionary *res = @{
            @"status":@"success",
            @"name":name,
            @"url":url,
            @"cache":@(YES),
            @"code":@(200),
            @"headers":@{},
            @"result":cacheResult
        };
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
    if ([@"application/json" isEqual: headers[@"Content-Type"]]) {
        //设置请求体数据为json类型
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
    }
    for (NSString *key  in headers.allKeys) {
        NSString *value = [NSString stringWithFormat:@"%@", headers[key]];
        [manager.requestSerializer setValue:value forHTTPHeaderField:key];
    }

    __weak typeof(self) ws = self;

#pragma mark GET
    if ([method compare:@"get" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        NSURLSessionDataTask *dataTask = [manager GET_EEUI:url parameters:data headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject, NSInteger resCode, NSDictionary *resHeaders) {
            //EELog(@"%@\n%@", url, responseObject);
            if (resCode == 200 && cache > 0) {
                [ws saveFile:responseObject key:url cache:cache];
            }
            if (responseObject && [responseObject isKindOfClass:[NSDictionary class]]) {
                //
            } else if (responseObject && [responseObject isKindOfClass:[NSArray class]]) {
                //
            } else {
                responseObject = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
            }
            NSDictionary *res = @{
                @"status":@"success",
                @"name":name,
                @"url":url,
                @"cache":@(NO),
                @"code":@(resCode),
                @"headers":resHeaders,
                @"result":responseObject==nil?@{}:responseObject
            };
            callback(res, beforeAfter ? YES : NO);
            
            if (beforeAfter) {
                NSDictionary *result2 = @{
                    @"status":@"complete",
                    @"name":name,
                    @"url":url,
                    @"cache":@(NO),
                    @"code":@(0),
                    @"headers":@{},
                    @"result":responseObject==nil?@{}:responseObject
                };
                callback(result2, NO);
            }
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            //EELog(@"%@", error);
            id result = [[error userInfo] objectForKey:NSLocalizedDescriptionKey];
            NSHTTPURLResponse *errorData = [[error userInfo] objectForKey:AFNetworkingOperationFailingURLResponseErrorKey];

            NSDictionary *res = @{
                @"status":@"error",
                @"name":name,
                @"url":url,
                @"cache":@(NO),
                @"code":errorData==nil?@(0):@([errorData statusCode]),
                @"headers":errorData==nil?@{}:[errorData allHeaderFields],
                @"result":result==nil?@{}:result
            };
            callback(res, beforeAfter ? YES : NO);

            if (beforeAfter) {
                NSDictionary *result2 = @{
                    @"status":@"complete",
                    @"name":name,
                    @"url":url,
                    @"cache":@(NO),
                    @"code":@(0),
                    @"headers":@{},
                    @"result":result==nil?@{}:result
                };
                callback(result2, NO);
            }
        }];
        [self.taskDic setObject:dataTask forKey:name];
    }
#pragma mark POST
    else if ([method compare:@"post" options:NSCaseInsensitiveSearch] == NSOrderedSame && files.count == 0) {
        NSURLSessionDataTask *dataTask = [manager POST_EEUI:url parameters:data headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject, NSInteger resCode, NSDictionary *resHeaders) {
            //EELog(@"%@\n%@", url, responseObject);
            if (resCode == 200 && cache > 0) {
                [ws saveFile:responseObject key:url cache:cache];
            }
            if (responseObject && [responseObject isKindOfClass:[NSDictionary class]]) {
                //
            } else if (responseObject && [responseObject isKindOfClass:[NSArray class]]) {
                //
            } else {
                responseObject = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
            }

            NSDictionary *res = @{
                @"status":@"success",
                @"name":name,
                @"url":url,
                @"cache":@(NO),
                @"code":@(resCode),
                @"headers":resHeaders,
                @"result":responseObject==nil?@{}:responseObject
            };
            callback(res, beforeAfter ? YES : NO);

            if (beforeAfter) {
                NSDictionary *result2 = @{
                    @"status":@"complete",
                    @"name":name,
                    @"url":url,
                    @"cache":@(NO),
                    @"code":@(0),
                    @"headers":@{},
                    @"result":responseObject==nil?@{}:responseObject
                };
                callback(result2, NO);
            }
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            //EELog(@"%@", error);
            id result = [[error userInfo] objectForKey:NSLocalizedDescriptionKey];
            NSHTTPURLResponse *errorData = [[error userInfo] objectForKey:AFNetworkingOperationFailingURLResponseErrorKey];
            
            NSDictionary *res = @{
                @"status":@"error",
                @"name":name,
                @"url":url,
                @"cache":@(NO),
                @"code":errorData==nil?@(0):@([errorData statusCode]),
                @"headers":errorData==nil?@{}:[errorData allHeaderFields],
                @"result":result==nil?@{}:result
            };
            callback(res, beforeAfter ? YES : NO);

            if (beforeAfter) {
                NSDictionary *result2 = @{
                    @"status":@"complete",
                    @"name":name,
                    @"url":url,
                    @"cache":@(NO),
                    @"code":@(0),
                    @"headers":@{},
                    @"result":result==nil?@{}:result
                };
                callback(result2, NO);
            }
        }];
        [self.taskDic setObject:dataTask forKey:name];
    }
#pragma mark Upload
    else if (files.count > 0) {
        NSURLSessionDataTask *dataTask = [manager POST_EEUI:url parameters:data headers:nil constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
            for (NSString *key in files.allKeys) {
                id obj = files[key];
                if ([obj isKindOfClass:[NSString class]]) {
                    NSString *mimeType = [self mimeTypeForFileAtPath:obj];
                    if (mimeType == nil) {
                        continue;
                    }
                    NSString *fileName = files[key];
                    if ([mimeType hasPrefix:@"image"]) {
                        UIImage *image = [UIImage imageWithContentsOfFile:fileName];
                        if (!image) {
                            //缓存
                            NSString *newUrl = [key stringByReplacingOccurrencesOfString:@"file://" withString:@""];
                            image = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:newUrl];
                        }
                        [formData appendPartWithFileData:UIImagePNGRepresentation(image)
                                                    name:key
                                                fileName:fileName
                                                mimeType:mimeType];
                    } else {
                        NSURL *objUrl = [NSURL fileURLWithPath:obj];
                        NSError *error = nil;
                        NSData *fileData = [NSData dataWithContentsOfURL:objUrl options:NSDataReadingMappedIfSafe error:&error];
                        [formData appendPartWithFileData:fileData name:key fileName:[objUrl lastPathComponent] mimeType:mimeType];
                    }
                } else if ([obj isKindOfClass:[NSArray class]]) {
                    for (NSUInteger i = 0; i < [obj count]; i++) {
                        id obj_item = obj[i];
                        NSString *tempName = [NSString stringWithFormat:@"%@[%ld]", key, (long) i];
                        if ([obj_item isKindOfClass:[NSString class]]) {
                            NSString *mimeType = [self mimeTypeForFileAtPath:obj_item];
                            if (mimeType == nil) {
                                continue;
                            }
                            NSString *fileName = obj_item;
                            if ([mimeType hasPrefix:@"image"]) {
                                UIImage *image = [UIImage imageWithContentsOfFile:fileName];
                                if (!image) {
                                    //缓存
                                    NSString *newUrl = [key stringByReplacingOccurrencesOfString:@"file://" withString:@""];
                                    image = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:newUrl];
                                }
                                [formData appendPartWithFileData:UIImagePNGRepresentation(image)
                                                            name:tempName
                                                        fileName:fileName
                                                        mimeType:mimeType];
                            } else {
                                NSURL *objUrl = [NSURL fileURLWithPath:obj];
                                NSError *error = nil;
                                NSData *fileData = [NSData dataWithContentsOfURL:objUrl options:NSDataReadingMappedIfSafe error:&error];
                                [formData appendPartWithFileData:fileData name:tempName fileName:[objUrl lastPathComponent] mimeType:mimeType];
                            }
                        }
                    }
                }
            }
        } progress:^(NSProgress * _Nonnull uploadProgress) {
            //EELog(@"%@", uploadProgress);
            if (progressCall) {
                NSDictionary *progress = @{
                        @"fraction":@(uploadProgress.fractionCompleted),
                        @"current":@(uploadProgress.completedUnitCount),
                        @"total":@(uploadProgress.totalUnitCount)
                };
                NSDictionary *res = @{
                        @"status":@"progress",
                        @"name":name,
                        @"url":url,
                        @"cache":@(NO),
                        @"code":@(0),
                        @"headers":@{},
                        @"progress":progress,
                        @"result":@{}
                };
                callback(res, YES);
            }
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject, NSInteger resCode, NSDictionary *resHeaders) {
            //EELog(@"%@", responseObject);
            NSDictionary *res = @{
                @"status":@"success",
                @"name":name,
                @"url":url,
                @"cache":@(NO),
                @"code":@(resCode),
                @"headers":resHeaders,
                @"result":responseObject==nil?@{}:responseObject
            };
            callback(res, beforeAfter ? YES : NO);

            if (beforeAfter) {
                NSDictionary *result2 = @{
                    @"status":@"complete",
                    @"name":name,
                    @"url":url,
                    @"cache":@(NO),
                    @"code":@(0),
                    @"headers":@{},
                    @"result":@{}
                };
                callback(result2, NO);
            }
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            //EELog(@"%@", error);
            id result = [[error userInfo] objectForKey:NSLocalizedDescriptionKey];
            NSHTTPURLResponse *errorData = [[error userInfo] objectForKey:AFNetworkingOperationFailingURLResponseErrorKey];

            NSDictionary *res = @{
                @"status":@"error",
                @"name":name,
                @"url":url,
                @"cache":@(NO),
                @"code":errorData==nil?@(0):@([errorData statusCode]),
                @"headers":errorData==nil?@{}:[errorData allHeaderFields],
                @"result":result==nil?@{}:result
            };
            callback(res, beforeAfter ? YES : NO);

            if (beforeAfter) {
                NSDictionary *result2 = @{
                    @"status":@"complete",
                    @"name":name,
                    @"url":url,
                    @"cache":@(NO),
                    @"code":@(0),
                    @"headers":@{},
                    @"result":result==nil?@{}:result
                };
                callback(result2, NO);
            }
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


//path为要获取MIMEType的文件路径
- (NSString *)mimeTypeForFileAtPath:(NSString *)path
{
    if (![[[NSFileManager alloc] init] fileExistsAtPath:path]) {
        
        NSString *type = [path pathExtension];
        
        if ([type isEqualToString:@"png"]) {
            return [NSString stringWithFormat:@"image/%@", type];
        }
        
        if ([type isEqualToString:@"jpg"]) {
            return [NSString stringWithFormat:@"image/%@", type];
        }
        
        if ([type isEqualToString:@"jpeg"]) {
            return [NSString stringWithFormat:@"image/%@", type];
        }
        
        if ([type isEqualToString:@"gif"]) {
            return [NSString stringWithFormat:@"image/%@", type];
        }
        
        return @"application/octet-stream";
    }
    

    CFStringRef UTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef)[path pathExtension], NULL);
    CFStringRef MIMEType = UTTypeCopyPreferredTagWithClass (UTI, kUTTagClassMIMEType);
    CFRelease(UTI);
    if (!MIMEType) {
        return @"application/octet-stream";
    }
    return (__bridge NSString *)(MIMEType);
}

@end
