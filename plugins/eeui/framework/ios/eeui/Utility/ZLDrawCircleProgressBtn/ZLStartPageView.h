//
//  ZLStartPageView.h
//  ZLStartPageDemo
//
//  Created by ZL on 2017/3/1.
//  Copyright © 2017年 ZL. All rights reserved.
//  启动页

#import <UIKit/UIKit.h>

#define kscreenWidth [UIScreen mainScreen].bounds.size.width
typedef void (^skipCall)(void);

@interface ZLStartPageView : UIView

- (void)setShowTime:(int) time;
- (void)setSkip:(skipCall )block;
- (void)show;

@end
