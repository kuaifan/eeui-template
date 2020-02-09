//
//  ZYCRippleButton.h
//  ZYCRippleButton
//
//  Created by 朱佳杰 on 2017/4/1.
//  Copyright © 2017年 zjj. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^ZYCRippleButtonBlock)(void);

@interface ZYCRippleButton : UIView

@property (nonatomic, strong) UILabel *textLabel;
@property (nonatomic, strong) UIColor *rippleColor;
@property (nonatomic, assign) NSUInteger rippleLineWidth;
@property (nonatomic, copy)   ZYCRippleButtonBlock rippleBlock;

- (void) setButtonTittle:(NSString *)tittle;
- (void) setButtonTittleColor:(UIColor *)tColor;
- (void) setButtonBackgroundColor:(UIColor *)bgColor;
- (void) setButtonTittle:(NSString *)tittle withTittleColor:(UIColor *)tColor;
- (void) setButtonTittle:(NSString *)tittle withTittleColor:(UIColor *)tColor backgroundColor:(UIColor *)bgColor;


@end
