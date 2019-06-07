//
//  NSObject+performSelector.h
//  NSInvocation
//
//  Created by MENGCHEN on 15/9/10.
//  Copyright (c) 2015年 Mcking. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (performSelector)


- (id)performSelector:(SEL)aSelector withObjects:(NSArray*)objects;
@end
