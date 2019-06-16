//
//  eeuiDebugModule.h
//  Pods
//
//  Created by 高一 on 2019/3/13.
//

#import <Foundation/Foundation.h>
#import "WeexSDK.h"

static WXModuleKeepAliveCallback _Nullable mJSCallback;
static NSMutableArray * _Nullable historys;

@interface eeuiDebugModule : NSObject <WXModuleProtocol>

@end
