//
//  NSTimer+eeui.m
//  WeexTestDemo
//
//  Created by apple on 2018/6/2.
//  Copyright © 2018年 TomQin. All rights reserved.
//

#import "NSTimer+eeui.h"

@implementation NSTimer (eeui)

+ (NSTimer *)wx_scheduledTimerWithTimeInterval:(NSTimeInterval)interval
                                         block:(void(^)(void))block
                                       repeats:(BOOL)repeats
{
    return [self scheduledTimerWithTimeInterval:interval
                                         target:self
                                       selector:@selector(blockInvoke:)
                                       userInfo:[block copy]
                                        repeats:repeats];
}

+ (void)blockInvoke:(NSTimer*)timer
{
    void (^block)(void) = timer.userInfo;
    if (block) {
        block();
    }
}
@end
