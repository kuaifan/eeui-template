//
//  CustomWeexSDKManager.h
//  Pods
//
//  Created by 高一 on 2019/3/3.
//

#import <Foundation/Foundation.h>

static NSString * _Nullable softInputMode;
static BOOL keyBoardlsVisible;

NS_ASSUME_NONNULL_BEGIN

@interface CustomWeexSDKManager : NSObject

+ (NSString *)getSoftInputMode;
+ (void) setSoftInputMode:(NSString *) mode;

+ (BOOL)getKeyBoardlsVisible;
+ (void) setKeyBoardlsVisible:(BOOL) visible;

@end

NS_ASSUME_NONNULL_END
