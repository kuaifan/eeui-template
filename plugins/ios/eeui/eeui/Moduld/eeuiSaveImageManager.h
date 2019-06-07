//
//  eeuiSaveImageManager.h
//  WeexTestDemo
//
//  Created by apple on 2018/6/7.
//  Copyright © 2018年 TomQin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WeexSDK.h"

@interface eeuiSaveImageManager : NSObject

@property (nonatomic, copy) WXKeepAliveCallback callback;

+ (eeuiSaveImageManager *)sharedIntstance;

- (void)saveImage:(NSString*)imgUrl callback:(WXKeepAliveCallback)callback;

@end
