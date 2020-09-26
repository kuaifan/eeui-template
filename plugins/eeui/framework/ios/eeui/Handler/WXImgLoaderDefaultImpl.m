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
    
    return (id<WXImageOperationProtocol>)[SDWebImageDownloader.sharedDownloader downloadImageWithURL:[NSURL URLWithString:url] options:0 progress:nil completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, BOOL finished) {
        if (completedBlock) {
            completedBlock(image, error, finished);
        }
        [self _recoredFinish:[NSURL URLWithString:url] error:error loadOptions:userInfo];
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

- (void)setImageViewWithURL:(UIImageView *)imageView url:(NSURL *)url placeholderImage:(UIImage *)placeholder options:(NSDictionary *)options progress:(void (^)(NSInteger, NSInteger))progressBlock completed:(void (^)(UIImage *, NSError *, WXImageLoaderCacheType, NSURL *))completedBlock
{
    WXSDKInstance *instance = [WXSDKManager instanceForID:options[@"instanceId"]];
    NSString *urlStr = [Config verifyFile:[DeviceUtil rewriteUrl:[self handCachePageUr:url.absoluteString] mInstance:instance]];
    urlStr = [DeviceUtil urlEncoder:urlStr];
    [self _recoredImgLoad:urlStr options:options];
    SDWebImageOptions sdWebimageOption = SDWebImageRetryFailed;
    if (options && options[@"sdWebimageOption"]) {
        [options[@"sdWebimageOption"] intValue];
    }
    
    [imageView sd_setImageWithURL:[NSURL URLWithString:urlStr] placeholderImage:placeholder options:sdWebimageOption progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
        if (progressBlock) {
            progressBlock(receivedSize, expectedSize);
        }
    } completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        if (completedBlock) {
            completedBlock(image, error, (WXImageLoaderCacheType)cacheType, imageURL);
        }
        [self _recoredFinish:imageURL error:error loadOptions:options];
    }];
}

- (void) _recoredImgLoad:(NSString *)url options:(NSDictionary *)options
{
    if (nil == url) {
        return;
    }
    NSString* instanceId = [options objectForKey:@"instanceId"];
    if (nil == instanceId) {
        WXLogWarning(@"please set instanceId in userInfo,for url %@:",url);
        return;
    }
    WXSDKInstance* instance =[WXSDKManager instanceForID:instanceId];
    if (nil == instance) {
        return;
    }
    [instance.apmInstance updateDiffStats:KEY_PAGE_STATS_IMG_LOAD_NUM withDiffValue:1];
}

- (void) _recoredFinish:(NSURL*)imgUrl error:(NSError*)error loadOptions:(NSDictionary*)options
{
    NSString* instanceId = [options objectForKey:@"instanceId"];
    if (nil == instanceId) {
        WXLogWarning(@"please set instanceId in userInfo,for url %@:",imgUrl.absoluteString);
        return;
    }
    WXSDKInstance* instance =[WXSDKManager instanceForID:instanceId];
    if (nil == instance) {
        return;
    }
    bool loadSucceed = error == nil;
    [instance.apmInstance actionImgLoadResult:loadSucceed withErrorCode:nil];
}
@end
