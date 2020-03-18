/*
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements.  See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership.  The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License.  You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied.  See the License for the
 * specific language governing permissions and limitations
 * under the License.
 */

#import "WXImgLoaderDefaultImpl.h"
#import "UIImageView+WebCache.h"
#import "WeexSDKManager.h"
#import "DeviceUtil.h"
#import "Config.h"

#define MIN_IMAGE_WIDTH 36
#define MIN_IMAGE_HEIGHT 36

#if OS_OBJECT_USE_OBJC
#undef  WXDispatchQueueRelease
#undef  WXDispatchQueueSetterSementics
#define WXDispatchQueueRelease(q)
#define WXDispatchQueueSetterSementics strong
#else
#undef  WXDispatchQueueRelease
#undef  WXDispatchQueueSetterSementics
#define WXDispatchQueueRelease(q) (dispatch_release(q))
#define WXDispatchQueueSetterSementics assign
#endif

@interface EeuiAssetsLoaderOperation : NSObject<WXImageOperationProtocol>

@end

@implementation EeuiAssetsLoaderOperation

- (void)cancel {}

@end

@interface WXImgLoaderDefaultImpl()

@property (WXDispatchQueueSetterSementics, nonatomic) dispatch_queue_t ioQueue;

@end

@implementation WXImgLoaderDefaultImpl

- (id<WXImageOperationProtocol>)downloadImageWithURL:(NSString *)url imageFrame:(CGRect)imageFrame userInfo:(NSDictionary *)userInfo completed:(void(^)(UIImage *image,  NSError *error, BOOL finished))completedBlock
{
    if ([url hasPrefix: @"local:///"]) {
        UIImage *img = [UIImage imageNamed: [url substringFromIndex: @"local:///".length]];
        completedBlock(img, nil, YES);
        
        return [EeuiAssetsLoaderOperation new];
    }
    
    WXSDKInstance *instance = [WXSDKManager instanceForID:userInfo[@"instanceId"]];
    url = [Config verifyFile:[DeviceUtil rewriteUrl:[self handCachePageUr:url] mInstance:instance]];
    url = [DeviceUtil urlEncoder:url];
    
    return (id<WXImageOperationProtocol>)[SDWebImageDownloader.sharedDownloader downloadImageWithURL:[NSURL URLWithString:url] options:SDWebImageDownloaderLowPriority progress:nil completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, BOOL finished) {
        if (completedBlock) {
            if (!image) {
                image = [UIImage imageWithContentsOfFile:url];
                if (!image) {
                    //缓存
                    NSString *newUrl = [url stringByReplacingOccurrencesOfString:@"file://" withString:@""];
                    image = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:newUrl];
                    if (image) {
                        error = nil;
                    }
                }
            }
            completedBlock(image, error, finished);
        }
    }];
}

- (NSString *)handCachePageUr:(NSString *)url
{
    if (url.length == 0) {
        return url;
    }
    NSString *cacheUrl = [NSString stringWithFormat:@"file://%@%@/", [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"page_cache"], [Config getSandPath:@"update"]];
    if ([url hasPrefix:cacheUrl]) {
        NSString *tmpUrl = [url substringFromIndex:cacheUrl.length];
        if ([tmpUrl containsString:@"/"]) {
            NSRange searchResult = [tmpUrl rangeOfString:@"/"];
            if (searchResult.location != NSNotFound) {
                NSString *dataId = [tmpUrl substringToIndex:searchResult.location];
                
                if ([self judgeIsNumberByRegularExpressionWith:dataId]) {
                    return [NSString stringWithFormat:@"root:/%@", [tmpUrl substringFromIndex:dataId.length]];
                }
            }
        }
    }
    return url;
}

- (BOOL)judgeIsNumberByRegularExpressionWith:(NSString *)str
{
   if (str.length == 0) {
        return NO;
    }
    NSString *regex = @"[0-9]*";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
    if ([pred evaluateWithObject:str]) {
        return YES;
    }
    return NO;
}

@end
