
//
//  eeuiSaveImageManager.m
//  WeexTestDemo
//
//  Created by apple on 2018/6/7.
//  Copyright © 2018年 TomQin. All rights reserved.
//

#import "eeuiSaveImageManager.h"
#import <Photos/Photos.h>
#import "UIButton+WebCache.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "UIImageView+WebCache.h"
#import "SDWebImageDownloader.h"
#import "SDImageCache.h"

@implementation eeuiSaveImageManager

+ (eeuiSaveImageManager *)sharedIntstance {
    static dispatch_once_t once;
    static id instance;
    dispatch_once(&once, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (void)saveImage:(NSString*)imgUrl callback:(WXKeepAliveCallback)callback
{
    self.callback = callback;

    //获取图片
//    NSString * imageUrl = [imgUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString * imageUrl = [imgUrl stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet characterSetWithCharactersInString:@"`#%^{}\"[]|\\<> "].invertedSet];

    UIImage *newImage = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:imageUrl];//用地址去本地找图片
    if (newImage != nil) {//如果本地有
        [self authorizationStatus:newImage];
    } else {//如果本地没有
        //下载图片
        [SDWebImageDownloader.sharedDownloader downloadImageWithURL:[NSURL URLWithString:imageUrl] options:SDWebImageDownloaderLowPriority progress:nil completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, BOOL finished) {
            if (image) {
                [self authorizationStatus:image];
            }
        }];
    }
}

- (void)authorizationStatus:(UIImage*)image
{
    //判断授权状态
    PHAuthorizationStatus authorizationStatus = [PHPhotoLibrary authorizationStatus];

    if (authorizationStatus == PHAuthorizationStatusAuthorized) {
        [self loadImageFinished:image];
    } else if (authorizationStatus == PHAuthorizationStatusNotDetermined) {
         // 如果没决定, 弹出指示框, 让用户选择
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            // 如果用户选择授权, 则保存图片
            if (status == PHAuthorizationStatusAuthorized) {
                [self loadImageFinished:image];
            } else {
                if (self.callback) {
                    self.callback(@{@"status":@"error", @"path":@"", @"error":@"用户未授权"}, NO);
                }
            }
        }];
    } else {
        if (self.callback) {
            self.callback(@{@"status":@"error", @"path":@"", @"error":@"用户未授权"}, NO);
        }
    }

}

- (void)loadImageFinished:(UIImage *)image
{
    NSMutableArray *imageIds = [NSMutableArray array];
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        //写入图片到相册
        PHAssetChangeRequest *req = [PHAssetChangeRequest creationRequestForAssetFromImage:image];
        //记录本地标识，等待完成后取到相册中的图片对象
        [imageIds addObject:req.placeholderForCreatedAsset.localIdentifier];
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        EELog(@"success = %d, error = %@", success, error);
        if (success)
        {
            //成功后取相册中的图片对象
            __block PHAsset *imageAsset = nil;
            PHFetchResult *result = [PHAsset fetchAssetsWithLocalIdentifiers:imageIds options:nil];
            [result enumerateObjectsUsingBlock:^(PHAsset * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                imageAsset = obj;
                *stop = YES;
            }];

            if (imageAsset)
            {
                //加载图片数据
                [[PHImageManager defaultManager] requestImageDataForAsset:imageAsset
                                                                  options:nil
                                                            resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
                                                                NSString *path = [NSString stringWithFormat:@"%@",[info objectForKey:@"PHImageFileURLKey"]];
                                                                if ([path hasPrefix:@"file://"]) {
                                                                    path = [path stringByReplacingOccurrencesOfString:@"file://" withString:@""];
                                                                }
                                                                [[SDImageCache sharedImageCache] storeImage:image forKey:path completion:nil];
                                                                if (self.callback) {
                                                                    self.callback(@{@"status":@"success", @"path":path, @"error":@""}, NO);
                                                                }
                                                            }];
            }
        } else {
            if (self.callback) {
                self.callback(@{@"status":@"error", @"path":@"", @"error":error.localizedDescription}, NO);
            }
        }

    }];
}

@end
