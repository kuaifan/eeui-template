//
//  eeuiStorageManager.h
//  WeexTestDemo
//
//  Created by apple on 2018/6/7.
//  Copyright © 2018年 TomQin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WeexSDK.h"

@interface eeuiStorageManager : NSObject

@property (nonatomic, strong) NSMutableDictionary *variateDic;

+ (eeuiStorageManager *)sharedIntstance;

- (void)setCachesString:(NSString*)key value:(id)value expired:(NSInteger)expired;

- (id)getCachesString:(NSString*)key defaultVal:(id)defaultVal;

- (void)setVariate:(NSString*)key value:(id)value;

- (id)getVariate:(NSString*)key defaultVal:(id)defaultVal;

@end
