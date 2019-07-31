//
//  NavigatorBridge.m
//  Pods
//
//  Created by 高一 on 2019/3/16.
//

#import "NavigatorBridge.h"
#import "eeuiNewPageManager.h"
#import "DeviceUtil.h"
#import "WXConvert.h"

@implementation NavigatorBridge

- (void)push:(id)params callback:(WXModuleKeepAliveCallback)callback
{
    NSMutableDictionary *info = [[NSMutableDictionary alloc] init];
    if ([params isKindOfClass:[NSString class]]) {
        info[@"url"] = params;
    }else if (![params isKindOfClass:[NSDictionary class]]) {
        return;
    }
    info = [params mutableCopy];
    info[@"pageTitle"] = info[@"pageTitle"] ? [WXConvert NSString:info[@"pageTitle"]] : @" ";
    [[eeuiNewPageManager sharedIntstance] openPage:info weexInstance:[[WXSDKManager bridgeMgr] topInstance] callback:callback];
}

- (void)pop:(id)params callback:(WXModuleKeepAliveCallback)callback
{
    NSMutableDictionary *info = [[NSMutableDictionary alloc] init];
    NSString *name = @"";
    if ([params isKindOfClass:[NSString class]]) {
        name = [(eeuiViewController*)[DeviceUtil getTopviewControler] pageName];
    } else if ([params isKindOfClass:[NSDictionary class]]) {
        info = [[NSMutableDictionary alloc] initWithDictionary:params];
        name = params[@"pageName"] ? [WXConvert NSString:params[@"pageName"]] : [(eeuiViewController*)[DeviceUtil getTopviewControler] pageName];
    }
    info[@"pageName"] = name;
    if (callback) {
        info[@"listenerName"] = @"__navigatorPop";
        [[eeuiNewPageManager sharedIntstance] setPageStatusListener:info callback:callback];
    }
    [[eeuiNewPageManager sharedIntstance] closePage:info weexInstance:[[WXSDKManager bridgeMgr] topInstance]];
}

@end

