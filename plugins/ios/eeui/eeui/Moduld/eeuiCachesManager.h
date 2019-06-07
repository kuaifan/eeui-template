//
//  eeuiCachesManager.h
//  WeexTestDemo
//
//  Created by apple on 2018/6/6.
//  Copyright © 2018年 TomQin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WeexSDK.h"

@interface eeuiCachesManager : NSObject

+ (eeuiCachesManager *)sharedIntstance;

- (void)getCacheSizeDir:(WXModuleKeepAliveCallback)callback;
- (void)clearCacheDir:(WXModuleKeepAliveCallback)callback;
- (void)getCacheSizeFiles:(WXModuleKeepAliveCallback)callback;
- (void)clearCacheFiles:(WXModuleKeepAliveCallback)callback;
- (void)getCacheSizeDbs:(WXModuleKeepAliveCallback)callback;
- (void)clearCacheDbs:(WXModuleKeepAliveCallback)callback;

@end
