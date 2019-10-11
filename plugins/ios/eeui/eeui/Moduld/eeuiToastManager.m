//
//  eeuiToastManager.m
//  WeexTestDemo
//
//  Created by apple on 2018/6/7.
//  Copyright © 2018年 TomQin. All rights reserved.
//

#import "eeuiToastManager.h"

#define ToastTag 999

@implementation eeuiToastManager

+ (eeuiToastManager *)sharedIntstance {
    static dispatch_once_t once;
    static id instance;
    dispatch_once(&once, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (void)toast:(id)params
{
    if ([params isKindOfClass:[NSString class]]) {
        self.message = params;
        self.gravity = @"bottom";
        self.messageColor = @"#FFFFFF";
        self.backgroundColor = @"#000000";
        self.longer = NO;
        self.x = 0;
        self.y = 0;
    } else if ([params isKindOfClass:[NSNumber class]]) {
        self.message = [NSString stringWithFormat: @"%@", params];
        self.gravity = @"bottom";
        self.messageColor = @"#FFFFFF";
        self.backgroundColor = @"#000000";
        self.longer = NO;
        self.x = 0;
        self.y = 0;
    } else if ([params isKindOfClass:[NSDictionary class]]) {
        self.message = params[@"message"] ? [WXConvert NSString:params[@"message"]] : @"";
        self.gravity = params[@"gravity"] ? [WXConvert NSString:params[@"gravity"]] : @"bottom";
        self.messageColor = params[@"messageColor"] ? [WXConvert NSString:params[@"messageColor"]] : @"#FFFFFF";
        self.backgroundColor = params[@"backgroundColor"] ? [WXConvert NSString:params[@"backgroundColor"]] : @"#000000";
        self.longer = params[@"long"] ? [WXConvert BOOL:params[@"long"]] : NO;
        self.x = params[@"x"] ? [WXConvert NSInteger:params[@"x"]] : 0;
        self.y = params[@"y"] ? [WXConvert NSInteger:params[@"y"]] : 0;
    } else {
        return;
    }

    UIWindow *window = [UIApplication sharedApplication].delegate.window;

    UILabel *toastLab = [[UILabel alloc] init];
    toastLab.font = [UIFont systemFontOfSize:12.0f];
    toastLab.textAlignment = NSTextAlignmentCenter;
    toastLab.numberOfLines = 0;
    toastLab.text = self.message;
    toastLab.textColor = [WXConvert UIColor:self.messageColor];
    toastLab.backgroundColor = [WXConvert UIColor:self.backgroundColor];
    toastLab.layer.cornerRadius = 7.0f;
    toastLab.layer.masksToBounds = YES;
    toastLab.alpha = 0;
    toastLab.tag = ToastTag;
    [window addSubview:toastLab];


    CGFloat width = 200, height = 30, cx = 0, cy = 0;

    CGSize size = [self.message boundingRectWithSize:CGSizeMake(window.bounds.size.width - 60, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:[NSDictionary dictionaryWithObjectsAndKeys:toastLab.font,NSFontAttributeName, nil] context:nil].size;

    if (size.height + 20 > height) {
        height = size.height + 20;
    }

    if (size.width + 20 > width) {
        width = size.width + 20;
    }

    cx = window.bounds.size.width/2;

    if ([self.gravity isEqualToString:@"top"]) {
        cy = 60 + height/2;
    } else if ([self.gravity isEqualToString:@"middle"]) {
        cy = window.bounds.size.height/2 + height/2;
    } else if ([self.gravity isEqualToString:@"bottom"]) {
        cy = window.bounds.size.height - 60 - height/2;
    }

    toastLab.frame = CGRectMake(0, 0, width, height);
    toastLab.center = CGPointMake(cx + self.x, cy + self.y);

    [UIView animateWithDuration:0.3 animations:^{
        toastLab.alpha = 1;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.3 delay:self.longer?3.5:1.8 options:0 animations:^{
            toastLab.alpha = 0;
        } completion:^(BOOL finished) {
            [toastLab removeFromSuperview];
        }];
    }];
}

- (void)toastClose
{
    UIWindow *window = [UIApplication sharedApplication].delegate.window;
    UIView *toastView = [window viewWithTag:ToastTag];
    if (toastView) {
        [toastView removeFromSuperview];
    }
}

@end
