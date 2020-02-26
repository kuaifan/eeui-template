//
//  eeuiLoadingManager.h
//  WeexTestDemo
//
//  Created by apple on 2018/6/6.
//  Copyright © 2018年 TomQin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WeexSDK.h"

@interface eeuiLoadingManager : NSObject

@property (nonatomic, strong) NSMutableDictionary *loadingDic;
@property (nonatomic, strong) NSMutableArray *loadingList;

+ (eeuiLoadingManager *)sharedIntstance;

- (NSString*)loading:(NSDictionary*)params callback:(WXModuleKeepAliveCallback)callback;

- (void)loadingClose:(NSString*)name;

@end
