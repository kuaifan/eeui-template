//
//  NSTimer+eeui.h
//  WeexTestDemo
//
//  Created by apple on 2018/6/2.
//  Copyright © 2018年 TomQin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSTimer (eeui)

+ (NSTimer *)wx_scheduledTimerWithTimeInterval:(NSTimeInterval)interval
                                         block:(void(^)(void))block
                                       repeats:(BOOL)repeats;

@end
