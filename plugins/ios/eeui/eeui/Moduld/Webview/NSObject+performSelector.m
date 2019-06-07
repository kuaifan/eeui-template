//
//  NSObject+performSelector.m
//  NSInvocation
//
//  Created by MENGCHEN on 15/9/10.
//  Copyright (c) 2015年 Mcking. All rights reserved.
//

#import "NSObject+performSelector.h"

@implementation NSObject (performSelector)
- (id)performSelector:(SEL)aSelector withObjects:(NSArray*)objects{
    //1、创建签名对象
    NSMethodSignature*signature = [[self class] instanceMethodSignatureForSelector:aSelector];
    
    //2、判断传入的方法是否存在
    if (signature==nil) {
        //传入的方法不存在 就抛异常
        //NSString*info = [NSString stringWithFormat:@"-[%@ %@]:unrecognized selector sent to instance",[self class],NSStringFromSelector(aSelector)];
        //@throw [[NSException alloc] initWithName:@"方法没有" reason:info userInfo:nil];
        return nil;
    }
    
    //3、、创建NSInvocation对象
    NSInvocation*invocation = [NSInvocation invocationWithMethodSignature:signature];
    
    //4、保存方法所属的对象
    invocation.target = self;
    invocation.selector = aSelector;

    //5、设置参数
    /*
     当前如果直接遍历参数数组来设置参数
     如果参数数组元素多余参数个数，那么就会报错
     */
    NSInteger arguments =signature.numberOfArguments-2;
    /*
     谁少就遍历谁
     */
    NSUInteger objectsCount = objects.count;
    NSInteger count = MIN(arguments, objectsCount);
    for (int i = 0; i<count; i++) {
        NSObject*obj = objects[i];
        //处理参数是NULL类型的情况
        if ([obj isKindOfClass:[NSNull class]]) {
            obj = nil;
        }
        [invocation setArgument:&obj atIndex:i+2];

    }
    
    //6、调用NSinvocation对象
    [invocation invoke];
    
    //7、获取返回值
    id result = nil;
    if (signature.methodReturnLength != 0) {
        NSString *returnTypeString = [NSString stringWithUTF8String:[signature methodReturnType]];
        if ([returnTypeString isEqualToString:@"@"]) { // id
            void * returnValue;[invocation getReturnValue:&returnValue];result = (__bridge id)returnValue; returnValue = nil;
        }  else if ([returnTypeString isEqualToString:@"B"]) { // bool
            bool returnValue;[invocation getReturnValue:&returnValue];result = [NSNumber numberWithBool:returnValue];
        } else if ([returnTypeString isEqualToString:@"f"]) { // float
            float returnValue;[invocation getReturnValue:&returnValue];result = [NSNumber numberWithFloat:returnValue];
        } else if ([returnTypeString isEqualToString:@"d"]) { // double
            double returnValue;[invocation getReturnValue:&returnValue];result = [NSNumber numberWithDouble:returnValue];
        } else if ([returnTypeString isEqualToString:@"c"]) { // char
            char returnValue;[invocation getReturnValue:&returnValue];result = [NSNumber numberWithChar:returnValue];
        } else if ([returnTypeString isEqualToString:@"i"]) { // int
            int returnValue;[invocation getReturnValue:&returnValue];result = [NSNumber numberWithInt:returnValue];
        } else if ([returnTypeString isEqualToString:@"I"]) { // unsigned int
            unsigned int returnValue;[invocation getReturnValue:&returnValue];result = [NSNumber numberWithUnsignedInteger:returnValue];
        } else if ([returnTypeString isEqualToString:@"S"]) { // unsigned short
            unsigned short returnValue;[invocation getReturnValue:&returnValue];result = [NSNumber numberWithUnsignedShort:returnValue];
        } else if ([returnTypeString isEqualToString:@"L"]) { // unsigned long
            unsigned long returnValue;[invocation getReturnValue:&returnValue];result = [NSNumber numberWithUnsignedLong:returnValue];
        } else if ([returnTypeString isEqualToString:@"s"]) { // shrot
            short returnValue;[invocation getReturnValue:&returnValue];result = [NSNumber numberWithShort:returnValue];
        } else if ([returnTypeString isEqualToString:@"l"]) { // long
            long returnValue;[invocation getReturnValue:&returnValue];result = [NSNumber numberWithLong:returnValue];
        } else if ([returnTypeString isEqualToString:@"q"]) { // long long
            long long returnValue;[invocation getReturnValue:&returnValue];result = [NSNumber numberWithLongLong:returnValue];
        } else if ([returnTypeString isEqualToString:@"C"]) { // unsigned char
            unsigned char returnValue;[invocation getReturnValue:&returnValue];result = [NSNumber numberWithUnsignedChar:returnValue];
        } else if ([returnTypeString isEqualToString:@"Q"]) { // unsigned long long
            unsigned long long returnValue;[invocation getReturnValue:&returnValue];result = [NSNumber numberWithUnsignedLongLong:returnValue];
        }else if([returnTypeString isEqualToString:@"v"]){
            result = nil;
        }else{
            result = nil;
        }
    }
    return result;
}
@end
