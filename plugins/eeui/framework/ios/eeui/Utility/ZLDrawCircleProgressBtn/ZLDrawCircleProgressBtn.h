//
//  ZLDrawCircleProgressBtn.h
//  ZLStartPageDemo
//
//  Created by ZL on 2017/3/1.
//  Copyright © 2017年 ZL. All rights reserved.
//  跳过按钮

#import <UIKit/UIKit.h>

typedef void(^DrawCircleProgressBlock)(void);

@interface ZLDrawCircleProgressBtn : UIButton

//set track color
@property (nonatomic, strong) UIColor    *trackColor;

//set progress color
@property (nonatomic, strong) UIColor    *progressColor;

//set track background color
@property (nonatomic, strong) UIColor    *fillColor;

//set progress line width
@property (nonatomic, assign) CGFloat    lineWidth;

//set progress duration
@property (nonatomic, assign) CGFloat    animationDuration;

/**
 *  set complete callback
 *
 *  @param lineWidth line width
 *  @param block     block
 *  @param duration  time
 */
- (void)startAnimationDuration:(CGFloat)duration withBlock:(DrawCircleProgressBlock )block;

@end
