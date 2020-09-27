//
//  CustomWeexSDKManager.m
//  Pods
//
//  Created by 高一 on 2019/3/3.
//

#import "CustomWeexSDKManager.h"

@implementation CustomWeexSDKManager

+ (NSString *) getSoftInputMode {
    return softInputMode;
}

+ (void) setSoftInputMode:(NSString *) mode {
    softInputMode = mode;
}

+ (BOOL) getKeyBoardlsVisible {
    return keyBoardlsVisible;
}

+ (void) setKeyBoardlsVisible:(BOOL) visible {
    keyBoardlsVisible = visible;
}

@end
