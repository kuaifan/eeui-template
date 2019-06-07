//
//  WeexSDKManager.h
//  WeexDemo
//
//  Created by yangshengtao on 16/11/14.
//  Copyright © 2016年 taobao. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kCachePath @"cache_path"

@interface WeexSDKManager : NSObject

@property (nonatomic, strong) NSString *weexUrl;
@property (nonatomic, strong) NSMutableDictionary *cacheData;

+ (WeexSDKManager *)sharedIntstance;
- (void)setup;

@end
