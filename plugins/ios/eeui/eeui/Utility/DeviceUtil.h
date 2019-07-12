//
//  DeviceUtil.h
//  WeexTestDemo
//
//  Created by apple on 2018/6/5.
//  Copyright © 2018年 TomQin. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <UIKit/UIKit.h>

#define SCALE(value) [DeviceUtil scale:value]
#define SCALEFLOAT(value) [DeviceUtil scaleFloat:value]
#define FONT(value) [DeviceUtil font:value]

#define ScreeScale [[UIScreen mainScreen]scale]

static NSMutableDictionary * mAppboardContent;

@interface DeviceUtil : NSObject

+ (CGFloat)scale:(NSInteger)value;

+ (CGFloat)scaleFloat:(float)value;

+ (NSInteger)font:(NSInteger)font;

+ (UIViewController *)getTopviewControler;

+ (NSString*)realUrl:(NSString*)url;

+ (NSString*)suffixUrl:(NSString*)pageType url:(NSString*)url;

+ (NSString*)rewriteUrl:(NSString*)url;

+ (UIImage*)getIconText:(NSString*)text font:(NSInteger)font color:(NSString*)icolor;

+ (NSString *)convertToCamelCaseFromSnakeCase:(NSString *)key;

+ (UIImage *)imageResize:(UIImage*)img andResizeTo:(CGSize)newSize icon:(NSString *)icon;

+ (NSString *)getAppboardContent;

+ (void)setAppboardContent:(NSString *)key content:(NSString *)content;

+ (void)downloadScript:(NSString *)url appboard:(NSString *)appboard cache:(NSInteger)cache callback:(void(^)(NSString* path))callback;

@end
