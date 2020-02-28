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

@property (nonatomic, strong) NSMutableDictionary *pageScriptUrlDic;

+ (eeuiStorageManager *)sharedIntstance;

- (void)setCaches:(NSString*)key value:(id)value expired:(NSInteger)expired;

- (id)getCaches:(NSString*)key defaultVal:(id)defaultVal;

- (void)setCachesString:(NSString*)key value:(NSString*)value expired:(NSInteger)expired;

- (NSString*)getCachesString:(NSString*)key defaultVal:(NSString*)defaultVal;

- (id)getAllCaches;

- (void)clearAllCaches;

- (void)setVariate:(NSString*)key value:(id)value;

- (id)getVariate:(NSString*)key defaultVal:(id)defaultVal;

- (id)getAllVariate;

- (void)clearAllVariate;

- (void)setPageScriptUrl:(NSString*)scriptURL url:(NSString*)url;

- (NSString *)getPageScriptUrl:(NSString*)scriptURL defaultVal:(NSString*)defaultVal;

@end
