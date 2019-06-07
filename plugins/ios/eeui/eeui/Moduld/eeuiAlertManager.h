//
//  eeuiAlertManager.h
//  WeexTestDemo
//
//  Created by apple on 2018/6/6.
//  Copyright © 2018年 TomQin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WeexSDK.h"

@interface eeuiAlertManager : NSObject <UITextFieldDelegate>

@property (nonatomic, strong) NSMutableDictionary *taskDic;

+ (eeuiAlertManager *)sharedIntstance;

- (void)alert:(NSDictionary*)params callback:(WXModuleKeepAliveCallback)callback;

- (void)confirm:(NSDictionary*)params callback:(WXModuleKeepAliveCallback)callback;

- (void)input:(NSDictionary*)params callback:(WXModuleKeepAliveCallback)callback;

@end
