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
        UIViewController *vc = [DeviceUtil getTopviewControler];
        if ([vc isKindOfClass:eeuiViewController.class]) {
            name = [(eeuiViewController*)vc pageName];
        }
    } else if ([params isKindOfClass:[NSDictionary class]]) {
        info = [[NSMutableDictionary alloc] initWithDictionary:params];
        if (params[@"pageName"]) {
            name = [WXConvert NSString:params[@"pageName"]];
        } else {
            UIViewController *vc = [DeviceUtil getTopviewControler];
            if ([vc isKindOfClass:eeuiViewController.class]) {
                name = [(eeuiViewController*)vc pageName];
            }
        }
    }
    info[@"pageName"] = name;
    if (callback) {
        info[@"listenerName"] = @"__navigatorPop";
        [[eeuiNewPageManager sharedIntstance] setPageStatusListener:info weexInstance:[[WXSDKManager bridgeMgr] topInstance] callback:callback];
    }
    [[eeuiNewPageManager sharedIntstance] closePage:info weexInstance:[[WXSDKManager bridgeMgr] topInstance]];
}

@end

