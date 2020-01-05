//
//  Debug.m
//  BindingX
//
//  Created by 高一 on 2019/12/13.
//

#import "Debug.h"

@implementation Debug

+ (void)addDebug:(NSString*)type log:(id)log pageUrl:(NSString*)pageUrl
{
    if (debugHistorys == nil) {
        debugHistorys = [NSMutableArray new];
    }
    NSInteger time = [[NSDate date] timeIntervalSince1970];
    NSDictionary *data = @{@"type":type, @"text": log, @"page": pageUrl, @"time":@(time)};
    if (debugJSCallback != nil) {
        debugJSCallback(data, YES);
    }
    //
    long int count = [debugHistorys count];
    if (count > 1200) {
        NSMutableArray *tmpLists = [NSMutableArray new];
        for (int i = 0 ; i < count; i++) {
            if (i > 200) {
                [tmpLists addObject:[debugHistorys objectAtIndex:i]];
            }
        }
        debugHistorys = tmpLists;
    }
    [debugHistorys addObject:data];
    //
    if (debugBtnCallback != nil) {
        if ([type containsString:@"error"]) {
            debugBtnCallback(@(9009), YES);
        } else if ([type containsString:@"warn"]) {
            debugBtnCallback(@(9008), YES);
        } else {
            debugBtnCallback(@(9001), YES);
        }
    }
}

+ (void)setDebugBtnStatus:(NSInteger)status
{
    if (debugBtnCallback != nil) {
        debugBtnCallback(@(status), YES);
    }
}

+ (void)setDebugBtnCallback:(WXModuleKeepAliveCallback __nullable)callback
{
    debugBtnCallback = callback;
}

+ (WXModuleKeepAliveCallback)getDebugBtnCallback
{
    return debugBtnCallback;
}

+ (void)setDebugJSCallback:(WXModuleKeepAliveCallback __nullable)callback
{
    debugJSCallback = callback;
}

+ (WXModuleKeepAliveCallback)getDebugJSCallback
{
    return debugJSCallback;
}

+ (void)setDebugHistorys:(NSMutableArray* __nullable)data
{
    debugHistorys = data;
}

+ (NSMutableArray*)getDebugHistorys
{
    return debugHistorys;
}

@end
