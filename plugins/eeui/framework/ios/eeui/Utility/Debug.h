//
//  Debug.h
//  BindingX
//
//  Created by 高一 on 2019/12/13.
//

#import <Foundation/Foundation.h>
#import "WeexSDK.h"

static WXModuleKeepAliveCallback __nullable debugBtnCallback;
static WXModuleKeepAliveCallback __nullable debugJSCallback;
static NSMutableArray * __nullable debugHistorys;

NS_ASSUME_NONNULL_BEGIN

@interface Debug : NSObject

+ (void)addDebug:(NSString*)type log:(id)log pageUrl:(NSString*)pageUrl;

+ (void)setDebugBtnStatus:(NSInteger)status;

+ (void)setDebugBtnCallback:(WXModuleKeepAliveCallback __nullable)callback;
+ (WXModuleKeepAliveCallback)getDebugBtnCallback;

+ (void)setDebugJSCallback:(WXModuleKeepAliveCallback __nullable)callback;
+ (WXModuleKeepAliveCallback)getDebugJSCallback;

+ (void)setDebugHistorys:(NSMutableArray* __nullable)data;
+ (NSMutableArray*)getDebugHistorys;

@end

NS_ASSUME_NONNULL_END
