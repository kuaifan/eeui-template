//
//  eeuiCaptchaManager.h
//  WeexTestDemo
//
//  Created by apple on 2018/6/6.
//  Copyright © 2018年 TomQin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WeexSDK.h"
#import "TTGPuzzleVerifyView.h"

@interface eeuiCaptchaManager : NSObject <TTGPuzzleVerifyViewDelegate>

@property (nonatomic, strong) NSString *pageName;

@property (nonatomic, strong) TTGPuzzleVerifyView *puzzleVerifyView;
@property (nonatomic, copy) WXModuleKeepAliveCallback callback;

+ (eeuiCaptchaManager *)sharedIntstance;

- (void)swipeCaptcha:(NSString*)imgUrl callback:(WXModuleKeepAliveCallback)callback;

@end
