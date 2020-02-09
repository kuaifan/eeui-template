//
//  eeuiScrollHeaderComponent.h
//  Pods
//
//  Created by 高一 on 2019/7/14.
//

#import "WXComponent.h"
#import "WeexSDK.h"

NS_ASSUME_NONNULL_BEGIN

@interface eeuiScrollHeaderComponent : WXComponent

@property (nonatomic, strong) NSString *status;
@property (nonatomic, assign) CGFloat bx;
@property (nonatomic, assign) CGFloat by;
@property (nonatomic, assign) BOOL isCallback;

- (void) stateCallback:(NSString *) status;

@end

NS_ASSUME_NONNULL_END
