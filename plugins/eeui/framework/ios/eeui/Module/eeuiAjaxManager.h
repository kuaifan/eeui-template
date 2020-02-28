//
//  eeuiAjaxManager.h
//  WeexTestDemo
//
//  Created by apple on 2018/6/5.
//  Copyright © 2018年 TomQin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WeexSDK.h"

@interface eeuiAjaxManager : NSObject

@property (nonatomic, strong) NSMutableDictionary *taskDic;

+ (eeuiAjaxManager *)sharedIntstance;

- (void)ajax:(NSDictionary*)params callback:(WXModuleKeepAliveCallback)callback;

- (void)ajaxCancel:(NSString*)name;

- (void)getCacheSizeAjax:(WXModuleKeepAliveCallback)callback;

- (void)clearCacheAjax;

@end
