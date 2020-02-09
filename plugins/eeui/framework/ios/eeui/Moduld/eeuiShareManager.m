//
//  eeuiShareManager.m
//  WeexTestDemo
//
//  Created by apple on 2018/6/7.
//  Copyright © 2018年 TomQin. All rights reserved.
//

#import "eeuiShareManager.h"
#import "DeviceUtil.h"
#import "SDWebImageManager.h"
#import "UIButton+WebCache.h"

@implementation eeuiShareManager

+ (eeuiShareManager *)sharedIntstance {
    static dispatch_once_t once;
    static id instance;
    dispatch_once(&once, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (void)shareText:(NSString*)text
{
    if (text.length == 0) {
        return;
    }
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:@[text] applicationActivities:nil];
    activityVC.completionWithItemsHandler = ^(NSString *activityType,BOOL completed,NSArray *returnedItems,NSError *activityError)
    {
        EELog(@"%@", activityType);
        if (completed) {
            EELog(@"分享成功");
        } else {
            EELog(@"分享失败");
        }
    };

    [[DeviceUtil getTopviewControler] presentViewController:activityVC animated:YES completion:nil];
}

- (void)shareImage:(id)data
{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    if ([data isKindOfClass:[NSString class]]) {
        [array addObject:[data stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet characterSetWithCharactersInString:@"`#%^{}\"[]|\\<> "].invertedSet]];
    }else if ([data isKindOfClass:[NSMutableArray class]]) {
        for (NSString *url in data) {
            [array addObject:[url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet characterSetWithCharactersInString:@"`#%^{}\"[]|\\<> "].invertedSet]];
        }
    }
    NSInteger __block count = array.count;
    if (count <= 0) {
        return;
    }

    NSMutableArray *images = [[NSMutableArray alloc] init];
    for (NSString *url in array) {
        UIImage *newImage = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:url];
        if (newImage != nil) {
            //如果本地有
            [images addObject:newImage];
            count--;
            if (count == 0) {
                [self imageShare:images];
            }
        } else {
            //如果本地没有，下载
            [SDWebImageDownloader.sharedDownloader downloadImageWithURL:[NSURL URLWithString:url] options:SDWebImageDownloaderLowPriority progress:nil completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, BOOL finished) {
                if (image) {
                    [images addObject:image];
                }
                count--;
                if (count == 0 && images.count > 0) {
                    [self imageShare:images];
                }
            }];
        }
    }
}

- (void)imageShare:(NSArray*) images
{
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:images applicationActivities:nil];
    activityVC.completionWithItemsHandler = ^(NSString *activityType,BOOL completed,NSArray *returnedItems,NSError *activityError)
    {
        EELog(@"%@", activityType);
        if (completed) {
            EELog(@"分享成功");
        } else {
            EELog(@"分享失败");
        }
    };

    [[DeviceUtil getTopviewControler] presentViewController:activityVC animated:YES completion:nil];
}

@end
