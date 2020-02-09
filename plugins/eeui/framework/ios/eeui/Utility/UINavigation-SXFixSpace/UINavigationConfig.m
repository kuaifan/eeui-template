//
//  UINavigationConfig.m
//  UINavigation-SXFixSpace
//
//  Created by charles on 2018/4/20.
//  Copyright © 2018年 None. All rights reserved.
//

#import "UINavigationConfig.h"

@implementation UINavigationConfig

+ (instancetype)shared {
    static UINavigationConfig *config;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        config = [[self alloc] init];
    });
    return config;
}

-(instancetype)init {
    if (self = [super init]) {
        self.sx_defaultFixSpace = 0;
        self.sx_disableFixSpace = NO;
    }
    return self;
}

- (CGFloat)sx_systemSpace {
    return MIN([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height) > 375 ? 20 : 16;
}

+(NSArray *)itemSpace:(UIBarButtonItem *)barButtonItem {
    UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    space.width = MIN([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height) > 375 ? 20 : 16;
    return @[space, barButtonItem];
}

@end
