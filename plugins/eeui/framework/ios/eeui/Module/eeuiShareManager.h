//
//  eeuiShareManager.h
//  WeexTestDemo
//
//  Created by apple on 2018/6/7.
//  Copyright © 2018年 TomQin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WeexSDK.h"

@interface eeuiShareManager : NSObject

+ (eeuiShareManager *)sharedIntstance;

- (void)shareText:(NSString*)text;
- (void)shareImage:(id)imgUrl;

@end
