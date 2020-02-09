//
//  eeuiToastManager.h
//  WeexTestDemo
//
//  Created by apple on 2018/6/7.
//  Copyright © 2018年 TomQin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WeexSDK.h"

@interface eeuiToastManager : NSObject

@property (nonatomic, strong) NSString *message;
@property (nonatomic, strong) NSString *gravity;
@property (nonatomic, strong) NSString *messageColor;
@property (nonatomic, strong) NSString *backgroundColor;
@property (nonatomic, assign) BOOL longer;
@property (nonatomic, assign) NSInteger x;
@property (nonatomic, assign) NSInteger y;

+ (eeuiToastManager *)sharedIntstance;

- (void)toast:(id)params;

- (void)toastClose;

@end
